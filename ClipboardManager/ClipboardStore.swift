import Foundation
import CryptoKit

final class ClipboardStore {
    static let shared = ClipboardStore()

    private let fileManager = FileManager.default
    private let baseDirectory: URL
    private let itemsDirectory: URL
    private let indexURL: URL
    private let queue = DispatchQueue(label: "app.xgboard.store", qos: .utility)
    private let migrationKey = "ClipboardStore.migratedFromUserDefaultsV1"
    private let legacyUserDefaultsKey = "ClipboardItems"

    var totalSizeBudgetBytes: Int = 200 * 1024 * 1024

    private init() {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support")
        baseDirectory = appSupport.appendingPathComponent("XGBoard", isDirectory: true)
        itemsDirectory = baseDirectory.appendingPathComponent("items", isDirectory: true)
        indexURL = baseDirectory.appendingPathComponent("index.json")

        try? fileManager.createDirectory(at: itemsDirectory, withIntermediateDirectories: true)
    }

    func load() -> [ClipboardItem] {
        migrateFromUserDefaultsIfNeeded()
        guard fileManager.fileExists(atPath: indexURL.path),
              let data = try? Data(contentsOf: indexURL) else {
            return []
        }
        let decoder = JSONDecoder()
        do {
            let items = try decoder.decode([ClipboardItem].self, from: data)
            return items.compactMap(hydrate(_:))
        } catch {
            print("⚠️ ClipboardStore: índice inválido, iniciando vazio: \(error)")
            return []
        }
    }

    func persist(_ items: [ClipboardItem]) {
        queue.async { [weak self] in
            guard let self else { return }
            self.writeIndex(items)
            self.enforceSizeBudget(items)
        }
    }

    func writeBlob(_ data: Data, for id: UUID) -> String? {
        let url = itemsDirectory.appendingPathComponent("\(id.uuidString).bin")
        do {
            try data.write(to: url, options: .atomic)
            return url.lastPathComponent
        } catch {
            print("⚠️ ClipboardStore: falha ao gravar blob \(id): \(error)")
            return nil
        }
    }

    func readBlob(named name: String) -> Data? {
        try? Data(contentsOf: itemsDirectory.appendingPathComponent(name))
    }

    func deleteBlob(named name: String) {
        let url = itemsDirectory.appendingPathComponent(name)
        try? fileManager.removeItem(at: url)
    }

    static func hash(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func hash(_ string: String) -> String {
        hash(Data(string.utf8))
    }

    private func hydrate(_ item: ClipboardItem) -> ClipboardItem? {
        guard let path = item.dataPath else { return item }
        var copy = item
        copy.data = readBlob(named: path)
        return copy
    }

    private func writeIndex(_ items: [ClipboardItem]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        do {
            let data = try encoder.encode(items)
            try data.write(to: indexURL, options: .atomic)
        } catch {
            print("⚠️ ClipboardStore: falha ao gravar índice: \(error)")
        }
    }

    private func enforceSizeBudget(_ items: [ClipboardItem]) {
        let referencedNames = Set(items.compactMap { $0.dataPath })
        guard let entries = try? fileManager.contentsOfDirectory(
            at: itemsDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        for entry in entries where !referencedNames.contains(entry.lastPathComponent) {
            try? fileManager.removeItem(at: entry)
        }

        let surviving = entries.filter { referencedNames.contains($0.lastPathComponent) }
        let sizes = surviving.compactMap { url -> (URL, Int, Date)? in
            guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]),
                  let size = values.fileSize,
                  let date = values.contentModificationDate else { return nil }
            return (url, size, date)
        }

        var total = sizes.reduce(0) { $0 + $1.1 }
        guard total > totalSizeBudgetBytes else { return }

        let favoriteNames: Set<String> = Set(items.filter { $0.isFavorite }.compactMap { $0.dataPath })
        let candidates = sizes
            .filter { !favoriteNames.contains($0.0.lastPathComponent) }
            .sorted { $0.2 < $1.2 }

        for (url, size, _) in candidates {
            if total <= totalSizeBudgetBytes { break }
            try? fileManager.removeItem(at: url)
            total -= size
        }
    }

    private func migrateFromUserDefaultsIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: migrationKey),
              let legacyData = defaults.data(forKey: legacyUserDefaultsKey) else {
            defaults.set(true, forKey: migrationKey)
            return
        }

        defer {
            defaults.removeObject(forKey: legacyUserDefaultsKey)
            defaults.set(true, forKey: migrationKey)
        }

        guard !fileManager.fileExists(atPath: indexURL.path) else { return }

        struct LegacyItem: Decodable {
            let id: UUID
            let content: String
            let type: String
            let timestamp: Date
            let data: Data?
            let sourceApp: String?
            let isFavorite: Bool
        }

        let decoder = JSONDecoder()
        guard let legacy = try? decoder.decode([LegacyItem].self, from: legacyData) else {
            print("⚠️ ClipboardStore: dados legados ilegíveis, pulando migração")
            return
        }

        let migrated: [ClipboardItem] = legacy.compactMap { entry in
            guard let type = ClipboardItemType(rawValue: entry.type) else { return nil }
            var blobPath: String?
            if let blob = entry.data {
                blobPath = writeBlob(blob, for: entry.id)
            }
            return ClipboardItem(
                id: entry.id,
                content: entry.content,
                type: type,
                timestamp: entry.timestamp,
                data: entry.data,
                dataPath: blobPath,
                sourceApp: entry.sourceApp ?? "Migrado",
                isFavorite: entry.isFavorite
            )
        }

        writeIndex(migrated)
        print("✅ ClipboardStore: migrados \(migrated.count) itens do UserDefaults")
    }
}
