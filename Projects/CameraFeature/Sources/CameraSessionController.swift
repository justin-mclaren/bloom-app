import AVFoundation
import UIKit

public final class CameraSessionController: NSObject {
  public static let shared = CameraSessionController()

  public let session = AVCaptureSession()
  private let output = AVCapturePhotoOutput()
  private let sessionQueue = DispatchQueue(label: "CameraSessionController.session")
  private var onCapture: ((UIImage) -> Void)?

  override init() {
    super.init()
    configureSession()
  }

  public func capture(completion: @escaping (UIImage) -> Void) {
    sessionQueue.async {
      self.onCapture = completion
      let settings = AVCapturePhotoSettings()
      settings.flashMode = .off
      self.output.capturePhoto(with: settings, delegate: self)
    }
  }

  public func start() {
    sessionQueue.async {
      if !self.session.isRunning {
        self.session.startRunning()
      }
    }
  }

  public func stop() {
    sessionQueue.async {
      if self.session.isRunning {
        self.session.stopRunning()
      }
    }
  }

  private func configureSession() {
    sessionQueue.async {
      self.session.beginConfiguration()
      self.session.sessionPreset = .photo

      guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: device),
            self.session.canAddInput(input),
            self.session.canAddOutput(self.output) else {
        self.session.commitConfiguration()
        return
      }

      self.session.addInput(input)
      self.session.addOutput(self.output)
      self.output.isHighResolutionCaptureEnabled = true

      self.session.commitConfiguration()
      self.session.startRunning()
    }
  }
}

extension CameraSessionController: AVCapturePhotoCaptureDelegate {
  public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    guard error == nil,
          let data = photo.fileDataRepresentation(),
          let image = UIImage(data: data) else {
      return
    }

    let handler = onCapture
    onCapture = nil

    DispatchQueue.main.async {
      handler?(image)
    }
  }
}
