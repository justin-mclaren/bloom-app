import Foundation
import MLCore
import DataKit

public struct Routine: Equatable {
  public let steps: [RoutineStep]

  public init(steps: [RoutineStep]) {
    self.steps = steps
  }

  public func steps(for time: RoutineTime) -> [RoutineStep] {
    steps.filter { $0.times.contains(time) }
  }
}

public struct RoutineStep: Identifiable, Equatable {
  public let id: String
  public let product: Product
  public let times: [RoutineTime]
  public let rationale: String

  public init(product: Product, times: [RoutineTime], rationale: String) {
    id = product.id
    self.product = product
    self.times = times
    self.rationale = rationale
  }
}

public enum RoutineTime: String, Codable, CaseIterable {
  case am
  case pm
}

public enum RuleEngine {
  private static let rationaleStore = RoutineRationales.load()
  private static let productStore = ProductStore.shared

  public static func routine(for traits: Traits, questionnaire: Questionnaire) -> Routine {
    var steps: [RoutineStep] = []

    if let cleanser = selectProduct(
      category: "cleanser",
      matchingTags: [],
      questionnaire: questionnaire
    ) {
      steps.append(
        RoutineStep(
          product: cleanser,
          times: [.am, .pm],
          rationale: rationaleStore.text(for: "cleanser")
        )
      )
    }

    if let treatment = treatmentProduct(for: traits, questionnaire: questionnaire) {
      steps.append(treatment)
    }

    if let moisturizer = moisturizerProduct(for: traits, questionnaire: questionnaire) {
      steps.append(moisturizer)
    }

    if let spf = selectProduct(
      category: "spf",
      matchingTags: [],
      questionnaire: questionnaire
    ) {
      steps.append(
        RoutineStep(
          product: spf,
          times: [.am],
          rationale: rationaleStore.text(for: "spf")
        )
      )
    }

    return Routine(steps: Array(steps.prefix(4)))
  }

  private static func treatmentProduct(for traits: Traits, questionnaire: Questionnaire) -> RoutineStep? {
    let goals = Set(questionnaire.goals.map { $0.lowercased() })
    var tags: [String] = []
    var rationaleKey: String?

    if goals.contains("acne") || traits.acneLikelihood > 0.55 {
      tags = ["bha", "acne"]
      rationaleKey = "bha"
    } else if goals.contains("tone") {
      tags = ["vitc", "niacinamide"]
      rationaleKey = "vitc"
    } else if goals.contains("hydration") {
      tags = ["hydrating"]
      rationaleKey = "hydrating"
    }

    guard !tags.isEmpty else {
      return nil
    }

    guard let product = selectProduct(
      category: "treatment",
      matchingTags: tags,
      questionnaire: questionnaire
    ) else {
      return nil
    }

    return RoutineStep(
      product: product,
      times: [.pm],
      rationale: rationaleStore.text(for: rationaleKey ?? "treatment")
    )
  }

  private static func moisturizerProduct(for traits: Traits, questionnaire: Questionnaire) -> RoutineStep? {
    let isVeryDry = traits.dryness > 0.6
    let matchingTags = isVeryDry ? ["rich"] : ["hydrating", "lightweight"]
    let rationaleKey = isVeryDry ? "rich" : "hydrating"

    guard let product = selectProduct(
      category: "moisturizer",
      matchingTags: matchingTags,
      questionnaire: questionnaire
    ) else {
      return nil
    }

    return RoutineStep(
      product: product,
      times: [.am, .pm],
      rationale: rationaleStore.text(for: rationaleKey)
    )
  }

  private static func selectProduct(
    category: String,
    matchingTags: [String],
    questionnaire: Questionnaire
  ) -> Product? {
    let candidates = productStore.products(
      in: category,
      matchingAnyOf: matchingTags,
      fragranceFreeOnly: questionnaire.fragranceFreeOnly
    )

    guard !candidates.isEmpty else {
      return nil
    }

    let sorted = candidates.sorted { $0.price < $1.price }

    switch questionnaire.budget.lowercased() {
    case "high":
      return sorted.last
    case "mid":
      return sorted[sorted.count / 2]
    default:
      return sorted.first
    }
  }
}

private struct RoutineRationales: Decodable {
  let rationales: [String: String]

  func text(for key: String) -> String {
    if let text = rationales[key] {
      return text
    }

    return "Supports your skin during this step."
  }

  static func load() -> RoutineRationales {
    guard let url = Bundle.module.url(forResource: "rules", withExtension: "json") else {
      return RoutineRationales(rationales: [:])
    }

    do {
      let data = try Data(contentsOf: url)
      return try JSONDecoder().decode(RoutineRationales.self, from: data)
    } catch {
      return RoutineRationales(rationales: [:])
    }
  }
}
