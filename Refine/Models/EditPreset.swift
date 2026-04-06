import Foundation

/// プリセットモデル - 用途別の補正セットを定義
struct EditPreset: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let parameters: EditParameters

    init(id: UUID = UUID(), name: String, description: String, parameters: EditParameters) {
        self.id = id
        self.name = name
        self.description = description
        self.parameters = parameters
    }
}
