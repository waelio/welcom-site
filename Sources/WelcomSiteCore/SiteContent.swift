import Foundation
import WelcomShared

public enum SiteRoute: String, CaseIterable {
    case home
    case privacy
    case terms

    public var title: String {
        switch self {
        case .home:
            return "WelcomTalk – One Voice at a Time"
        case .privacy:
            return "Privacy Policy – WelcomTalk"
        case .terms:
            return "Terms of Use – WelcomTalk"
        }
    }

    public var fileName: String {
        switch self {
        case .home:
            return "index.html"
        case .privacy:
            return "privacy.html"
        case .terms:
            return "terms.html"
        }
    }
}

public struct FeatureCard: Identifiable, Hashable {
    public let id: String
    public let icon: String
    public let title: String
    public let body: String

    public init(icon: String, title: String, body: String) {
        self.id = title
        self.icon = icon
        self.title = title
        self.body = body
    }
}

public struct LegalSection: Identifiable, Hashable {
    public let id: String
    public let number: String
    public let title: String
    public let paragraphs: [String]
    public let bullets: [String]

    public init(number: String, title: String, paragraphs: [String], bullets: [String] = []) {
        self.id = "\(number)-\(title)"
        self.number = number
        self.title = title
        self.paragraphs = paragraphs
        self.bullets = bullets
    }
}

public struct HomePageViewModel {
    public let appName: String
    public let badge: String
    public let headline: String
    public let tagline: String
    public let architectureLine: String
    public let features: [FeatureCard]
    public let aboutParagraphs: [String]
    public let sharedSessionSummary: SessionSummaryViewModel
    public let sharedSessionNote: String
    public let parentRepositoryURL: String
    public let parentRepositoryName: String

    public init(
        appName: String,
        badge: String,
        headline: String,
        tagline: String,
        architectureLine: String,
        features: [FeatureCard],
        aboutParagraphs: [String],
        sharedSessionSummary: SessionSummaryViewModel,
        sharedSessionNote: String,
        parentRepositoryURL: String,
        parentRepositoryName: String
    ) {
        self.appName = appName
        self.badge = badge
        self.headline = headline
        self.tagline = tagline
        self.architectureLine = architectureLine
        self.features = features
        self.aboutParagraphs = aboutParagraphs
        self.sharedSessionSummary = sharedSessionSummary
        self.sharedSessionNote = sharedSessionNote
        self.parentRepositoryURL = parentRepositoryURL
        self.parentRepositoryName = parentRepositoryName
    }
}

public struct LegalPageViewModel {
    public let route: SiteRoute
    public let title: String
    public let effectiveDate: String
    public let highlight: String?
    public let sections: [LegalSection]
    public let contactName: String
    public let contactEmail: String

    public init(
        route: SiteRoute,
        title: String,
        effectiveDate: String,
        highlight: String?,
        sections: [LegalSection],
        contactName: String,
        contactEmail: String
    ) {
        self.route = route
        self.title = title
        self.effectiveDate = effectiveDate
        self.highlight = highlight
        self.sections = sections
        self.contactName = contactName
        self.contactEmail = contactEmail
    }
}

public struct WebsiteViewModel {
    public let route: SiteRoute

    public init(route: SiteRoute) {
        self.route = route
    }

    public var homePage: HomePageViewModel {
        Self.makeHomePage()
    }

    public var legalPage: LegalPageViewModel? {
        switch route {
        case .home:
            return nil
        case .privacy:
            return Self.makePrivacyPage()
        case .terms:
            return Self.makeTermsPage()
        }
    }

    private static func makeHomePage() -> HomePageViewModel {
        HomePageViewModel(
            appName: "WelcomTalk",
            badge: "SwiftWasm + Tokamak",
            headline: "One Voice at a Time",
            tagline: "A Swift-powered web companion that shares portable models with the iOS app while preserving the calm, focused feel of the original site.",
            architectureLine: "This page is driven by the same Session model and a shared summary view model exposed from the parent WelcomTalk app.",
            features: [
                FeatureCard(
                    icon: "🎙️",
                    title: "Structured Turns",
                    body: "Each party speaks for a set time without interruption — calm, focused conversation."
                ),
                FeatureCard(
                    icon: "📡",
                    title: "Peer-to-Peer",
                    body: "No internet required. Devices connect directly via Multipeer Connectivity — private by design."
                ),
                FeatureCard(
                    icon: "⏸️",
                    title: "Grace & Pause",
                    body: "A 15-second grace period before each turn. Pause anytime when you need a moment."
                ),
                FeatureCard(
                    icon: "📅",
                    title: "Schedule Together",
                    body: "Propose and confirm follow-up meetings directly in the app — added to your calendar."
                ),
                FeatureCard(
                    icon: "🔒",
                    title: "Private & Offline",
                    body: "No accounts. No servers. No data ever leaves your devices."
                ),
                FeatureCard(
                    icon: "📱",
                    title: "QR Join",
                    body: "The host creates a session; guests join by scanning a QR code. Simple and instant."
                ),
            ],
            aboutParagraphs: [
                "WelcomTalk (displayed as Safe Talk on your device) is an iOS app designed to facilitate fair, structured conversations between two people — whether resolving a dispute, having a difficult discussion, or simply ensuring both voices are heard equally.",
                "Sessions are fully local. Your iPhone communicates directly with the other person's iPhone via Apple's Multipeer Connectivity framework. No data is sent to any server, no account is needed, and nothing is stored beyond your device.",
                "Built with SwiftUI for iOS 16+ by Wael Wahbeh, and now mirrored on the web with SwiftWasm + Tokamak.",
            ],
            sharedSessionSummary: demoSessionSummary(),
            sharedSessionNote: "The snapshot below comes from a real shared Swift package dependency on the parent app, not a hand-copied web-only model.",
            parentRepositoryURL: "https://github.com/waelio/WelcomTalk",
            parentRepositoryName: "waelio/WelcomTalk"
        )
    }

