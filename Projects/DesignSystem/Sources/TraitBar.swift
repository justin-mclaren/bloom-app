import SwiftUI

public struct TraitBar: View {
  private let label: String
  private let value: Double

  public init(label: String, value: Double) {
    self.label = label
    self.value = value
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(label)
        .font(.headline)

      GeometryReader { proxy in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(Color(.systemGray5))
          Capsule()
            .fill(Color.accentColor)
            .frame(width: proxy.size.width * CGFloat(clampedValue))
        }
      }
      .frame(height: 10)

      Text(String(format: "%.0f%%", clampedValue * 100))
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }

  private var clampedValue: Double {
    min(max(value, 0), 1)
  }
}
