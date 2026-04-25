import Foundation
import TokamakShim
import WelcomShared
import WelcomSiteCore

private enum SitePalette {
    static let background = Color(red: 10 / 255, green: 22 / 255, blue: 40 / 255)
    static let heroStart = Color(red: 13 / 255, green: 31 / 255, blue: 60 / 255)
    static let heroEnd = Color(red: 26 / 255, green: 53 / 255, blue: 96 / 255)
    static let card = Color.white.opacity(0.05)
    static let cardStrong = Color.white.opacity(0.07)
    static let border = Color.white.opacity(0.10)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 168 / 255, green: 184 / 255, blue: 216 / 255)
    static let accent = Color(red: 201 / 255, green: 168 / 255, blue: 76 / 255)
    static let accentMuted = Color(red: 216 / 255, green: 200 / 255, blue: 144 / 255)
}

struct WebsiteRootView: View {
    let viewModel: WebsiteViewModel

    var body: some View {
        ZStack {
            SitePalette.background

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    switch viewModel.route {
                    case .home:
                        HomePageView(viewModel: viewModel.homePage)
                    case .privacy, .terms:
                        if let page = viewModel.legalPage {
                            LegalPageView(viewModel: page)
                        }
                    }

                    FooterView(activeRoute: viewModel.route)
                }
                .frame(maxWidth: 960, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
        .foregroundColor(SitePalette.textPrimary)
        .onAppear {
            BrowserSupport.markAppReady()
        }
    }
}

struct HomePageView: View {
    let viewModel: HomePageViewModel
    @StateObject private var requestStore = RequestJSONStore()
    @StateObject private var sessionStore = SmartSessionStore()

    private let featureColumns = [
        GridItem(.adaptive(minimum: 220), spacing: 16),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 18) {
                Text(viewModel.badge)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(SitePalette.heroStart)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(SitePalette.accent)
                    .cornerRadius(999)

                Text(viewModel.appName)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)

                Text(viewModel.appCaption.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(SitePalette.accentMuted)

                Text(viewModel.headline)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(SitePalette.accent)

                Text(viewModel.tagline)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(SitePalette.textSecondary)

                Text(viewModel.architectureLine)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SitePalette.accentMuted)

