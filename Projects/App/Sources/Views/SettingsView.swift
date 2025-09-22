import SwiftUI
import DataKit

struct SettingsView: View {
  @EnvironmentObject private var appState: AppState
  @EnvironmentObject private var privacySettings: PrivacySettings
  @State private var isClearing = false

  var body: some View {
    Form {
      Section {
        Toggle("settings_delete_toggle", isOn: $privacySettings.deleteAfterAnalysis)
          .tint(.accentColor)
      } footer: {
        Text("settings_toggle_footer")
      }

      Section(footer: Text("settings_delete_footer")) {
        Button(role: .destructive, action: deleteAllData) {
          if isClearing {
            ProgressView()
              .progressViewStyle(.circular)
              .frame(maxWidth: .infinity)
          } else {
            Text("settings_delete_all")
              .frame(maxWidth: .infinity)
          }
        }
        .disabled(isClearing)
      }
    }
    .navigationTitle(Text("settings_nav_title"))
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Done") {
          appState.route = .capture
        }
      }
    }
  }

  private func deleteAllData() {
    guard !isClearing else { return }

    isClearing = true
    Task {
      await privacySettings.deleteAllData()
      await MainActor.run {
        appState.resetCaptures()
        isClearing = false
      }
    }
  }
}
