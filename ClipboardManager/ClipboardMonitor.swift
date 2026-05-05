import Foundation
import AppKit
import SwiftUI

final class ClipboardMonitor: ObservableObject {
    static let shared = ClipboardMonitor()

    @Published var clipboardItems: [ClipboardItem] = []
    @AppStorage("maxItems") private var maxItems: Int = 500
    @AppStorage("monitoringInterval") private var monitoringInterval: Double = 0.5

    private var timer: Timer?
    private var lastChangeCount: Int
    private let pasteboard = NSPasteboard.general
    private let store = ClipboardStore.shared
    private var lastHash: String?

    private init() {
        lastChangeCount = pasteboard.changeCount
        clipboardItems = store.load()
        lastHash = clipboardItems.first.map(Self.hash(of:))
        print("📋 ClipboardMonitor: \(clipboardItems.count) itens carregados")
    }

    // MARK: - Lifecycle

    func startMonitoring() {
        guard timer == nil else { return }
        let timer = Timer(timeInterval: monitoringInterval, repeats: true) { [weak self] _ in
            self?.checkForClipboardChange()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Polling

    private func checkForClipboardChange() {
        let current = pasteboard.changeCount
        guard current != lastChangeCount else { return }
        lastChangeCount = current
        ingestCurrentPasteboard()
    }

    private func ingestCurrentPasteboard() {
        guard let item = pasteboard.pasteboardItems?.first else { return }
        let sourceApp = NSWorkspace.shared.frontmostApplication?.localizedName ?? "Desconhecido"

        if let fileURL = readFileURL(from: item) {
            ingestFile(fileURL, sourceApp: sourceApp)
        } else if let imageData = readImageData(from: item) {
            ingestImage(imageData, fileName: nil, sourceApp: sourceApp)
        } else if let text = item.string(forType: .string), !text.isEmpty {
            ingestText(text, sourceApp: sourceApp)
        } else if let rtf = item.data(forType: .rtf) {
            ingestRTF(rtf, sourceApp: sourceApp)
        }
    }

    // MARK: - Ingestion

    private func ingestFile(_ url: URL, sourceApp: String) {
        let imageExtensions: Set<String> = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "heic", "webp"]
        let ext = url.pathExtension.lowercased()
        if imageExtensions.contains(ext), let data = try? Data(contentsOf: url) {
            ingestImage(data, fileName: url.lastPathComponent, sourceApp: sourceApp)
            return
        }
        let size = fileSize(at: url)
        let content = "\(url.lastPathComponent) (\(size))"
        addItem(content: content, type: .file, data: nil, sourceApp: sourceApp,
                hash: ClipboardStore.hash(url.path))
    }

    private func ingestImage(_ data: Data, fileName: String?, sourceApp: String) {
        let info = describeImage(data: data, fileName: fileName)
        addItem(content: info, type: .image, data: data, sourceApp: sourceApp,
                hash: ClipboardStore.hash(data))
    }

    private func ingestText(_ text: String, sourceApp: String) {
        addItem(content: text, type: .text, data: nil, sourceApp: sourceApp,
                hash: ClipboardStore.hash(text))
    }

    private func ingestRTF(_ data: Data, sourceApp: String) {
        addItem(content: "Texto formatado (RTF)", type: .rtf, data: data, sourceApp: sourceApp,
                hash: ClipboardStore.hash(data))
    }

    // MARK: - Storage

    private func addItem(
        content: String,
        type: ClipboardItemType,
        data: Data?,
        sourceApp: String,
        hash: String
    ) {
        if hash == lastHash { return }
        lastHash = hash

        var item = ClipboardItem(
            content: content,
            type: type,
            timestamp: Date(),
            data: data,
            sourceApp: sourceApp
        )
        if let data {
            item.dataPath = store.writeBlob(data, for: item.id)
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.clipboardItems.removeAll { $0.id == item.id }
            self.clipboardItems.insert(item, at: 0)
            self.trimAndPersist()
        }
    }

    private func trimAndPersist() {
        if clipboardItems.count > maxItems {
            let removed = clipboardItems.suffix(from: maxItems)
            for item in removed where !item.isFavorite {
                if let path = item.dataPath { store.deleteBlob(named: path) }
            }
            clipboardItems = Array(clipboardItems.prefix(maxItems))
        }
        store.persist(clipboardItems)
    }

    // MARK: - Public mutations

    func copyItem(_ item: ClipboardItem) {
        pasteboard.clearContents()
        switch item.type {
        case .text:
            pasteboard.setString(item.content, forType: .string)
        case .image:
            if let data = item.data ?? loadBlob(for: item) {
                pasteboard.setData(data, forType: imageType(for: data))
                if let nsImage = NSImage(data: data) {
                    pasteboard.writeObjects([nsImage])
                }
            }
        case .rtf:
            if let data = item.data ?? loadBlob(for: item) {
                pasteboard.setData(data, forType: .rtf)
            }
        case .file:
            pasteboard.setString(item.content, forType: .string)
        }
        lastChangeCount = pasteboard.changeCount
        lastHash = Self.hash(of: item)
    }

    func toggleFavorite(_ item: ClipboardItem) {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let index = self.clipboardItems.firstIndex(where: { $0.id == item.id }) else { return }
            self.clipboardItems[index].isFavorite.toggle()
            self.store.persist(self.clipboardItems)
        }
    }

