import Foundation

enum ClipboardItemType: String, Codable, CaseIterable {
    case text
    case image
    case rtf
    case file

    var displayName: String {
        switch self {
        case .text: return "Texto"
        case .image: return "Imagem"
        case .rtf: return "Rich Text"
        case .file: return "Arquivo"
        }
    }

    var iconName: String {
        switch self {
        case .text: return "text.alignleft"
        case .image: return "photo"
        case .rtf: return "textformat"
        case .file: return "doc"
        }
    }
}

struct ClipboardItem: Identifiable, Codable, Hashable {
    let id: UUID
    var content: String
    let type: ClipboardItemType
    let timestamp: Date
    var dataPath: String?
    let sourceApp: String
    var isFavorite: Bool
    var data: Data?

    init(
        id: UUID = UUID(),
        content: String,
        type: ClipboardItemType,
        timestamp: Date,
        data: Data? = nil,
        dataPath: String? = nil,
        sourceApp: String = "Desconhecido",
        isFavorite: Bool = false
    ) {
        self.id = id
        self.content = content
        self.type = type
        self.timestamp = timestamp
        self.data = data
        self.dataPath = dataPath
        self.sourceApp = sourceApp
        self.isFavorite = isFavorite
    }

    private enum CodingKeys: String, CodingKey {
        case id, content, type, timestamp, dataPath, sourceApp, isFavorite
    }

    var truncatedContent: String {
        content.count > 100 ? String(content.prefix(100)) + "..." : content
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(timestamp) {
            formatter.dateFormat = "HH:mm"
        } else if Calendar.current.isDate(timestamp, equalTo: Date(), toGranularity: .weekOfYear) {
            formatter.dateFormat = "E HH:mm"
        } else {
            formatter.dateFormat = "dd/MM HH:mm"
        }
        return formatter.string(from: timestamp)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.id == rhs.id
    }
}
