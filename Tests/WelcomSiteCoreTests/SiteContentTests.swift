import Foundation
import Testing
@testable import WelcomSiteCore

@Test func homePageIncludesSixFeatureCards() {
    let viewModel = WebsiteViewModel(route: .home)

    #expect(viewModel.homePage.features.count == 6)
    #expect(viewModel.homePage.badge == "Website JSON Builder")
    #expect(viewModel.homePage.features.first?.title == "Request JSON Builder")
    #expect(viewModel.homePage.sharedSessionSummary.fairnessLine.contains("Equal time for each participant"))
}

@Test func privacyPageTitleMatchesRoute() {
    let viewModel = WebsiteViewModel(route: .privacy)

    #expect(viewModel.legalPage?.title == "Privacy Policy")
    #expect(viewModel.legalPage?.sections.count == 11)
}

@Test func sharedSessionSummaryComesFromParentModelPackage() {
    let summary = WebsiteViewModel(route: .home).homePage.sharedSessionSummary

    #expect(summary.sessionCode == "DEMO42")
    #expect(summary.currentSpeakerName == "Sam")
    #expect(summary.turnProgressText == "Turn 4 of 4")
    #expect(summary.statusText == "Live now")
}

@Test func requestFormDraftGeneratesStructuredWebsiteRecord() {
    let draft = RequestFormDraft(
        fullName: "Jordan Smith",
        topic: "Repair dispute",
        summary: "Need a structured record of the repair timeline.",
        supportingDocumentNamesLine: "invoice.pdf, photos.png",
        additionalNotes: "Please include the follow-up emails.",
        hasConsent: true
    )

    let record = draft.generatedRecord(
        requestId: "REQ-123",
        createdAt: Date(timeIntervalSince1970: 0)
    )

    #expect(record?.requestId == "REQ-123")
    #expect(record?.source == "website")
    #expect(record?.attachments.count == 2)
    #expect(record?.attachments.first?.contentType == "application/pdf")
    #expect(draft.generatedJSONPreview(requestId: "REQ-123", createdAt: Date(timeIntervalSince1970: 0)) != nil)
}
