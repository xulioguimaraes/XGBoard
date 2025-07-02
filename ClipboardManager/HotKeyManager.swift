import Foundation
import AppKit

class HotKeyManager: ObservableObject {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    
    @Published var isEnabled: Bool = false
    
    var onHotKeyPressed: (() -> Void)?
    
    init() {
        setupHotKey()
    }
    
    deinit {
        removeHotKey()
    }
    
    private func setupHotKey() {
        guard globalMonitor == nil && localMonitor == nil else { return }
        
        // Monitorar eventos globais (quando o app não está em foco)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        // Monitorar eventos locais (quando o app está em foco)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil // Consumir o evento
            }
            return event
        }
        
        if globalMonitor != nil || localMonitor != nil {
            isEnabled = true
            print("✅ Atalho Cmd+F2 registrado com sucesso!")
            
            // Verificar permissões de acessibilidade
            if !checkAccessibilityPermissions() {
                print("⚠️ Permissões de acessibilidade necessárias para atalho global")
            }
        } else {
            isEnabled = false
            print("❌ Falha ao registrar atalho de teclado")
        }
    }
    
    private func removeHotKey() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
        
        isEnabled = false
    }
    
    @discardableResult
    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        // Verificar se é Cmd+F2
        let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let expectedFlags: NSEvent.ModifierFlags = [.command]
        
        // Debug: log todas as teclas Cmd para diagnosticar
        if modifierFlags.contains(.command) {
            print("🔍 Debug: Cmd+\(HotKeyManager.keyCodeToString(event.keyCode)) detectado (keyCode: \(event.keyCode))")
        }
        
        guard modifierFlags == expectedFlags else { return false }
        
        // Verificar se é a tecla F2 (keyCode 116)
        guard event.keyCode == 116 else { return false }
        
        print("🔥 Atalho Cmd+F2 detectado! Abrindo XGBoard...")
        
        // Executar callback no main thread
        DispatchQueue.main.async { [weak self] in
            self?.onHotKeyPressed?()
        }
        
        return true
    }
    
    func toggleHotKey() {
        if isEnabled {
            removeHotKey()
        } else {
            setupHotKey()
        }
    }
    
    // Método para verificar permissões de acessibilidade
    func checkAccessibilityPermissions() -> Bool {
        return AXIsProcessTrusted()
    }
    
    // Método para solicitar permissões de acessibilidade
    func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    static func keyCodeToString(_ keyCode: UInt16) -> String {
        let keyCodeMap: [UInt16: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X", 8: "C", 9: "V",
            11: "B", 12: "Q", 13: "W", 14: "E", 15: "R", 16: "Y", 17: "T", 18: "1", 19: "2",
            20: "3", 21: "4", 22: "6", 23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8",
            29: "0", 30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L", 38: "J",
            39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/", 45: "N", 46: "M", 47: ".",
            50: "`", 65: ".", 67: "*", 69: "+", 71: "Clear", 75: "/", 76: "Enter", 78: "-",
            81: "=", 82: "0", 83: "1", 84: "2", 85: "3", 86: "4", 87: "5", 88: "6", 89: "7",
            91: "8", 92: "9", 96: "F5", 97: "F6", 98: "F7", 99: "F3", 100: "F8", 101: "F9",
            103: "F11", 105: "F13", 107: "F14", 109: "F10", 111: "F12", 113: "F16", 115: "F4",
            116: "F2", 117: "F15", 118: "F1", 119: "F17", 120: "F18", 121: "F19", 122: "F20",
            123: "Left", 124: "Right", 125: "Down", 126: "Up", 36: "Return", 48: "Tab",
            49: "Space", 51: "Delete", 53: "Escape"
        ]
        
        return keyCodeMap[keyCode] ?? "Unknown"
    }
    
    static func modifiersToString(_ modifiers: NSEvent.ModifierFlags) -> String {
        var result: [String] = []
        
        if modifiers.contains(.control) { result.append("Ctrl") }
        if modifiers.contains(.option) { result.append("Opt") }
        if modifiers.contains(.shift) { result.append("Shift") }
        if modifiers.contains(.command) { result.append("Cmd") }
        
        return result.joined(separator: "+")
    }
} 