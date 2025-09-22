import SwiftUI
import MLCore
import Recommendations
import DesignSystem
import DataKit

struct ResultsView: View {
  @EnvironmentObject private var appState: AppState
  let traits: Traits

  private var routine: Routine {
    RuleEngine.routine(for: traits, questionnaire: appState.questionnaire)
  }

  var body: some View {
    List {
      Section("results_section_assessment") {
        ForEach(traitEntries, id: \.label) { entry in
          TraitBar(label: entry.label, value: entry.value)
        }
      }

      Section("results_section_routine") {
        ForEach(Array(routine.steps.enumerated()), id: \.(offset:element:).element.id) { index, step in
          RoutineCard(
            stepNumber: index + 1,
            title: step.product.name,
            time: timeSummary(for: step),
            rationale: step.rationale
          )
        }
      }

      Section(footer: Text("results_disclaimer")) {
        EmptyView()
      }
    }
    .listStyle(.insetGrouped)
    .navigationTitle(Text("results_nav_title"))
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button {
          appState.resetCaptures()
          appState.route = .capture
        } label: {
          Text("results_retake")
        }
      }
    }
  }

  private var traitEntries: [(label: String, value: Double)] {
    [
      (NSLocalizedString("trait_oil_tzone", comment: "Trait label"), traits.oilyTzone),
      (NSLocalizedString("trait_dryness", comment: "Trait label"), traits.dryness),
      (NSLocalizedString("trait_acne", comment: "Trait label"), traits.acneLikelihood),
      (NSLocalizedString("trait_redness", comment: "Trait label"), traits.redness),
      (NSLocalizedString("trait_wrinkles", comment: "Trait label"), traits.wrinkles),
      (NSLocalizedString("trait_hyperpigmentation", comment: "Trait label"), traits.hyperpigmentation),
    ]
  }

  private func timeSummary(for step: RoutineStep) -> String {
    if Set(step.times) == Set([.am, .pm]) {
      return NSLocalizedString("routine_time_both", comment: "Routine timing")
    } else if step.times.contains(.am) {
      return NSLocalizedString("routine_time_am", comment: "Routine timing")
    } else {
      return NSLocalizedString("routine_time_pm", comment: "Routine timing")
    }
  }
}
