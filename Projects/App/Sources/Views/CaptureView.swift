import SwiftUI
import CameraFeature
import DataKit
import UIKit

struct CaptureView: View {
  @EnvironmentObject private var appState: AppState
  @EnvironmentObject private var privacySettings: PrivacySettings

  private let lightingAnalyzer = LightingAnalyzer()
  @State private var lightingCondition: LightingCondition?

  private let steps: [CaptureStep] = [
    CaptureStep(titleKey: "capture_step_front_title", detailKey: "capture_step_front_detail"),
    CaptureStep(titleKey: "capture_step_left_title", detailKey: "capture_step_left_detail"),
    CaptureStep(titleKey: "capture_step_right_title", detailKey: "capture_step_right_detail"),
  ]

  var body: some View {
    ZStack(alignment: .top) {
      CameraView(
        buttonTitle: buttonTitle,
        isCaptureEnabled: true,
        onPhoto: { handleCapture($0) }
      )
      .ignoresSafeArea()

      VStack(spacing: 16) {
        header

        if let condition = lightingCondition {
          LightingPrompt(condition: condition)
            .transition(.opacity)
        }

        Spacer()

        captureFooter
      }
      .padding()
    }
  }

  private var buttonTitle: String {
    let nextIndex = min(appState.capturedImages.count + 1, steps.count)
    let format = NSLocalizedString("capture_button_format", comment: "Capture button label format")
    return String(format: format, nextIndex)
  }

  private var currentStep: CaptureStep {
    let index = min(appState.capturedImages.count, steps.count - 1)
    return steps[index]
  }

  private var header: some View {
    HStack(alignment: .center) {
      VStack(alignment: .leading, spacing: 4) {
        Text(currentStep.title)
          .font(.headline)
          .foregroundStyle(.white)
        Text(currentStep.detail)
          .font(.subheadline)
          .foregroundStyle(.white.opacity(0.8))
      }
      .padding(12)
      .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

      Spacer()

      Button {
        appState.route = .settings
      } label: {
        Image(systemName: "gearshape")
          .imageScale(.large)
          .padding(10)
          .background(.ultraThinMaterial, in: Circle())
      }
      .buttonStyle(.plain)
      .accessibilityLabel(Text("capture_settings_accessibility"))
    }
  }

  private var captureFooter: some View {
    VStack(spacing: 8) {
      Text("capture_footer_hint")
        .font(.footnote)
        .foregroundStyle(.white.opacity(0.9))
    }
    .frame(maxWidth: .infinity)
  }

  private func handleCapture(_ image: UIImage) {
    let evaluation = lightingAnalyzer.evaluate(image: image)

    guard evaluation == .good else {
      withAnimation {
        lightingCondition = evaluation
      }
      return
    }

    withAnimation {
      lightingCondition = nil
    }

    Task {
      if !privacySettings.deleteAfterAnalysis {
        _ = try? await PhotoDiskStore.shared.save(image: image)
      }

      await MainActor.run {
        appState.capturedImages.append(image)

        if appState.capturedImages.count >= steps.count {
          appState.route = .questionnaire
        }
      }
    }
  }
}

private struct CaptureStep {
  let titleKey: String
  let detailKey: String

  var title: String { NSLocalizedString(titleKey, comment: "Capture step title") }
  var detail: String { NSLocalizedString(detailKey, comment: "Capture step detail") }
}

private struct LightingPrompt: View {
  let condition: LightingCondition

  var body: some View {
    Text(condition.message)
      .font(.subheadline.weight(.medium))
      .padding(12)
      .frame(maxWidth: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .fill(.black.opacity(0.55))
      )
      .foregroundColor(.white)
  }
}