                VStack(alignment: .leading, spacing: 12) {
                    FilledActionButton(title: "Contact") {
                        BrowserSupport.open("mailto:\(viewModel.contactEmail)")
                    }

                    FilledActionButton(title: "Privacy Policy") {
                        BrowserSupport.navigate(to: .privacy)
                    }

                    OutlineActionButton(title: "Terms of Use") {
                        BrowserSupport.navigate(to: .terms)
                    }

                    OutlineActionButton(title: "View Parent App") {
                        BrowserSupport.open(viewModel.parentRepositoryURL)
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [SitePalette.heroStart, SitePalette.heroEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(SitePalette.accent.opacity(0.25), lineWidth: 1)
            )
            .cornerRadius(24)

            VStack(alignment: .leading, spacing: 16) {
                SectionHeading(title: "Introducing the concept")

                VStack(alignment: .leading, spacing: 14) {
                    ForEach(viewModel.marketParagraphs, id: \.self) { paragraph in
                        Text(paragraph)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(SitePalette.textSecondary)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SitePalette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(SitePalette.border, lineWidth: 1)
                )
                .cornerRadius(20)
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionHeading(title: "How it works")

                VStack(alignment: .leading, spacing: 14) {
                    ForEach(viewModel.processSteps) { step in
                        ProcessStepCardView(step: step)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionHeading(title: "Create request JSON")

                RequestJSONBuilderView(requestStore: requestStore)
            }

            SessionCalloutBox(
                heading: "Fair by design",
                detail: "WelcomTalk Portal starts with a structured request, then stays neutral in live sessions: one person speaks at a time, everyone gets equal timed turns by default, and every participant has space to present their side.",
                accentColor: SitePalette.accent
            )

            VStack(alignment: .leading, spacing: 16) {
                SectionHeading(title: "Live portal session beta")

                SmartSessionWorkbenchView(sessionStore: sessionStore)
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionHeading(title: "Who it's for")

                LazyVGrid(columns: featureColumns, spacing: 16) {
                    ForEach(viewModel.audienceCards) { audience in
                        FeatureCardView(feature: audience)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionHeading(title: "Why it works")

                LazyVGrid(columns: featureColumns, spacing: 16) {
                    ForEach(viewModel.features) { feature in
                        FeatureCardView(feature: feature)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionHeading(title: "Shared session snapshot")

                SessionSnapshotCard(
                    summary: viewModel.sharedSessionSummary,
                    note: viewModel.sharedSessionNote,
                    repositoryName: viewModel.parentRepositoryName,
                    repositoryURL: viewModel.parentRepositoryURL
                )
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionHeading(title: "About Us")

                VStack(alignment: .leading, spacing: 14) {
                    ForEach(viewModel.aboutParagraphs, id: \.self) { paragraph in
                        Text(paragraph)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(SitePalette.textSecondary)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SitePalette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(SitePalette.border, lineWidth: 1)
                )
                .cornerRadius(20)
            }

            VStack(alignment: .leading, spacing: 16) {
                SectionHeading(title: "Contact")

                ContactCardView(
                    paragraphs: viewModel.contactParagraphs,
                    email: viewModel.contactEmail
                )
            }
        }
    }
}

struct RequestJSONBuilderView: View {
    @ObservedObject var requestStore: RequestJSONStore

    var body: some View {
        SmartCardShell(
            title: "Portal request form",
            subtitle: "This is the Portal flow inside WelcomTalk where a user fills in the request and creates the JSON case record."
        ) {
            VStack(alignment: .leading, spacing: 14) {
                StyledTextInput(title: "Full name", text: $requestStore.fullName)
                StyledTextInput(title: "Topic", text: $requestStore.topic)
                StyledTextInput(title: "Request summary", text: $requestStore.summary)
                StyledTextInput(title: "Supporting document names (comma separated)", text: $requestStore.supportingDocumentNamesLine)
                StyledTextInput(title: "Additional notes", text: $requestStore.additionalNotes)

                RequestConsentRow(isSelected: $requestStore.hasConsent)

                SessionCalloutBox(
                    heading: "Form note",
                    detail: "The Portal preview currently lists supporting documents by name inside the generated JSON. Real upload and storage wiring can be connected later without changing the request structure.",
                    accentColor: SitePalette.accentMuted
                )

                HStack(spacing: 12) {
                    WideActionButton(
                        title: "Generate JSON",
                        style: .filled,
                        isDisabled: !requestStore.canGenerate,
                        action: requestStore.generateJSON
                    )

                    WideActionButton(
                        title: "Copy JSON",
                        style: .outline,
                        isDisabled: requestStore.generatedJSON.isEmpty,
                        action: requestStore.copyJSON
                    )
                }

                if let statusMessage = requestStore.statusMessage {
                    HStack(spacing: 10) {
                        Text(statusMessage)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(SitePalette.textSecondary)

                        if requestStore.didCopyJSON {
                            StatusPill(title: "Copied", isAccent: false)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("JSON preview")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(SitePalette.accentMuted)

                    ScrollView {
                        Text(requestStore.generatedJSONPlaceholderOrValue)
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                    }
                    .frame(minHeight: 220)
                    .background(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(SitePalette.border.opacity(0.7), lineWidth: 1)
                    )
                    .cornerRadius(14)
                }
            }
        }
    }
}

struct LegalPageView: View {
    let viewModel: LegalPageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            OutlineActionButton(title: "← Back to WelcomTalk") {
                BrowserSupport.navigate(to: .home)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)

                Text("Effective: \(viewModel.effectiveDate)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(SitePalette.textSecondary)
            }

            if let highlight = viewModel.highlight {
                VStack(alignment: .leading, spacing: 0) {
                    Text(highlight)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(SitePalette.accentMuted)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SitePalette.accent.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(SitePalette.accent.opacity(0.35), lineWidth: 1)
                )
                .cornerRadius(18)
            }

            ForEach(viewModel.sections) { section in
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(section.number). \(section.title)")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundColor(SitePalette.accent)

                    ForEach(section.paragraphs, id: \.self) { paragraph in
                        Text(paragraph)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(SitePalette.textSecondary)
                    }

                    if !section.bullets.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(section.bullets, id: \.self) { bullet in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("•")
                                        .foregroundColor(SitePalette.accent)
                                    Text(bullet)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(SitePalette.textSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SitePalette.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(SitePalette.border, lineWidth: 1)
                )
                .cornerRadius(20)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Contact")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text(viewModel.contactName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(SitePalette.textSecondary)
                Text(viewModel.contactEmail)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(SitePalette.accent)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SitePalette.cardStrong)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(SitePalette.border, lineWidth: 1)
            )
            .cornerRadius(20)
        }
    }
}

struct FooterView: View {
    let activeRoute: SiteRoute

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
                .overlay(SitePalette.border)

            VStack(alignment: .leading, spacing: 12) {
                Text("© 2026 Wael Wahbeh. WelcomTalk Portal experience powered by SwiftWasm + Tokamak.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(SitePalette.textSecondary)

                HStack(spacing: 10) {
                    FooterLinkButton(title: "Home", isActive: activeRoute == .home) {
                        BrowserSupport.navigate(to: .home)
                    }
                    FooterLinkButton(title: "Privacy Policy", isActive: activeRoute == .privacy) {
                        BrowserSupport.navigate(to: .privacy)
                    }
                    FooterLinkButton(title: "Terms of Use", isActive: activeRoute == .terms) {
                        BrowserSupport.navigate(to: .terms)
                    }
                    FooterLinkButton(title: "GitHub") {
                        BrowserSupport.open("https://github.com/waelio/WelcomTalk")
                    }
                }
            }
        }
    }
}

struct SectionHeading: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(SitePalette.accent)
    }
}

struct FeatureCardView: View {
    let feature: FeatureCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(feature.icon)
                .font(.system(size: 30))

            Text(feature.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Text(feature.body)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(SitePalette.textSecondary)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SitePalette.card)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(SitePalette.border, lineWidth: 1)
        )
        .cornerRadius(18)
    }
}

struct ProcessStepCardView: View {
    let step: ProcessStep

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(step.stepLabel.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(SitePalette.accentMuted)

            Text(step.title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)

            Text(step.body)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(SitePalette.textSecondary)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SitePalette.cardStrong)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(SitePalette.border, lineWidth: 1)
        )
        .cornerRadius(18)
    }
}

struct ContactCardView: View {
    let paragraphs: [String]
    let email: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(paragraphs, id: \.self) { paragraph in
                Text(paragraph)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(SitePalette.textSecondary)
            }

