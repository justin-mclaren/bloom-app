import SwiftUI

public struct RoutineCard: View {
  private let stepNumber: Int
  private let title: String
  private let time: String
  private let rationale: String

  public init(stepNumber: Int, title: String, time: String, rationale: String) {
    self.stepNumber = stepNumber
    self.title = title
    self.time = time
    self.rationale = rationale
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("STEP \(stepNumber)")
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.secondary)

      Text(title)
        .font(.headline)

      Text(time)
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Text(rationale)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(Color(.secondarySystemBackground))
    )
  }
}
