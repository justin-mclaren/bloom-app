import SwiftUI
import AVFoundation
import UIKit

public struct CameraView: View {
  private let buttonTitle: String
  private let isCaptureEnabled: Bool
  private let onPhoto: (UIImage) -> Void
  @StateObject private var controller = SharedController()

  public init(
    buttonTitle: String = "Take Photo",
    isCaptureEnabled: Bool = true,
    onPhoto: @escaping (UIImage) -> Void
  ) {
    self.buttonTitle = buttonTitle
    self.isCaptureEnabled = isCaptureEnabled
    self.onPhoto = onPhoto
  }

  public var body: some View {
    ZStack(alignment: .bottom) {
      CameraPreview(session: controller.session)
        .overlay(
          GeometryReader { proxy in
            Circle()
              .strokeBorder(Color.white.opacity(0.85), lineWidth: 2)
              .frame(width: min(proxy.size.width, proxy.size.height) * 0.65)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .padding(.bottom, proxy.safeAreaInsets.bottom + 80)
              .padding(.top, proxy.safeAreaInsets.top + 40)
          }
        )
        .ignoresSafeArea()

      Button {
        controller.capture { image in
          onPhoto(image)
        }
      } label: {
        Text(buttonTitle)
          .font(.headline)
          .padding(.horizontal, 32)
          .padding(.vertical, 12)
      }
      .background(Color.white.opacity(0.9), in: Capsule())
      .foregroundColor(.black)
      .padding(.bottom, 32)
      .disabled(!isCaptureEnabled)
    }
    .onAppear {
      controller.start()
    }
    .onDisappear {
      controller.stop()
    }
  }
}

private final class SharedController: ObservableObject {
  let session: AVCaptureSession

  init() {
    session = CameraSessionController.shared.session
  }

  func start() {
    CameraSessionController.shared.start()
  }

  func stop() {
    CameraSessionController.shared.stop()
  }

  func capture(_ completion: @escaping (UIImage) -> Void) {
    CameraSessionController.shared.capture(completion: completion)
  }
}

private struct CameraPreview: UIViewRepresentable {
  let session: AVCaptureSession

  func makeUIView(context: Context) -> PreviewView {
    let view = PreviewView()
    view.videoPreviewLayer.session = session
    view.videoPreviewLayer.videoGravity = .resizeAspectFill
    return view
  }

  func updateUIView(_ uiView: PreviewView, context: Context) {
    uiView.videoPreviewLayer.session = session
  }
}

private final class PreviewView: UIView {
  override static var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
  }

  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    guard let previewLayer = layer as? AVCaptureVideoPreviewLayer else {
      fatalError("Unexpected layer type")
    }
    return previewLayer
  }
}
