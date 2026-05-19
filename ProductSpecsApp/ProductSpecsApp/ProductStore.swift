import SwiftUI
import UIKit

@MainActor
final class ProductStore: ObservableObject {
    @Published var products: [Product] = []

    private let fileName = "products.json"

    init() {
        createFoldersIfNeeded()
        load()
    }

    var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    var dataURL: URL {
        documentsURL.appendingPathComponent(fileName)
    }

    var imagesURL: URL {
        documentsURL.appendingPathComponent("images")
    }

    func createFoldersIfNeeded() {
        if !FileManager.default.fileExists(atPath: imagesURL.path) {
            try? FileManager.default.createDirectory(at: imagesURL, withIntermediateDirectories: true)
        }
    }

    func load() {
        guard FileManager.default.fileExists(atPath: dataURL.path) else {
            products = []
            return
        }
        do {
            let data = try Data(contentsOf: dataURL)
            products = try JSONDecoder().decode([Product].self, from: data)
        } catch {
            print("Load error:", error)
            products = []
        }
    }

    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(products)
            try data.write(to: dataURL, options: .atomic)
        } catch {
            print("Save error:", error)
        }
    }

    func add(_ product: Product) {
        products.insert(product, at: 0)
        save()
    }

    func update(_ product: Product) {
        guard let index = products.firstIndex(where: { $0.id == product.id }) else { return }
        var item = product
        item.updatedAt = Date()
        products[index] = item
        save()
    }

    func delete(_ product: Product) {
        products.removeAll { $0.id == product.id }
        for name in product.imageFileNames {
            try? FileManager.default.removeItem(at: imageURL(name))
        }
        save()
    }

    func saveImage(_ image: UIImage) -> String? {
        createFoldersIfNeeded()
        let name = UUID().uuidString + ".jpg"
        let url = imageURL(name)
        guard let data = image.jpegData(compressionQuality: 0.86) else { return nil }
        do {
            try data.write(to: url, options: .atomic)
            return name
        } catch {
            print("Image save error:", error)
            return nil
        }
    }

    func imageURL(_ name: String) -> URL {
        imagesURL.appendingPathComponent(name)
    }

    func exportJSONToClipboard() {
        guard let data = try? JSONEncoder().encode(products),
              let text = String(data: data, encoding: .utf8) else { return }
        UIPasteboard.general.string = text
    }
}
