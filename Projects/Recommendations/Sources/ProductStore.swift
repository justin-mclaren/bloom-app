import Foundation

public struct Product: Codable, Identifiable, Equatable {
  public let id: String
  public let brand: String
  public let name: String
  public let category: String
  public let price: Double
  public let tags: [String]
  public let spf: Int?

  public var isFragranceFree: Bool {
    tags.contains { $0.caseInsensitiveCompare("fragrance-free") == .orderedSame }
  }
}

public final class ProductStore {
  public static let shared = ProductStore()

  public let products: [Product]

  private init() {
    products = Self.loadJSON(filename: "products")
  }

  public func products(
    in category: String,
    matchingAnyOf tags: [String] = [],
    fragranceFreeOnly: Bool
  ) -> [Product] {
    products.filter { product in
      guard product.category == category else { return false }

      if fragranceFreeOnly && !product.isFragranceFree {
        return false
      }

      guard !tags.isEmpty else { return true }

      return product.tags.contains { productTag in
        tags.contains { $0.caseInsensitiveCompare(productTag) == .orderedSame }
      }
    }
  }

  public func allProducts(in category: String, fragranceFreeOnly: Bool) -> [Product] {
    products(
      in: category,
      matchingAnyOf: [],
      fragranceFreeOnly: fragranceFreeOnly
    )
  }

  private static func loadJSON<T: Decodable>(filename: String) -> T {
    guard let url = Bundle.module.url(forResource: filename, withExtension: "json") else {
      fatalError("Missing resource: \(filename).json")
    }

    do {
      let data = try Data(contentsOf: url)
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      fatalError("Failed to load \(filename).json: \(error)")
    }
  }
}