            OutlineActionButton(title: email) {
                BrowserSupport.open("mailto:\(email)")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SitePalette.card)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(SitePalette.border, lineWidth: 1)
        )
        .cornerRadius(20)
    }
}

struct SessionSnapshotCard: View {
    let summary: SessionSummaryViewModel
    let note: String
    let repositoryName: String
    let repositoryURL: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(summary.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            Text(note)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(SitePalette.textSecondary)

            VStack(alignment: .leading, spacing: 12) {
                SnapshotMetricRow(label: "Status", value: summary.statusText)
                SnapshotMetricRow(label: "Current speaker", value: "\(summary.currentSpeakerName) (\(summary.currentSpeakerRole))")
                SnapshotMetricRow(label: "Fairness", value: summary.fairnessLine)
                SnapshotMetricRow(label: "Turn progress", value: summary.turnProgressText)
                SnapshotMetricRow(label: "Turn duration", value: summary.turnDurationText)
                SnapshotMetricRow(label: "Participants", value: summary.participantsLine)
                SnapshotMetricRow(label: "Session code", value: summary.sessionCode)
                SnapshotMetricRow(label: "Rounds", value: summary.totalRoundsText)
            }

            OutlineActionButton(title: "Open \(repositoryName)") {
                BrowserSupport.open(repositoryURL)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SitePalette.cardStrong)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(SitePalette.border, lineWidth: 1)
        )
        .cornerRadius(20)
    }
}

struct SmartSessionWorkbenchView: View {
    @ObservedObject var sessionStore: SmartSessionStore

    private let roundOptions = [2, 4, 6]
    private let durationOptions = [30, 45, 60]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(sessionStore.betaNotice)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(SitePalette.textSecondary)

            SessionCalloutBox(
                heading: "Current portal scope",
                detail: "Today's WelcomTalk Portal beta supports one host and one guest with equal timed turns. The wider product idea stays flexible so the format can grow over time.",
                accentColor: SitePalette.accentMuted
            )

            if let error = sessionStore.errorMessage {
                SessionCalloutBox(
                    heading: "Connection note",
                    detail: error,
                    accentColor: Color(red: 228 / 255, green: 107 / 255, blue: 99 / 255)
                )
            }

