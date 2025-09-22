import SwiftUI
import DataKit

@main
struct SkincareAIApp: App {
  @StateObject private var appState = AppState()
  @StateObject private var privacySettings = PrivacySettings()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(appState)
        .environmentObject(privacySettings)
    }
  }
}