    private static func makePrivacyPage() -> LegalPageViewModel {
        LegalPageViewModel(
            route: .privacy,
            title: "Privacy Policy",
            effectiveDate: "March 30, 2026",
            highlight: "WelcomTalk collects no personal data. No information ever leaves your device or is transmitted to any server.",
            sections: [
                LegalSection(
                    number: "1",
                    title: "Overview",
                    paragraphs: [
                        "WelcomTalk (Safe Talk) is an iOS application developed by Wael Wahbeh. This Privacy Policy describes how the app handles your information. Because the app is designed to operate entirely offline and peer-to-peer, there is nothing to collect, store remotely, or share."
                    ]
                ),
                LegalSection(
                    number: "2",
                    title: "Information We Do Not Collect",
                    paragraphs: [
                        "WelcomTalk does not collect, transmit, or store any of the following:"
                    ],
                    bullets: [
                        "Personal identifiers (name, email, phone number, Apple ID)",
                        "Location data",
                        "Usage analytics or crash reports sent to a remote server",
                        "Conversation content, session recordings, or transcripts on any server",
                        "Device identifiers or advertising IDs",
                        "Payment or financial information",
                    ]
                ),
                LegalSection(
                    number: "3",
                    title: "Data Stored Locally on Your Device",
                    paragraphs: [
                        "The app stores session history and notes using Apple's Core Data framework, which writes exclusively to your device's local storage. This data is:"
                    ],
                    bullets: [
                        "Never transmitted to any server",
                        "Only accessible to the app on your device",
                        "Deleted when you uninstall the app",
                    ]
                ),
                LegalSection(
                    number: "4",
                    title: "Camera Access",
                    paragraphs: [
                        "The app requests camera access solely to scan QR codes for joining a session. No images or video are captured, stored, or transmitted."
                    ]
                ),
                LegalSection(
                    number: "5",
                    title: "Microphone and Speech Recognition",
                    paragraphs: [
                        "If speech recognition is enabled (optional feature), the app uses Apple's on-device Speech framework to transcribe your speaking turn. Audio is processed locally on your device. No audio or transcription data is sent to any external server by WelcomTalk.",
                        "Apple's Speech framework may route audio to Apple's servers depending on iOS settings. Please refer to Apple's Privacy Policy at https://www.apple.com/legal/privacy/ for details on their data practices."
                    ]
                ),
                LegalSection(
                    number: "6",
                    title: "Peer-to-Peer Communication (Multipeer Connectivity)",
                    paragraphs: [
                        "Session synchronization between devices uses Apple's Multipeer Connectivity framework (Bluetooth and local Wi-Fi). Communication is direct device-to-device — no data passes through any server operated by us or any third party."
                    ]
                ),
                LegalSection(
                    number: "7",
                    title: "Calendar Access",
                    paragraphs: [
                        "If you choose to schedule a follow-up session, the app requests write-only access to add an event to your calendar. No calendar data is read by the app or transmitted anywhere."
                    ]
                ),
                LegalSection(
                    number: "8",
                    title: "Third-Party Services",
                    paragraphs: [
                        "WelcomTalk does not integrate with any third-party analytics, advertising, or data platforms. No third-party SDKs that collect data are included in the app."
                    ]
                ),
                LegalSection(
                    number: "9",
                    title: "Children's Privacy",
                    paragraphs: [
                        "The app is not directed to children under 13 and does not knowingly collect information from children. Because no data is collected by the app, there is no risk of inadvertent collection."
                    ]
                ),
                LegalSection(
                    number: "10",
                    title: "Changes to This Policy",
                    paragraphs: [
                        "If this policy changes materially, an updated version will be posted at this URL with a revised effective date."
                    ]
                ),
                LegalSection(
                    number: "11",
                    title: "Contact",
                    paragraphs: [
                        "Questions about this privacy policy may be directed to the contact below."
                    ]
                ),
            ],
            contactName: "Wael Wahbeh",
            contactEmail: "wahbehw@me.com"
        )
    }

