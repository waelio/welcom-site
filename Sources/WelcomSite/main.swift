import TokamakShim
import WelcomSiteCore

struct WelcomSiteApp: App {
    private let viewModel = WebsiteViewModel(route: BrowserSupport.currentRoute())

    var body: some Scene {
        WindowGroup(viewModel.route.title) {
            WebsiteRootView(viewModel: viewModel)
        }
    }
}

WelcomSiteApp.main()
