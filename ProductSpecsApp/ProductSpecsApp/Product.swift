import Foundation

struct Product: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var spec: String
    var category: String
    var packageType: String
    var length: Double
    var width: Double
    var height: Double
    var remark: String
    var imageFileNames: [String]
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var cbm: Double {
        length * width * height / 1_000_000
    }
}
