import AppKit
import Carbon.HIToolbox

struct HotKeyCombo: Equatable, Codable {
    var keyCode: UInt32
    var carbonModifiers: UInt32

    static let `default` = HotKeyCombo(
        keyCode: UInt32(kVK_ANSI_V),
        carbonModifiers: UInt32(cmdKey | shiftKey)
    )

    var displayString: String {
        var parts: [String] = []
        if carbonModifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        if carbonModifiers & UInt32(optionKey) != 0  { parts.append("⌥") }
        if carbonModifiers & UInt32(shiftKey) != 0   { parts.append("⇧") }
        if carbonModifiers & UInt32(cmdKey) != 0     { parts.append("⌘") }
        parts.append(HotKeyCombo.keyName(for: keyCode))
        return parts.joined()
    }

    static func keyName(for keyCode: UInt32) -> String {
        switch Int(keyCode) {
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_Space: return "Space"
        case kVK_Return: return "↩"
        case kVK_Tab: return "⇥"
        case kVK_Escape: return "⎋"
        case kVK_F1: return "F1"
        case kVK_F2: return "F2"
        case kVK_F3: return "F3"
        case kVK_F4: return "F4"
        case kVK_F5: return "F5"
        case kVK_F6: return "F6"
        case kVK_F7: return "F7"
        case kVK_F8: return "F8"
        case kVK_F9: return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        default: return "key#\(keyCode)"
        }
    }

    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var mods: UInt32 = 0
        if flags.contains(.command) { mods |= UInt32(cmdKey) }
        if flags.contains(.shift)   { mods |= UInt32(shiftKey) }
        if flags.contains(.option)  { mods |= UInt32(optionKey) }
        if flags.contains(.control) { mods |= UInt32(controlKey) }
        return mods
    }
}

final class HotKeyManager {
    static let shared = HotKeyManager()

    private static let signature: OSType = {
        let chars: [UInt8] = [0x58, 0x47, 0x42, 0x44]
        return (OSType(chars[0]) << 24) | (OSType(chars[1]) << 16) | (OSType(chars[2]) << 8) | OSType(chars[3])
    }()

    private static let keyCodeKey = "hotkey.keyCode"
    private static let modifiersKey = "hotkey.carbonModifiers"

    var onPressed: (() -> Void)?

    private(set) var currentCombo: HotKeyCombo
    private(set) var isRegistered = false

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    private init() {
        let defaults = UserDefaults.standard
        let storedKey = defaults.object(forKey: HotKeyManager.keyCodeKey) as? UInt32
        let storedMods = defaults.object(forKey: HotKeyManager.modifiersKey) as? UInt32
        if let storedKey, let storedMods, storedMods != 0 {
            currentCombo = HotKeyCombo(keyCode: storedKey, carbonModifiers: storedMods)
        } else {
            currentCombo = .default
        }
        installHandlerIfNeeded()
    }

    @discardableResult
    func registerCurrentCombo() -> Bool {
        register(currentCombo)
    }

    @discardableResult
    func register(_ combo: HotKeyCombo) -> Bool {
        unregister()
        installHandlerIfNeeded()

        guard combo.carbonModifiers != 0 else {
            print("⚠️ HotKey: combinação sem modificadores não é permitida")
            return false
        }

        let hotKeyID = EventHotKeyID(signature: HotKeyManager.signature, id: 1)
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(
            combo.keyCode,
            combo.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &ref
        )

        guard status == noErr, let ref else {
            print("❌ HotKey: RegisterEventHotKey falhou (status \(status))")
            isRegistered = false
            return false
        }

        hotKeyRef = ref
        currentCombo = combo
        isRegistered = true

        let defaults = UserDefaults.standard
        defaults.set(combo.keyCode, forKey: HotKeyManager.keyCodeKey)
        defaults.set(combo.carbonModifiers, forKey: HotKeyManager.modifiersKey)

        print("✅ HotKey registrado: \(combo.displayString)")
        return true
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        isRegistered = false
    }

    private func installHandlerIfNeeded() {
        guard eventHandler == nil else { return }
        var spec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            HotKeyManager.handlerCallback,
            1,
            &spec,
            selfPtr,
            &eventHandler
        )
        if status != noErr {
            print("❌ HotKey: InstallEventHandler falhou (status \(status))")
        }
    }

    private static let handlerCallback: EventHandlerUPP = { _, eventRef, userData in
        guard let userData, let eventRef else { return OSStatus(eventNotHandledErr) }
        let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()

        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            eventRef,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )
        guard status == noErr, hotKeyID.signature == HotKeyManager.signature else {
            return OSStatus(eventNotHandledErr)
        }

        DispatchQueue.main.async {
            manager.onPressed?()
        }
        return noErr
    }

    deinit {
        unregister()
        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }
}
