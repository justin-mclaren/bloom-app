import Foundation
import UIKit

public actor SkinAnalyzer {
  public static let shared = SkinAnalyzer()

  public func mockAnalyze(images: [UIImage]) async -> Traits {
    let delay = UInt64.random(in: 400_000_000...600_000_000)
    try? await Task.sleep(nanoseconds: delay)

    guard !images.isEmpty else {
      return Traits.empty
    }

    let seed = images
      .map { image -> Int in
        let width = Int(image.size.width.rounded())
        let height = Int(image.size.height.rounded())
        return max(width * height, 1)
      }
      .reduce(0, +)

    let normalized = Double((seed % 71) + 10) / 100.0
    let inverse = 1.0 - normalized

    return Traits(
      oilyTzone: normalized,
      dryness: max(min(inverse, 1.0), 0.0),
      acneLikelihood: 0.35 + 0.3 * normalized,
      redness: 0.25 + 0.35 * normalized,
      wrinkles: 0.2 + 0.5 * normalized,
      hyperpigmentation: 0.3 + 0.4 * normalized,
      sensitivityRisk: 0.45 + 0.1 * normalized,
      qualityScore: 0.75 + 0.15 * inverse
    )
  }
}
