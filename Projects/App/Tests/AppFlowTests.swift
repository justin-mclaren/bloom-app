import XCTest
import SwiftUI
@testable import App
import DataKit
import MLCore
import UIKit

final class AppFlowTests: XCTestCase {
  @MainActor
  func testRootViewNavigatesThroughFlow() {
    let suiteName = "com.skincareai.tests.flow"
    let defaults = UserDefaults(suiteName: suiteName) ?? .standard
    defaults.removePersistentDomain(forName: suiteName)
    defer { defaults.removePersistentDomain(forName: suiteName) }

    let appState = AppState()
    let privacy = PrivacySettings(userDefaults: defaults)

    let controller = UIHostingController(
      rootView: RootView()
        .environmentObject(appState)
        .environmentObject(privacy)
    )

    XCTAssertNotNil(controller.view)

    appState.capturedImages = [dummyImage(), dummyImage(), dummyImage()]
    appState.route = .questionnaire

    appState.questionnaire = Questionnaire(goals: ["acne"], budget: "mid", fragranceFreeOnly: true)
    appState.route = .results(Traits.empty)

    appState.route = .capture
  }

  private func dummyImage() -> UIImage {
    UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8)).image { context in
      UIColor.white.setFill()
      context.fill(CGRect(x: 0, y: 0, width: 8, height: 8))
    }
  }
}