    private static func makeTermsPage() -> LegalPageViewModel {
        LegalPageViewModel(
            route: .terms,
            title: "Terms of Use",
            effectiveDate: "March 30, 2026",
            highlight: nil,
            sections: [
                LegalSection(
                    number: "1",
                    title: "Acceptance",
                    paragraphs: [
                        "By downloading, installing, or using WelcomTalk (Safe Talk, the App), you agree to be bound by these Terms of Use. If you do not agree, do not use the App."
                    ]
                ),
                LegalSection(
                    number: "2",
                    title: "License",
                    paragraphs: [
                        "Wael Wahbeh grants you a personal, non-exclusive, non-transferable, revocable license to use the App on any Apple-branded device you own or control, subject to the Usage Rules set forth in Apple's App Store Terms of Service."
                    ]
                ),
                LegalSection(
                    number: "3",
                    title: "Permitted Use",
                    paragraphs: [
                        "The App is intended to facilitate voluntary, structured, face-to-face or near-proximity conversations between consenting adults. You agree to use the App only for lawful purposes and in a manner consistent with its intended design."
                    ]
                ),
                LegalSection(
                    number: "4",
                    title: "Prohibited Use",
                    paragraphs: [
                        "You must not use the App to:"
                    ],
                    bullets: [
                        "Record, capture, or transmit another person's voice without their knowledge and consent",
                        "Harass, threaten, or intimidate any person",
                        "Violate any applicable local, national, or international law or regulation",
                        "Attempt to reverse-engineer, decompile, or modify the App in any unauthorized way",
                    ]
                ),
                LegalSection(
                    number: "5",
                    title: "Intellectual Property",
                    paragraphs: [
                        "All content, design, code, and trademarks in the App are the property of Wael Wahbeh. Nothing in these Terms grants you any right to use the App's name, logos, or trademarks without prior written permission."
                    ]
                ),
                LegalSection(
                    number: "6",
                    title: "No Warranty",
                    paragraphs: [
                        "The App is provided as is and as available without warranties of any kind, express or implied, including but not limited to merchantability, fitness for a particular purpose, or non-infringement. Wael Wahbeh does not warrant that the App will be uninterrupted, error-free, or suitable for any specific purpose."
                    ]
                ),
                LegalSection(
                    number: "7",
                    title: "Limitation of Liability",
                    paragraphs: [
                        "To the fullest extent permitted by law, Wael Wahbeh shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of or inability to use the App, even if advised of the possibility of such damages. The total liability in any matter related to the App is limited to the amount you paid for the App (if any)."
                    ]
                ),
                LegalSection(
                    number: "8",
                    title: "Third-Party Frameworks",
                    paragraphs: [
                        "The App uses Apple platform frameworks (Multipeer Connectivity, Speech, EventKit, Core Data). Your use of those frameworks is additionally subject to Apple's terms and policies."
                    ]
                ),
                LegalSection(
                    number: "9",
                    title: "Disclaimer on Sensitive Conversations",
                    paragraphs: [
                        "WelcomTalk is a communication tool only. It is not a substitute for professional legal, psychological, or mediation services. For disputes involving legal rights, domestic safety, or mental health, please consult qualified professionals."
                    ]
                ),
                LegalSection(
                    number: "10",
                    title: "Governing Law",
                    paragraphs: [
                        "These Terms are governed by the laws of the State of California, United States, without regard to conflict of law principles."
                    ]
                ),
                LegalSection(
                    number: "11",
                    title: "Changes to These Terms",
                    paragraphs: [
                        "We reserve the right to update these Terms at any time. An updated version will be posted at this URL with a revised effective date. Continued use of the App after changes constitutes acceptance of the new Terms."
                    ]
                ),
                LegalSection(
                    number: "12",
                    title: "Contact",
                    paragraphs: [
                        "Questions about these Terms may be directed to the contact below."
                    ]
                ),
            ],
            contactName: "Wael Wahbeh",
            contactEmail: "wahbehw@me.com"
        )
    }

    private static func demoSessionSummary() -> SessionSummaryViewModel {
        let session = Session(
            title: "Finding More Time Together",
            sessionCode: "DEMO42",
            status: .active,
            currentTurn: .partyB,
            currentTurnNumber: 4,
            maxTurns: 2,
            turnDuration: 45,
            partyAId: "alex-demo",
            partyBId: "sam-demo",
            partyAName: "Alex",
            partyBName: "Sam",
            turnStartedAt: Date()
        )

        return SessionSummaryViewModel(session: session)
    }
}
