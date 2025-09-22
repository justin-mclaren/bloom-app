import Foundation

public struct Questionnaire: Codable, Equatable {
  public var goals: [String]
  public var budget: String
  public var fragranceFreeOnly: Bool

  public init(goals: [String] = [], budget: String = "mid", fragranceFreeOnly: Bool = true) {
    self.goals = goals
    self.budget = budget
    self.fragranceFreeOnly = fragranceFreeOnly
  }

  public static let empty = Questionnaire()
}
