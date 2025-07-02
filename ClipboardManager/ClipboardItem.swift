import Foundation

enum ClipboardItemType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
    case rtf = "rtf"
    case file = "file"
    
    var displayName: String {
        switch self {
        case .text:
            return "Texto"
        case .image:
            return "Imagem"
        case .rtf:
            return "Rich Text"
        case .file:
            return "Arquivo"
        }
    }
    
    var iconName: String {
        switch self {
        case .text:
            return "text.alignleft"
        case .image:
            return "photo"
        case .rtf:
            return "textformat"
        case .file:
            return "doc"
        }
    }
    
    // Custom decoding para lidar com tipos antigos
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Se o tipo não existe (como "file" em dados antigos), mapear para texto
        self = ClipboardItemType(rawValue: rawValue) ?? .text
    }
}

struct ClipboardItem: Identifiable, Codable, Hashable {
    let id: UUID
    var content: String
    let type: ClipboardItemType
    let timestamp: Date
    let data: Data?
    let sourceApp: String
    var isFavorite: Bool
    
    init(content: String, type: ClipboardItemType, timestamp: Date, data: Data? = nil, sourceApp: String = "Desconhecido", isFavorite: Bool = false) {
        self.id = UUID()
        self.content = content
        self.type = type
        self.timestamp = timestamp
        self.data = data
        self.sourceApp = sourceApp
        self.isFavorite = isFavorite
    }
    
    // O custom decoder abaixo já lida com a migração automaticamente
    
    // Custom decoding para lidar com migração
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        type = try container.decode(ClipboardItemType.self, forKey: .type)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        data = try container.decodeIfPresent(Data.self, forKey: .data)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        
        // Tentar decodificar sourceApp, se não existir usar valor padrão
        sourceApp = try container.decodeIfPresent(String.self, forKey: .sourceApp) ?? "Migrado (App Desconhecido)"
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, content, type, timestamp, data, sourceApp, isFavorite
    }
    
    var truncatedContent: String {
        if content.count > 100 {
            return String(content.prefix(100)) + "..."
        }
        return content
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