            if sessionStore.session == nil {
                VStack(alignment: .leading, spacing: 16) {
                    SmartCardShell(title: "Host a live session", subtitle: "Start on one browser, then share the invite link or the six-character code. The current beta uses equal timed turns for one host and one guest.") {
                        VStack(alignment: .leading, spacing: 12) {
                            StyledTextInput(title: "Conversation topic", text: $sessionStore.hostTopic)
                            StyledTextInput(title: "Your name", text: $sessionStore.hostName)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Equal rounds per participant")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(SitePalette.accentMuted)

                                HStack(spacing: 10) {
                                    ForEach(roundOptions, id: \.self) { rounds in
                                        SelectionChip(
                                            title: "\(rounds)",
                                            isSelected: sessionStore.selectedRounds == rounds
                                        ) {
                                            sessionStore.selectedRounds = rounds
                                        }
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Equal seconds per turn")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(SitePalette.accentMuted)

                                HStack(spacing: 10) {
                                    ForEach(durationOptions, id: \.self) { seconds in
                                        SelectionChip(
                                            title: "\(seconds)s",
                                            isSelected: sessionStore.selectedTurnDuration == seconds
                                        ) {
                                            sessionStore.selectedTurnDuration = seconds
                                        }
                                    }
                                }
                            }

                            WideActionButton(
                                title: "Start live session",
                                style: .filled,
                                isDisabled: !sessionStore.canCreateSession,
                                action: sessionStore.createSession
                            )
                        }
                    }

                    SmartCardShell(title: "Join from another browser", subtitle: "Open the invite link or paste the code from the host.") {
                        VStack(alignment: .leading, spacing: 12) {
                            StyledTextInput(title: "Your name", text: $sessionStore.guestName)
                            StyledTextInput(title: "Session code", text: $sessionStore.joinCode)

                            WideActionButton(
                                title: "Join session",
                                style: .outline,
                                isDisabled: !sessionStore.canJoinSession,
                                action: sessionStore.joinSession
                            )
                        }
                    }
                }
            } else {
                SmartCardShell(
                    title: sessionStore.sessionSummary?.title ?? "Live session",
                    subtitle: sessionStore.roleLabel.map { "\($0) view" } ?? "Session preview"
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            StatusPill(title: sessionStore.connectionStatus, isAccent: true)

                            if let roleLabel = sessionStore.roleLabel {
                                StatusPill(title: roleLabel, isAccent: false)
                            }

                            if sessionStore.didCopyInvite {
                                StatusPill(title: "Invite copied", isAccent: false)
                            }
                        }

                        Text(sessionStore.countdownText)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(SitePalette.textSecondary)

                        if let summary = sessionStore.sessionSummary {
                            VStack(alignment: .leading, spacing: 12) {
                                SnapshotMetricRow(label: "Status", value: summary.statusText)
                                SnapshotMetricRow(label: "Current speaker", value: "\(summary.currentSpeakerName) (\(summary.currentSpeakerRole))")
                                SnapshotMetricRow(label: "Fairness", value: summary.fairnessLine)
                                SnapshotMetricRow(label: "Turn progress", value: summary.turnProgressText)
                                SnapshotMetricRow(label: "Time remaining", value: sessionStore.countdownText)
                                SnapshotMetricRow(label: "Participants", value: summary.participantsLine)
                                SnapshotMetricRow(label: "Session code", value: summary.sessionCode)
                            }
                        }

                        if let shareURL = sessionStore.shareURL {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Invite link")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(SitePalette.accentMuted)

                                Text(shareURL)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white.opacity(0.03))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(SitePalette.border.opacity(0.7), lineWidth: 1)
                                    )
                                    .cornerRadius(14)
                            }
                        }

                        if let pendingName = sessionStore.pendingParticipantName,
                           sessionStore.hasPendingParticipant {
                            SessionCalloutBox(
                                heading: "Guest waiting",
                                detail: "\(pendingName) wants to join this session. Tap below when you're ready to start.",
                                accentColor: SitePalette.accent
                            )

                            WideActionButton(
                                title: "Let \(pendingName) in",
                                style: .filled,
                                isDisabled: false,
                                action: sessionStore.approvePendingParticipant
                            )
                        }

                        HStack(spacing: 12) {
                            if sessionStore.shareURL != nil {
                                WideActionButton(
                                    title: "Copy invite link",
                                    style: .outline,
                                    isDisabled: false,
                                    action: sessionStore.copyInviteLink
                                )
                            }

                            WideActionButton(
                                title: "Reset",
                                style: .outline,
                                isDisabled: false,
                                action: sessionStore.reset
                            )
                        }
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SitePalette.cardStrong)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(SitePalette.border, lineWidth: 1)
        )
        .cornerRadius(20)
    }
}

struct SmartCardShell<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(SitePalette.textSecondary)

            content
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.03))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(SitePalette.border.opacity(0.8), lineWidth: 1)
        )
        .cornerRadius(18)
    }
}

