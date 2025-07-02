import Foundation
import AppKit
import Combine
import SwiftUI

class ClipboardMonitor: ObservableObject {
    @Published var clipboardItems: [ClipboardItem] = []
    @AppStorage("maxItems") private var maxItems: Int = 500
    @AppStorage("monitoringInterval") private var monitoringInterval: Double = 0.5
    
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let pasteboard = NSPasteboard.general
    
    init() {
        lastChangeCount = pasteboard.changeCount
        loadStoredItems()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: monitoringInterval, repeats: true) { [weak self] _ in
            self?.checkForClipboardChange()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkForClipboardChange() {
        let currentChangeCount = pasteboard.changeCount
        
        if currentChangeCount != lastChangeCount {
            lastChangeCount = currentChangeCount
            handleClipboardChange()
        }
    }
    
    private func handleClipboardChange() {
        guard let items = pasteboard.pasteboardItems else { return }
        
        let sourceApp = getCurrentApplication()
        
        for item in items {
            // Verificar se tem arquivo primeiro (URL de arquivo)
            if let fileURL = getFileURL(from: item) {
                let fileName = fileURL.lastPathComponent
                let fileSize = getFileSize(at: fileURL)
                let content = "\(fileName) (\(fileSize))"
                
                // Verificar se é uma imagem por extensão
                let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "heic", "webp"]
                let fileExtension = fileURL.pathExtension.lowercased()
                
                if imageExtensions.contains(fileExtension) {
                    // É uma imagem - carregar os dados
                    if let imageData = try? Data(contentsOf: fileURL) {
                        let imageInfo = getImageInfo(from: imageData, fileName: fileName)
                        addClipboardItem(content: imageInfo, type: .image, data: imageData, sourceApp: sourceApp)
                    } else {
                        addClipboardItem(content: content, type: .file, sourceApp: sourceApp)
                    }
                } else {
                    addClipboardItem(content: content, type: .file, sourceApp: sourceApp)
                }
            }
            // Verificar se tem dados de imagem diretamente na área de transferência
            else if let imageData = getImageData(from: item) {
                let imageInfo = getImageInfo(from: imageData)
                addClipboardItem(content: imageInfo, type: .image, data: imageData, sourceApp: sourceApp)
            }
            // Verificar string
            else if let stringContent = item.string(forType: .string), !stringContent.isEmpty {
                addClipboardItem(content: stringContent, type: .text, sourceApp: sourceApp)
            }
            // RTF como última opção para texto formatado
            else if let rtfData = item.data(forType: .rtf) {
                addClipboardItem(content: "Texto formatado (RTF)", type: .rtf, data: rtfData, sourceApp: sourceApp)
            }
        }
    }
    
    private func getImageData(from item: NSPasteboardItem) -> Data? {
        // Tentar diferentes formatos de imagem em ordem de preferência
        let imageTypes: [NSPasteboard.PasteboardType] = [
            .png,           // PNG
            .tiff,          // TIFF
            .pdf,           // PDF
            NSPasteboard.PasteboardType("public.jpeg"), // JPEG
            NSPasteboard.PasteboardType("public.heic"), // HEIC
            NSPasteboard.PasteboardType("public.image") // Genérico
        ]
        
        for type in imageTypes {
            if let data = item.data(forType: type) {
                return data
            }
        }
        
        return nil
    }
    
    private func getImageInfo(from data: Data, fileName: String? = nil) -> String {
        guard let imageRep = NSBitmapImageRep(data: data) else {
            let size = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
            if let fileName = fileName {
                return "\(fileName) (\(size))"
            }
            return "Imagem (\(size))"
        }
        
        let width = imageRep.pixelsWide
        let height = imageRep.pixelsHigh
        let size = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
        
        if let fileName = fileName {
            return "\(fileName) - \(width)×\(height) (\(size))"
        }
        return "Imagem \(width)×\(height) (\(size))"
    }
    
    private func getFileURL(from item: NSPasteboardItem) -> URL? {
        // Tentar obter URL de arquivo
        if let urlString = item.string(forType: NSPasteboard.PasteboardType.fileURL),
           let url = URL(string: urlString) {
            return url
        }
        
        // Tentar através de NSFilenamesPboardType
        if let data = item.data(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")),
           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String],
           let firstPath = plist.first {
            return URL(fileURLWithPath: firstPath)
        }
        
        return nil
    }
    
