import SwiftUI
import DataKit
import DesignSystem
import MLCore

struct QuestionnaireView: View {
  @EnvironmentObject private var appState: AppState
  @State private var selectedGoals: Set<String> = []
  @State private var selectedBudget: String = "mid"
  @State private var fragranceFreeOnly: Bool = true
  @State private var isAnalyzing = false

  private let allGoals = [
    Goal(id: "acne", titleKey: "goal_acne_title"),
    Goal(id: "hydration", titleKey: "goal_hydration_title"),
    Goal(id: "tone", titleKey: "goal_tone_title"),
  ]

  private let budgets = [
    BudgetOption(id: "low", titleKey: "budget_low"),
    BudgetOption(id: "mid", titleKey: "budget_mid"),
    BudgetOption(id: "high", titleKey: "budget_high"),
  ]

  var body: some View {
    ZStack(alignment: .top) {
      List {
        Section("questionnaire_skin_goals") {
          ForEach(allGoals) { goal in
            Button {
              toggle(goal.id)
            } label: {
              HStack {
                Text(goal.title)
                Spacer()
                if selectedGoals.contains(goal.id) {
                  Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentColor)
                } else {
                  Image(systemName: "circle")
                    .foregroundStyle(.tertiary)
                }
              }
            }
            .buttonStyle(.plain)
          }
        }

        Section("questionnaire_budget") {
          Picker("questionnaire_budget", selection: $selectedBudget) {
            ForEach(budgets) { option in
              Text(option.title).tag(option.id)
            }
          }
          .pickerStyle(.segmented)
        }

        Section {
          Toggle("questionnaire_fragrance_toggle", isOn: $fragranceFreeOnly)
            .tint(.accentColor)
        }

        Section {
          Button(action: analyze) {
            Text("questionnaire_button")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.borderedProminent)
          .disabled(isAnalyzing || appState.capturedImages.count < 3)
        }
      }
      .listStyle(.insetGrouped)
      .navigationTitle(Text("questionnaire_nav_title"))
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Back") {
            appState.resetCaptures()
            appState.route = .capture
          }
        }
      }

      AnalyzingBanner(isAnalyzing: $isAnalyzing)
        .padding(.top, 12)
    }
    .onAppear {
      selectedGoals = Set(appState.questionnaire.goals)
      selectedBudget = appState.questionnaire.budget
      fragranceFreeOnly = appState.questionnaire.fragranceFreeOnly
    }
  }

  private func toggle(_ goal: String) {
    if selectedGoals.contains(goal) {
      selectedGoals.remove(goal)
    } else {
      selectedGoals.insert(goal)
    }
  }

  private func analyze() {
    guard !isAnalyzing else { return }

    isAnalyzing = true
    let questionnaire = Questionnaire(
      goals: Array(selectedGoals).sorted(),
      budget: selectedBudget,
      fragranceFreeOnly: fragranceFreeOnly
    )

    Task {
      let traits = await SkinAnalyzer.shared.mockAnalyze(images: appState.capturedImages)
      await MainActor.run {
        appState.resetCaptures()
        appState.questionnaire = questionnaire
        appState.route = .results(traits)
        isAnalyzing = false
      }
    }
  }
}

private struct Goal: Identifiable {
  let id: String
  let titleKey: String

  var title: String { NSLocalizedString(titleKey, comment: "Questionnaire goal title") }
}

private struct BudgetOption: Identifiable {
  let id: String
  let titleKey: String

  var title: String { NSLocalizedString(titleKey, comment: "Budget option title") }
}
