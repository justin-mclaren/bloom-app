import Combine
import Foundation

public final class PrivacySettings: ObservableObject {
  private enum Keys {
    static let deleteAfterAnalysis = "deletePhotosAfterAnalysis"
  }

  private let userDefaults: UserDefaults

  @Published public var deleteAfterAnalysis: Bool {
    didSet {
      userDefaults.set(deleteAfterAnalysis, forKey: Keys.deleteAfterAnalysis)
    }
  }

  public init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults

    if userDefaults.object(forKey: Keys.deleteAfterAnalysis) == nil {
      userDefaults.set(true, forKey: Keys.deleteAfterAnalysis)
      deleteAfterAnalysis = true
    } else {
      deleteAfterAnalysis = userDefaults.bool(forKey: Keys.deleteAfterAnalysis)
    }
  }

  public func deleteAllData() async {
    await PhotoDiskStore.shared.deleteAll()
  }
}
