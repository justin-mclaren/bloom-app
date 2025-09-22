import Foundation
import UIKit

public actor PhotoDiskStore {
  public static let shared = PhotoDiskStore()

  private let fileManager: FileManager
  private let directory: URL

  public init(fileManager: FileManager = .default) {
    self.fileManager = fileManager
    if let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
      directory = documents.appendingPathComponent("SkincareAIPhotos", isDirectory: true)
    } else {
      directory = fileManager.temporaryDirectory.appendingPathComponent("SkincareAIPhotos", isDirectory: true)
    }

    if !fileManager.fileExists(atPath: directory.path) {
      try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }
  }

  @discardableResult
  public func save(image: UIImage) throws -> URL {
    guard let data = image.jpegData(compressionQuality: 0.9) else {
      throw PhotoStoreError.encodingFailed
    }

    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let timestamp = formatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")
    let name = "capture-" + timestamp + ".jpg"
    let url = directory.appendingPathComponent(name)

    do {
      try data.write(to: url, options: [.atomic])
      return url
    } catch {
      throw PhotoStoreError.writeFailed(error)
    }
  }

  public func deleteAll() {
    guard let contents = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
      return
    }

    for url in contents {
      try? fileManager.removeItem(at: url)
    }
  }

  public enum PhotoStoreError: Error {
    case encodingFailed
    case writeFailed(Error)
  }
}
