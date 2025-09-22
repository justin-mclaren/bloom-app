import SwiftUI
import MLCore
import DataKit
import UIKit

final class AppState: ObservableObject {
  @Published var route: Route = .capture
  @Published var capturedImages: [UIImage] = []
  @Published var questionnaire: Questionnaire = .empty

  func resetCaptures() {
    capturedImages.removeAll()
  }
}

enum Route {
  case capture
  case questionnaire
  case results(Traits)
  case settings
}

struct RootView: View {
  @EnvironmentObject private var appState: AppState

  @ViewBuilder
  var body: some View {
    switch appState.route {
    case .capture:
      CaptureView()
    case .questionnaire:
      NavigationStack {
        QuestionnaireView()
      }
    case .results(let traits):
      NavigationStack {
        ResultsView(traits: traits)
      }
    case .settings:
      NavigationStack {
        SettingsView()
      }
    }
  }
}