struct StyledTextInput: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(SitePalette.accentMuted)

            TextField(title, text: $text)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(SitePalette.border, lineWidth: 1)
                )
                .cornerRadius(14)
        }
    }
}

struct RequestConsentRow: View {
    @Binding var isSelected: Bool

    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? SitePalette.accent : SitePalette.textSecondary)
                    .font(.system(size: 18, weight: .semibold))

                Text("I agree to submit this information for review and generate the JSON record in WelcomTalk Portal.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(Color.white.opacity(0.03))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(SitePalette.border.opacity(0.7), lineWidth: 1)
            )
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}

struct SelectionChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? SitePalette.heroStart : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isSelected ? SitePalette.accent : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? SitePalette.accent : SitePalette.border, lineWidth: 1)
                )
                .cornerRadius(12)
        }
    }
}

struct SessionCalloutBox: View {
    let heading: String
    let detail: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(heading.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(accentColor)

            Text(detail)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(SitePalette.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accentColor.opacity(0.10))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(accentColor.opacity(0.35), lineWidth: 1)
        )
        .cornerRadius(14)
    }
}

struct StatusPill: View {
    let title: String
    let isAccent: Bool

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(isAccent ? SitePalette.heroStart : .white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isAccent ? SitePalette.accent : Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 999)
                    .stroke(isAccent ? SitePalette.accent : SitePalette.border, lineWidth: 1)
            )
            .cornerRadius(999)
    }
}

struct WideActionButton: View {
    enum Style {
        case filled
        case outline
    }

    let title: String
    let style: Style
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(style == .filled ? SitePalette.heroStart : .white)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(borderColor, lineWidth: 1)
                )
                .cornerRadius(14)
                .opacity(isDisabled ? 0.45 : 1)
        }
        .disabled(isDisabled)
    }

    private var backgroundColor: Color {
        switch style {
        case .filled:
            return SitePalette.accent
        case .outline:
            return Color.white.opacity(0.05)
        }
    }

    private var borderColor: Color {
        switch style {
        case .filled:
            return SitePalette.accent
        case .outline:
            return SitePalette.border
        }
    }
}

struct SnapshotMetricRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(SitePalette.accentMuted)

            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.03))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(SitePalette.border.opacity(0.7), lineWidth: 1)
        )
        .cornerRadius(14)
    }
}

struct FilledActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(SitePalette.heroStart)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(SitePalette.accent)
                .cornerRadius(14)
        }
    }
}

struct OutlineActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(SitePalette.border, lineWidth: 1)
                )
                .cornerRadius(14)
        }
    }
}

struct FooterLinkButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    init(title: String, isActive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isActive = isActive
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isActive ? SitePalette.heroStart : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(isActive ? SitePalette.accent : Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? SitePalette.accent : SitePalette.border, lineWidth: 1)
                )
                .cornerRadius(12)
        }
    }
}

final class RequestJSONStore: ObservableObject {
    @Published var fullName: String = ""
    @Published var topic: String = ""
    @Published var summary: String = ""
    @Published var supportingDocumentNamesLine: String = ""
    @Published var additionalNotes: String = ""
    @Published var hasConsent: Bool = false
    @Published private(set) var generatedJSON: String = ""
    @Published private(set) var statusMessage: String? = "Fill in the request details and consent to generate the JSON record in WelcomTalk Portal."
    @Published private(set) var didCopyJSON = false

    var canGenerate: Bool {
        draft.canGenerate
    }

    var generatedJSONPlaceholderOrValue: String {
        if generatedJSON.isEmpty {
            return "JSON preview appears here after you generate the request record."
        }

        return generatedJSON
    }

    private var draft: RequestFormDraft {
        RequestFormDraft(
            fullName: fullName,
            topic: topic,
            summary: summary,
            supportingDocumentNamesLine: supportingDocumentNamesLine,
            additionalNotes: additionalNotes,
            hasConsent: hasConsent
        )
    }

    func generateJSON() {
        guard let json = draft.generatedJSONPreview() else {
            statusMessage = "Fill in full name, topic, request summary, and consent before generating JSON."
            generatedJSON = ""
            didCopyJSON = false
            return
        }

        generatedJSON = json
        statusMessage = "JSON generated locally in WelcomTalk Portal."
        didCopyJSON = false
    }

    func copyJSON() {
        guard !generatedJSON.isEmpty else {
            statusMessage = "Generate the JSON first, then copy it."
            didCopyJSON = false
            return
        }

        BrowserSupport.copyToClipboard(generatedJSON)
        statusMessage = "JSON copied to the clipboard."
        didCopyJSON = true
    }
}
