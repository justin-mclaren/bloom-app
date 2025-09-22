import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import Foundation

public enum LightingCondition: Equatable {
  case good
  case tooDark
  case tooBright

  public var message: String {
    switch self {
    case .good:
      return ""
    case .tooDark:
      return NSLocalizedString("lighting_prompt_too_dark", comment: "Prompt when lighting is too dark")
    case .tooBright:
      return NSLocalizedString("lighting_prompt_too_bright", comment: "Prompt when lighting is too bright")
    }
  }
}

public struct LightingAnalyzer {
  private let context = CIContext()

  public init() {}

  public func evaluate(image: UIImage) -> LightingCondition {
    guard let ciImage = CIImage(image: image) else {
      return .good
    }

    let extent = ciImage.extent
    let vector = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)

    guard let filter = CIFilter(name: "CIAreaAverage") else {
      return .good
    }

    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(vector, forKey: kCIInputExtentKey)

    guard let outputImage = filter.outputImage else {
      return .good
    }

    var bitmap = [UInt8](repeating: 0, count: 4)
    context.render(
      outputImage,
      toBitmap: &bitmap,
      rowBytes: 4,
      bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
      format: .RGBA8,
      colorSpace: CGColorSpaceCreateDeviceRGB()
    )

    let r = Double(bitmap[0]) / 255.0
    let g = Double(bitmap[1]) / 255.0
    let b = Double(bitmap[2]) / 255.0

    let luminance = 0.299 * r + 0.587 * g + 0.114 * b

    if luminance < 0.2 {
      return .tooDark
    } else if luminance > 0.85 {
      return .tooBright
    } else {
      return .good
    }
  }
}
