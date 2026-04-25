import Foundation
import TokamakShim
import WelcomShared

#if os(WASI)
import JavaScriptKit
#endif

#if os(WASI)
private typealias RelayTicker = JSTimer
#else
private final class RelayTicker {}
#endif

final class SmartSessionStore: ObservableObject {
    @Published var hostTopic: String = ""
    @Published var hostName: String = ""
    @Published var guestName: String = ""
    @Published var joinCode: String
    @Published var selectedRounds: Int = 2
    @Published var selectedTurnDuration: Int = 45
    @Published private(set) var session: Session?
    @Published private(set) var timeRemaining: Int = 0
    @Published private(set) var connectionStatus: String = "Ready to start"
    @Published private(set) var errorMessage: String?
    @Published private(set) var pendingParticipantName: String?
    @Published private(set) var shareURL: String?
    @Published private(set) var didCopyInvite = false
    @Published private(set) var roleLabel: String?

    private let localParticipantId = UUID().uuidString
    private let relayURL: String
    private var localParticipantName: String = ""
    private var pendingParticipantId: String?
    private var isHostSession = false
    private var ticker: RelayTicker?

    #if os(WASI)
    private var relaySocket: BrowserRelaySocket?
    #endif

    init() {
        self.joinCode = BrowserSupport.currentJoinCode() ?? ""
        self.relayURL = BrowserSupport.currentRelayURL()
    }

    var canCreateSession: Bool {
        !trimmed(hostTopic).isEmpty && !trimmed(hostName).isEmpty
    }

    var canJoinSession: Bool {
        normalizedJoinCode.count == 6 && !trimmed(guestName).isEmpty
    }

    var hasPendingParticipant: Bool {
        pendingParticipantId != nil && pendingParticipantName != nil
    }

    var waitingForApproval: Bool {
        !isHostSession && session?.status == .waiting
    }

    var sessionSummary: SessionSummaryViewModel? {
        guard let session else { return nil }
        return SessionSummaryViewModel(session: session)
    }

    var countdownText: String {
        guard let session else { return "Waiting to begin" }

        if session.status == .completed {
            return "Session completed"
        }

        if session.status == .waiting {
            return isHostSession
                ? "Share the invite and approve your guest when you're ready to start equal turns."
                : "Waiting for the host to let you into the equal-time session."
        }

        return "\(formatted(seconds: timeRemaining)) remaining in this turn"
    }

    var betaNotice: String {
        "Web beta uses a lightweight relay to sync browsers in real time. Today it mirrors the equal-turn two-participant session model, while the iPhone app remains the most private path with local Multipeer sessions."
    }

    func fillDemoHostDraft() {
        hostTopic = "Demo equal-turn session"
        hostName = "Speaker A"
        selectedRounds = 2
        selectedTurnDuration = 30
        errorMessage = nil
    }

    func fillDemoGuestDraft() {
        guestName = "Speaker B"

        if normalizedJoinCode.isEmpty {
            joinCode = BrowserSupport.currentJoinCode() ?? ""
        }

        errorMessage = nil
    }

    func createSession() {
        resetTransientState(keepDrafts: true)

        let topic = trimmed(hostTopic)
        let host = trimmed(hostName)
        let code = Self.generateCode()

        localParticipantName = host
        isHostSession = true
        roleLabel = "Host"
        joinCode = code
        didCopyInvite = false
        shareURL = BrowserSupport.inviteURL(for: code)
        timeRemaining = selectedTurnDuration
        connectionStatus = "Opening live relay…"

        session = Session(
            title: topic,
            sessionCode: code,
            status: .waiting,
            currentTurn: .partyA,
            currentTurnNumber: 1,
            maxTurns: selectedRounds,
            turnDuration: TimeInterval(selectedTurnDuration),
            partyAId: localParticipantId,
            partyBId: "",
            partyAName: host,
            partyBName: "Waiting for guest",
            turnStartedAt: nil
        )

        connectToRelay()
    }

    func joinSession() {
        resetTransientState(keepDrafts: true)

        let guest = trimmed(guestName)
        let code = normalizedJoinCode

        localParticipantName = guest
        isHostSession = false
        roleLabel = "Guest"
        joinCode = code
        didCopyInvite = false
        connectionStatus = "Connecting to the host…"

        session = Session(
            title: "Joining \(code)",
            sessionCode: code,
            status: .waiting,
            currentTurn: .partyA,
            currentTurnNumber: 1,
            maxTurns: selectedRounds,
            turnDuration: TimeInterval(selectedTurnDuration),
            partyAId: "pending-host",
            partyBId: localParticipantId,
            partyAName: "Host",
            partyBName: guest,
            turnStartedAt: nil
        )

        connectToRelay()
    }

