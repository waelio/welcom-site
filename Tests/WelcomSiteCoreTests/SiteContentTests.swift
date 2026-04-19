import Testing
@testable import WelcomSiteCore

@Test func homePageIncludesSixFeatureCards() {
    let viewModel = WebsiteViewModel(route: .home)

    #expect(viewModel.homePage.features.count == 6)
    #expect(viewModel.homePage.features.first?.title == "Structured Turns")
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
