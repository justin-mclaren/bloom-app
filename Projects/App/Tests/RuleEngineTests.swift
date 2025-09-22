import XCTest
@testable import App
import Recommendations
import MLCore
import DataKit

final class RuleEngineTests: XCTestCase {
  func testAcneGoalReturnsBHATreatmentAndSPF() {
    let traits = Traits(
      oilyTzone: 0.4,
      dryness: 0.5,
      acneLikelihood: 0.7,
      redness: 0.3,
      wrinkles: 0.2,
      hyperpigmentation: 0.4,
      sensitivityRisk: 0.5,
      qualityScore: 0.9
    )

    let questionnaire = Questionnaire(goals: ["acne"], budget: "mid", fragranceFreeOnly: true)
    let routine = RuleEngine.routine(for: traits, questionnaire: questionnaire)

    XCTAssertTrue(
      routine.steps.contains { step in
        step.product.tags.contains(where: { $0.caseInsensitiveCompare("bha") == .orderedSame })
      },
      "Routine should include a BHA treatment when acne goal is selected."
    )

    XCTAssertTrue(
      routine.steps.contains { $0.product.category == "spf" },
      "Routine must always include SPF."
    )
  }

  func testFragranceFreeFilter() {
    let traits = Traits.empty
    let questionnaire = Questionnaire(goals: [], budget: "mid", fragranceFreeOnly: true)

    let routine = RuleEngine.routine(for: traits, questionnaire: questionnaire)

    XCTAssertFalse(routine.steps.isEmpty)
    XCTAssertTrue(routine.steps.allSatisfy { $0.product.isFragranceFree })
  }

  func testRoutineDoesNotExceedFourSteps() {
    let traits = Traits(
      oilyTzone: 0.6,
      dryness: 0.8,
      acneLikelihood: 0.65,
      redness: 0.5,
      wrinkles: 0.4,
      hyperpigmentation: 0.6,
      sensitivityRisk: 0.5,
      qualityScore: 0.85
    )

    let questionnaire = Questionnaire(goals: ["acne", "tone", "hydration"], budget: "high", fragranceFreeOnly: false)
    let routine = RuleEngine.routine(for: traits, questionnaire: questionnaire)

    XCTAssertLessThanOrEqual(routine.steps.count, 4)
  }
}