    func approvePendingParticipant() {
        guard isHostSession,
              let participantId = pendingParticipantId,
              let participantName = pendingParticipantName,
              var session,
              session.status == .waiting else {
            return
        }

        session.partyBId = participantId
        session.partyBName = participantName
        session.status = .active
        session.currentTurn = .partyA
        session.currentTurnNumber = 1
        session.turnStartedAt = Date()

        self.session = session
        timeRemaining = Int(session.turnDuration)
        pendingParticipantId = nil
        pendingParticipantName = nil
        connectionStatus = "Live now"

        startTickerIfNeeded()
        broadcastCurrentSessionState()
    }

    func copyInviteLink() {
        guard let shareURL else { return }
        BrowserSupport.copyToClipboard(shareURL)
        didCopyInvite = true
    }

    func reset() {
        disconnectRelay()
        session = nil
        timeRemaining = 0
        pendingParticipantId = nil
        pendingParticipantName = nil
        shareURL = nil
        didCopyInvite = false
        roleLabel = nil
        errorMessage = nil
        connectionStatus = BrowserSupport.currentJoinCode() == nil
            ? "Ready to start"
            : "Invite detected — enter your name to join"
        isHostSession = false
        localParticipantName = ""
        joinCode = BrowserSupport.currentJoinCode() ?? ""
    }

