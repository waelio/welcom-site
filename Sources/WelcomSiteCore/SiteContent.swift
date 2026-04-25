import Foundation
import WelcomShared

public enum SiteRoute: String, CaseIterable {
    case home
    case privacy
    case terms

    public var title: String {
        switch self {
        case .home:
            return "WelcomTalk Portal – Request JSON Builder"
        case .privacy:
            return "Privacy Policy – WelcomTalk Portal"
        case .terms:
            return "Terms of Use – WelcomTalk Portal"
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

public struct ProcessStep: Identifiable, Hashable {
    public let id: String
    public let stepLabel: String
    public let title: String
    public let body: String

    public init(stepLabel: String, title: String, body: String) {
        self.id = "\(stepLabel)-\(title)"
        self.stepLabel = stepLabel
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
    public let appCaption: String
    public let badge: String
    public let headline: String
    public let tagline: String
    public let architectureLine: String
    public let marketParagraphs: [String]
    public let processSteps: [ProcessStep]
    public let audienceCards: [FeatureCard]
    public let features: [FeatureCard]
    public let aboutParagraphs: [String]
    public let contactParagraphs: [String]
    public let contactEmail: String
    public let sharedSessionSummary: SessionSummaryViewModel
    public let sharedSessionNote: String
    public let parentRepositoryURL: String
    public let parentRepositoryName: String

    public init(
        appName: String,
        appCaption: String,
        badge: String,
        headline: String,
        tagline: String,
        architectureLine: String,
        marketParagraphs: [String],
        processSteps: [ProcessStep],
        audienceCards: [FeatureCard],
        features: [FeatureCard],
        aboutParagraphs: [String],
        contactParagraphs: [String],
        contactEmail: String,
        sharedSessionSummary: SessionSummaryViewModel,
        sharedSessionNote: String,
        parentRepositoryURL: String,
        parentRepositoryName: String
    ) {
        self.appName = appName
        self.appCaption = appCaption
        self.badge = badge
        self.headline = headline
        self.tagline = tagline
        self.architectureLine = architectureLine
        self.marketParagraphs = marketParagraphs
        self.processSteps = processSteps
        self.audienceCards = audienceCards
        self.features = features
        self.aboutParagraphs = aboutParagraphs
        self.contactParagraphs = contactParagraphs
        self.contactEmail = contactEmail
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
            appCaption: "Portal",
            badge: "Introducing a new category",
            headline: "A fairness-first way to prepare difficult conversations.",
            tagline: "WelcomTalk Portal introduces a new market concept: start with a structured request, then move into equal-turn live dialogue only when both sides are ready.",
            architectureLine: "Lead with the story, show the process, and let people try the structured request flow before the live beta begins.",
            marketParagraphs: [
                "WelcomTalk Portal is not just another chat tool. It is a guided entry point for difficult conversations — a place to slow the moment down, capture the issue clearly, and create a fairer starting point.",
                "That matters because this is a new concept entering the market: structure first, then dialogue. Instead of sending people straight into a tense exchange, WelcomTalk Portal helps them arrive with context, clarity, and equal time in mind.",
            ],
            processSteps: [
                ProcessStep(
                    stepLabel: "Step 01",
                    title: "Capture the request",
                    body: "The user explains the issue, the people involved, and the desired outcome in one structured place."
                ),
                ProcessStep(
                    stepLabel: "Step 02",
                    title: "Generate the case record",
                    body: "WelcomTalk Portal turns the intake into a clean JSON record that can support product workflows, human review, or app handoff later."
                ),
                ProcessStep(
                    stepLabel: "Step 03",
                    title: "Invite the other side",
                    body: "Once the request is clear, the conversation can move forward with context already established instead of starting in confusion."
                ),
                ProcessStep(
                    stepLabel: "Step 04",
                    title: "Run an equal-turn session",
                    body: "When a live discussion happens, everyone gets clear speaking order, equal time, and a neutral framework for follow-up."
                ),
            ],
            audienceCards: [
                FeatureCard(
                    icon: "👤",
                    title: "Individuals",
                    body: "Use WelcomTalk Portal to turn a stressful situation into a structured request before a live conversation begins."
                ),
                FeatureCard(
                    icon: "🤝",
                    title: "Couples & Families",
                    body: "Create a calmer starting point for emotionally charged conversations by organizing context before anyone starts talking over each other."
                ),
                FeatureCard(
                    icon: "🏢",
                    title: "Teams & Organizations",
                    body: "Apply a fairness-first process to internal disputes, feedback loops, or moderated conversations that need more structure."
                ),
                FeatureCard(
                    icon: "🎥",
                    title: "Moderators & Studios",
                    body: "Grow the concept into richer facilitated discussions, studio formats, or creator-led conversations over time."
                ),
            ],
            features: [
                FeatureCard(
                    icon: "🧾",
                    title: "Request JSON Builder",
                    body: "Fill in the request in WelcomTalk Portal and generate a structured JSON record that can later feed the app or a backend workflow."
                ),
                FeatureCard(
                    icon: "⚖️",
                    title: "Equal Time",
                    body: "When a live session happens, each participant gets the same timed speaking window by default."
                ),
                FeatureCard(
                    icon: "🧭",
                    title: "Neutral Structure",
                    body: "WelcomTalk Portal does not decide who is right. It gives people a clear structure to present their side and respond."
                ),
                FeatureCard(
                    icon: "🌐",
                    title: "Live Browser Beta",
                    body: "After the request record is created, today's web beta can host one equal-turn session with a host and one guest."
                ),
                FeatureCard(
                    icon: "🎬",
                    title: "Individuals to Studios",
                    body: "The concept starts with individual request intake today and can grow into richer moderated discussions and studio-style formats later."
                ),
                FeatureCard(
                    icon: "🔒",
                    title: "Private by Design",
                    body: "WelcomTalk Portal can prepare the structured JSON record, while the iPhone app remains the most private path for sensitive live conversations."
                ),
            ],
            aboutParagraphs: [
                "WelcomTalk is being built by Wael Wahbeh as a new fairness-first product for introducing, preparing, and eventually hosting difficult conversations.",
                "The goal is simple: reduce chaos at the beginning of a tense interaction by giving people a neutral structure before the live moment starts.",
                "The iPhone app remains the most private path for live sessions, while WelcomTalk Portal serves as the public front door for explaining the concept, collecting the structured request, and inviting early adopters into the experience.",
            ],
            contactParagraphs: [
                "If you want to talk about partnerships, pilot programs, feedback, or early access, reach out.",
                "WelcomTalk Portal is early, and thoughtful feedback from real users, mediators, creators, and teams can help shape where it goes next.",
            ],
            contactEmail: "wahbehw@me.com",
            sharedSessionSummary: demoSessionSummary(),
            sharedSessionNote: "The snapshot below shows the shared equal-turn session model that can be used after the WelcomTalk Portal request JSON has done its job.",
            parentRepositoryURL: "https://github.com/waelio/WelcomTalk",
            parentRepositoryName: "iPhone app repo"
        )
    }

    private static func makePrivacyPage() -> LegalPageViewModel {
        LegalPageViewModel(
            route: .privacy,
            title: "Privacy Policy",
            effectiveDate: "March 30, 2026",
            highlight: "The iPhone app remains local and peer-to-peer. The WelcomTalk Portal beta may relay active session state through a lightweight server so two browsers can sync in real time.",
            sections: [
                LegalSection(
                    number: "1",
                    title: "Overview",
                    paragraphs: [
                        "WelcomTalk Portal is an iOS and web experience developed by Wael Wahbeh. This Privacy Policy describes how the iPhone app and the current WelcomTalk Portal experience handle your information.",
                        "The iPhone app is designed to operate offline and peer-to-peer. The WelcomTalk Portal beta can host and join live browser sessions and may use a lightweight relay to synchronize the active session between browsers."
                    ]
                ),
                LegalSection(
                    number: "2",
                    title: "Information We Do Not Collect",
                    paragraphs: [
                        "WelcomTalk Portal does not collect, transmit, or store any of the following:"
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
                        "The iPhone app stores session history and notes using Apple's Core Data framework, which writes exclusively to your device's local storage. This data is:",
                        "The current WelcomTalk Portal beta keeps the active session in browser memory while the page is open and does not require an account."
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
                        "If speech recognition is enabled (optional feature), the app uses Apple's on-device Speech framework to transcribe your speaking turn. Audio is processed locally on your device. No audio or transcription data is sent to any external server by the iPhone app or WelcomTalk Portal.",
                        "Apple's Speech framework may route audio to Apple's servers depending on iOS settings. Please refer to Apple's Privacy Policy at https://www.apple.com/legal/privacy/ for details on their data practices."
                    ]
                ),
                LegalSection(
                    number: "6",
                    title: "Real-Time Communication",
                    paragraphs: [
                        "On iPhone, session synchronization between devices uses Apple's Multipeer Connectivity framework (Bluetooth and local Wi-Fi). Communication is direct device-to-device — no data passes through any server operated by us or any third party.",
                        "On the WelcomTalk Portal beta, active session state may be relayed through a lightweight WebSocket service so two browsers can stay in sync. If your conversation is highly sensitive, use the iPhone app instead of the current WelcomTalk Portal beta."
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
                        "WelcomTalk Portal does not integrate with analytics, advertising, or profiling SDKs. The WelcomTalk Portal beta may use a lightweight relay host strictly to pass active session state between connected browsers."
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
                        "If this policy changes materially, an updated version will be posted at this URL with a revised effective date. As the WelcomTalk Portal beta evolves, this policy will be updated to describe the production web experience more precisely."
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
                        "By downloading, installing, or using the iPhone app or WelcomTalk Portal, you agree to be bound by these Terms of Use. If you do not agree, do not use the iPhone app or WelcomTalk Portal."
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
                        "The iPhone app and WelcomTalk Portal beta are intended to facilitate voluntary, structured, face-to-face or remote conversations between consenting adults. You agree to use them only for lawful purposes and in a manner consistent with their intended design."
                    ]
                ),
                LegalSection(
                    number: "4",
                    title: "Prohibited Use",
                    paragraphs: [
                        "You must not use the iPhone app or WelcomTalk Portal to:"
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
                        "All content, design, code, and trademarks in the iPhone app and WelcomTalk Portal are the property of Wael Wahbeh. Nothing in these Terms grants you any right to use their names, logos, or trademarks without prior written permission."
                    ]
                ),
                LegalSection(
                    number: "6",
                    title: "No Warranty",
                    paragraphs: [
                        "The iPhone app and WelcomTalk Portal are provided as is and as available without warranties of any kind, express or implied, including but not limited to merchantability, fitness for a particular purpose, or non-infringement. Wael Wahbeh does not warrant that the iPhone app or WelcomTalk Portal will be uninterrupted, error-free, or suitable for any specific purpose."
                    ]
                ),
                LegalSection(
                    number: "7",
                    title: "Limitation of Liability",
                    paragraphs: [
                        "To the fullest extent permitted by law, Wael Wahbeh shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of or inability to use the iPhone app or WelcomTalk Portal, even if advised of the possibility of such damages. The total liability in any matter related to the iPhone app or WelcomTalk Portal is limited to the amount you paid for the iPhone app (if any)."
                    ]
                ),
                LegalSection(
                    number: "8",
                    title: "Third-Party Frameworks",
                    paragraphs: [
                        "The iPhone app uses Apple platform frameworks (Multipeer Connectivity, Speech, EventKit, Core Data). The WelcomTalk Portal beta uses standard browser capabilities and may rely on a lightweight real-time relay to synchronize live sessions. Your use of those frameworks and browser services is additionally subject to the relevant platform terms and policies."
                    ]
                ),
                LegalSection(
                    number: "9",
                    title: "Disclaimer on Sensitive Conversations",
                    paragraphs: [
                        "The iPhone app and WelcomTalk Portal are communication tools only. They are not a substitute for professional legal, psychological, or mediation services. For disputes involving legal rights, domestic safety, or mental health, please consult qualified professionals."
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
                        "We reserve the right to update these Terms at any time. An updated version will be posted at this URL with a revised effective date. Continued use of the iPhone app or WelcomTalk Portal after changes constitutes acceptance of the new Terms."
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