    func deleteItem(_ item: ClipboardItem) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let path = item.dataPath { self.store.deleteBlob(named: path) }
            self.clipboardItems.removeAll { $0.id == item.id }
            self.store.persist(self.clipboardItems)
        }
    }

    func updateItem(_ item: ClipboardItem, newContent: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let index = self.clipboardItems.firstIndex(where: { $0.id == item.id }) else { return }
            self.clipboardItems[index].content = newContent
            self.store.persist(self.clipboardItems)
        }
    }

    func clearAll() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            for item in self.clipboardItems {
                if let path = item.dataPath { self.store.deleteBlob(named: path) }
            }
            self.clipboardItems.removeAll()
            self.store.persist(self.clipboardItems)
        }
    }

    // MARK: - Helpers

    private func loadBlob(for item: ClipboardItem) -> Data? {
        guard let path = item.dataPath else { return nil }
        return store.readBlob(named: path)
    }

    private func readFileURL(from item: NSPasteboardItem) -> URL? {
        if let urlString = item.string(forType: .fileURL),
           let url = URL(string: urlString) {
            return url
        }
        if let data = item.data(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")),
           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String],
           let firstPath = plist.first {
            return URL(fileURLWithPath: firstPath)
        }
        return nil
    }

    private func readImageData(from item: NSPasteboardItem) -> Data? {
        let imageTypes: [NSPasteboard.PasteboardType] = [
            .png, .tiff, .pdf,
            NSPasteboard.PasteboardType("public.jpeg"),
            NSPasteboard.PasteboardType("public.heic"),
            NSPasteboard.PasteboardType("public.image")
        ]
        for type in imageTypes {
            if let data = item.data(forType: type) { return data }
        }
        return nil
    }

    private func describeImage(data: Data, fileName: String?) -> String {
        let size = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
        guard let rep = NSBitmapImageRep(data: data) else {
            return fileName.map { "\($0) (\(size))" } ?? "Imagem (\(size))"
        }
        let dims = "\(rep.pixelsWide)×\(rep.pixelsHigh)"
        if let fileName { return "\(fileName) - \(dims) (\(size))" }
        return "Imagem \(dims) (\(size))"
    }

    private func fileSize(at url: URL) -> String {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? Int64 else {
            return "Tamanho desconhecido"
        }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    private func imageType(for data: Data) -> NSPasteboard.PasteboardType {
        guard data.count >= 4 else { return .png }
        let prefix = Array(data.prefix(4))
        if prefix.starts(with: [0x89, 0x50, 0x4E, 0x47]) { return .png }
        if prefix.starts(with: [0xFF, 0xD8, 0xFF]) { return NSPasteboard.PasteboardType("public.jpeg") }
        if prefix.starts(with: [0x49, 0x49, 0x2A, 0x00]) || prefix.starts(with: [0x4D, 0x4D, 0x00, 0x2A]) { return .tiff }
        if prefix.starts(with: [0x25, 0x50, 0x44, 0x46]) { return .pdf }
        return .png
    }

    private static func hash(of item: ClipboardItem) -> String {
        if let path = item.dataPath {
            return "blob:\(path)"
        }
        return ClipboardStore.hash(item.content)
    }
}