    private var normalizedJoinCode: String {
        trimmed(joinCode).uppercased()
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func resetTransientState(keepDrafts: Bool) {
        disconnectRelay()
        errorMessage = nil
        pendingParticipantId = nil
        pendingParticipantName = nil
        didCopyInvite = false
        shareURL = nil

        if !keepDrafts {
            hostTopic = ""
            hostName = ""
            guestName = ""
        }
    }

    private func connectToRelay() {
        #if os(WASI)
        relaySocket = BrowserRelaySocket(url: relayURL)
        relaySocket?.onOpen = { [weak self] in
            guard let self else { return }
            self.connectionStatus = self.isHostSession ? "Invite ready" : "Waiting for the host"
            if !self.isHostSession {
                self.sendJoinRequest()
            }
        }
        relaySocket?.onText = { [weak self] text in
            self?.handleRelayText(text)
        }
        relaySocket?.onClose = { [weak self] in
            self?.connectionStatus = "Disconnected from relay"
        }
        relaySocket?.onError = { [weak self] message in
            self?.errorMessage = message
            self?.connectionStatus = "Relay error"
        }
        relaySocket?.connect()
        #else
        connectionStatus = "Live relay works in the web build"
        errorMessage = "Open the WebAssembly build in a browser to use live sessions."
        #endif
    }

    private func disconnectRelay() {
        #if os(WASI)
        ticker = nil
        relaySocket?.disconnect()
        relaySocket = nil
        #endif
    }

    private func sendJoinRequest() {
        guard let session else { return }

        let message = RealtimeSignalMessage(
            type: "join-request",
            sessionCode: session.sessionCode,
            userId: localParticipantId,
            userName: localParticipantName,
            snapshot: nil
        )

        sendSignal(message)
    }

    private func broadcastCurrentSessionState() {
        guard isHostSession,
              let session else { return }

        let message = RealtimeSignalMessage(
            type: "session-state",
            sessionCode: session.sessionCode,
            userId: localParticipantId,
            userName: localParticipantName,
            snapshot: SessionSnapshot(session: session, timeRemaining: timeRemaining)
        )

        sendSignal(message)
    }

    private func sendSignal(_ message: RealtimeSignalMessage) {
        guard let payload = try? JSONEncoder().encode(message),
              let payloadString = String(data: payload, encoding: .utf8) else {
            return
        }

        #if os(WASI)
        relaySocket?.sendBroadcast(payloadString)
        #endif
    }

    private func handleRelayText(_ text: String) {
        if let serverEvent = try? JSONDecoder().decode(RelayServerEnvelope.self, from: Data(text.utf8)) {
            switch serverEvent.type {
            case "register-success":
                return
            case "error":
                if let message = serverEvent.message {
                    errorMessage = message
                }
                return
            case "message":
                if let payload = serverEvent.payload {
                    handleSignalPayload(payload)
                }
                return
            default:
                break
            }
        }

        handleSignalPayload(text)
    }

    private func handleSignalPayload(_ payload: String) {
        guard let message = try? JSONDecoder().decode(RealtimeSignalMessage.self, from: Data(payload.utf8)),
              let currentCode = session?.sessionCode,
              message.sessionCode.uppercased() == currentCode.uppercased(),
              message.userId != localParticipantId else {
            return
        }

        switch message.type {
        case "join-request":
            guard isHostSession,
                  session?.status == .waiting else { return }
            pendingParticipantId = message.userId
            pendingParticipantName = message.userName ?? "Guest"
            connectionStatus = "\(pendingParticipantName ?? "Guest") is waiting"

        case "session-state":
            guard let snapshot = message.snapshot else { return }
            applyRemoteSnapshot(snapshot)

        default:
            break
        }
    }

    private func applyRemoteSnapshot(_ snapshot: SessionSnapshot) {
        guard !isHostSession else { return }
        session = snapshot.session
        timeRemaining = snapshot.timeRemaining
        shareURL = BrowserSupport.inviteURL(for: snapshot.session.sessionCode)
        if snapshot.session.status == .waiting {
            connectionStatus = "Waiting for host approval"
        } else {
            connectionStatus = snapshot.session.status.statusText
        }
    }

    private func startTickerIfNeeded() {
        #if os(WASI)
        ticker = JSTimer(millisecondsDelay: 1_000, isRepeating: true) { [weak self] in
            self?.tick()
        }
        #endif
    }

    private func tick() {
        guard isHostSession,
              var session,
              session.status == .active else {
            return
        }

        if timeRemaining > 1 {
            timeRemaining -= 1
            broadcastCurrentSessionState()
            return
        }

        if session.currentTurnNumber >= session.totalTurns {
            session.status = .completed
            timeRemaining = 0
            ticker = nil
        } else {
            session.currentTurn = session.currentTurn == .partyA ? .partyB : .partyA
            session.currentTurnNumber += 1
            session.turnStartedAt = Date()
            timeRemaining = Int(session.turnDuration)
        }

        self.session = session
        broadcastCurrentSessionState()
    }

    private func formatted(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60

        if minutes > 0 {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }

        return "\(remainingSeconds)s"
    }

    private static func generateCode(length: Int = 6) -> String {
        let characters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
}

private extension Session.SessionStatus {
    var statusText: String {
        switch self {
        case .waiting:
            return "Waiting to start"
        case .active:
            return "Live now"
        case .paused:
            return "Paused"
        case .completed:
            return "Completed"
        }
    }
}

private struct RealtimeSignalMessage: Codable {
    let type: String
    let sessionCode: String
    let userId: String
    let userName: String?
    let snapshot: SessionSnapshot?
}

private struct SessionSnapshot: Codable {
    let session: Session
    let timeRemaining: Int
}

private struct RelayBroadcastEnvelope: Codable {
    let type: String
    let to: String?
    let payload: String
}

private struct RelayServerEnvelope: Codable {
    let type: String
    let payload: String?
    let message: String?
}

#if os(WASI)
private final class BrowserRelaySocket {
    let url: String
    var onOpen: (() -> Void)?
    var onText: ((String) -> Void)?
    var onClose: (() -> Void)?
    var onError: ((String) -> Void)?

    private var socket: JSObject?
    private var onOpenClosure: JSClosure?
    private var onMessageClosure: JSClosure?
    private var onCloseClosure: JSClosure?
    private var onErrorClosure: JSClosure?

    init(url: String) {
        self.url = url
    }

    func connect() {
        guard let constructor = JSObject.global.WebSocket.function else {
            onError?("This browser does not expose WebSocket support.")
            return
        }

        let socket = constructor.new(url)
        self.socket = socket.object

        onOpenClosure = JSClosure { [weak self] _ in
            self?.onOpen?()
            return .undefined
        }
        onMessageClosure = JSClosure { [weak self] args in
            let text = args.first?.object?["data"].string ?? args.first?.string
            if let text {
                self?.onText?(text)
            }
            return .undefined
        }
        onCloseClosure = JSClosure { [weak self] _ in
            self?.onClose?()
            return .undefined
        }
        onErrorClosure = JSClosure { [weak self] _ in
            self?.onError?("Could not reach the live relay.")
            return .undefined
        }

        socket.object?["onopen"] = .object(onOpenClosure)
        socket.object?["onmessage"] = .object(onMessageClosure)
        socket.object?["onclose"] = .object(onCloseClosure)
        socket.object?["onerror"] = .object(onErrorClosure)
    }

    func sendBroadcast(_ payload: String) {
        guard let socket,
              let send = socket["send"].function,
              let data = try? JSONEncoder().encode(
                RelayBroadcastEnvelope(type: "broadcast", to: nil, payload: payload)
              ),
              let text = String(data: data, encoding: .utf8) else {
            return
        }

        _ = send(text)
    }

    func disconnect() {
        guard let socket,
              let close = socket["close"].function else {
            return
        }

        _ = close()
        self.socket = nil
    }
}
#endif