    private func getFileSize(at url: URL) -> String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let size = attributes[.size] as? Int64 {
                return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
            }
        } catch {
            print("Erro ao obter tamanho do arquivo: \(error)")
        }
        return "Tamanho desconhecido"
    }
    
    private func getCurrentApplication() -> String {
        let workspace = NSWorkspace.shared
        
        // Tentar obter o aplicativo ativo
        if let activeApp = workspace.frontmostApplication {
            return activeApp.localizedName ?? "Aplicativo Desconhecido"
        }
        
        return "Aplicativo Desconhecido"
    }
    
    private func addClipboardItem(content: String, type: ClipboardItemType, data: Data? = nil, sourceApp: String = "Desconhecido") {
        // Evitar duplicatas consecutivas
        if let lastItem = clipboardItems.first, lastItem.content == content {
            return
        }
        
        let newItem = ClipboardItem(
            content: content,
            type: type,
            timestamp: Date(),
            data: data,
            sourceApp: sourceApp
        )
        
        DispatchQueue.main.async {
            self.clipboardItems.insert(newItem, at: 0)
            
            // Limitar ao número máximo configurado
            if self.clipboardItems.count > self.maxItems {
                self.clipboardItems = Array(self.clipboardItems.prefix(self.maxItems))
            }
            
            self.saveItems()
        }
    }
    
    func copyItem(_ item: ClipboardItem) {
        pasteboard.clearContents()
        
        switch item.type {
        case .text:
            pasteboard.setString(item.content, forType: .string)
        case .image:
            if let data = item.data {
                // Tentar determinar o formato original da imagem
                let imageType = getImageType(from: data)
                pasteboard.setData(data, forType: imageType)
                
                // Adicionar também em outros formatos para melhor compatibilidade
                if let nsImage = NSImage(data: data) {
                    pasteboard.writeObjects([nsImage])
                }
            }
        case .rtf:
            if let data = item.data {
                pasteboard.setData(data, forType: .rtf)
            }
        case .file:
            // Para arquivos, copiar o conteúdo como texto (caminho do arquivo)
            pasteboard.setString(item.content, forType: .string)
        }
    }
    
    private func getImageType(from data: Data) -> NSPasteboard.PasteboardType {
        // Verificar assinatura dos dados para determinar o tipo de imagem
        guard data.count >= 4 else { return .png }
        
        let bytes = data.prefix(4)
        
        // PNG: 89 50 4E 47
        if bytes.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            return .png
        }
        // JPEG: FF D8 FF
        else if bytes.starts(with: [0xFF, 0xD8, 0xFF]) {
            return NSPasteboard.PasteboardType("public.jpeg")
        }
        // TIFF: 49 49 2A 00 ou 4D 4D 00 2A
        else if bytes.starts(with: [0x49, 0x49, 0x2A, 0x00]) || bytes.starts(with: [0x4D, 0x4D, 0x00, 0x2A]) {
            return .tiff
        }
        // PDF: 25 50 44 46
        else if bytes.starts(with: [0x25, 0x50, 0x44, 0x46]) {
            return .pdf
        }
        
        // Padrão: PNG
        return .png
    }
    
    func toggleFavorite(_ item: ClipboardItem) {
        DispatchQueue.main.async {
            if let index = self.clipboardItems.firstIndex(where: { $0.id == item.id }) {
                self.clipboardItems[index].isFavorite.toggle()
                self.saveItems()
            }
        }
    }
    
    func deleteItem(_ item: ClipboardItem) {
        DispatchQueue.main.async {
            self.clipboardItems.removeAll { $0.id == item.id }
            self.saveItems()
        }
    }
    
    func updateItem(_ item: ClipboardItem, newContent: String) {
        DispatchQueue.main.async {
            if let index = self.clipboardItems.firstIndex(where: { $0.id == item.id }) {
                var updatedItem = self.clipboardItems[index]
                updatedItem.content = newContent
                self.clipboardItems[index] = updatedItem
                self.saveItems()
            }
        }
    }
    
    func clearAll() {
        DispatchQueue.main.async {
            self.clipboardItems.removeAll()
            self.saveItems()
        }
    }
    
    private func saveItems() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(clipboardItems) {
            UserDefaults.standard.set(encoded, forKey: "ClipboardItems")
        }
    }
    
    private func loadStoredItems() {
        if let data = UserDefaults.standard.data(forKey: "ClipboardItems") {
            do {
                let decoded = try JSONDecoder().decode([ClipboardItem].self, from: data)
                self.clipboardItems = decoded
                print("✅ Histórico carregado com \(decoded.count) itens")
            } catch {
                print("⚠️ Erro ao carregar histórico antigo: \(error)")
                print("🔄 Iniciando com histórico limpo...")
                // Limpar dados antigos incompatíveis
                UserDefaults.standard.removeObject(forKey: "ClipboardItems")
                self.clipboardItems = []
            }
        } else {
            print("📋 Iniciando com histórico vazio")
        }
    }
} 