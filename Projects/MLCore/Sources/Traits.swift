import Foundation

public struct Traits: Codable, Equatable {
  public var oilyTzone: Double
  public var dryness: Double
  public var acneLikelihood: Double
  public var redness: Double
  public var wrinkles: Double
  public var hyperpigmentation: Double
  public var sensitivityRisk: Double
  public var qualityScore: Double

  public init(
    oilyTzone: Double,
    dryness: Double,
    acneLikelihood: Double,
    redness: Double,
    wrinkles: Double,
    hyperpigmentation: Double,
    sensitivityRisk: Double,
    qualityScore: Double
  ) {
    self.oilyTzone = oilyTzone
    self.dryness = dryness
    self.acneLikelihood = acneLikelihood
    self.redness = redness
    self.wrinkles = wrinkles
    self.hyperpigmentation = hyperpigmentation
    self.sensitivityRisk = sensitivityRisk
    self.qualityScore = qualityScore
  }

  public static let empty = Traits(
    oilyTzone: 0.5,
    dryness: 0.5,
    acneLikelihood: 0.5,
    redness: 0.5,
    wrinkles: 0.5,
    hyperpigmentation: 0.5,
    sensitivityRisk: 0.5,
    qualityScore: 0.8
  )
}
