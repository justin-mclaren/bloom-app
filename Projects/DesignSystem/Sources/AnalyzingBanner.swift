import SwiftUI

public struct AnalyzingBanner: View {
  @Binding private var isAnalyzing: Bool

  public init(isAnalyzing: Binding<Bool>) {
    _isAnalyzing = isAnalyzing
  }

  public var body: some View {
    if isAnalyzing {
      Text("Analyzing…")
        .font(.headline)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.top, 20)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: isAnalyzing)
    }
  }
}
