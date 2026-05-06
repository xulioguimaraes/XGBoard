import SwiftUI
import AppKit
import Carbon.HIToolbox

@main
struct XGBoardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate? { NSApp.delegate as? AppDelegate }

    private let clipboardMonitor = ClipboardMonitor.shared
    private let hotKeyManager = HotKeyManager.shared

    private var statusItem: NSStatusItem?
    private var pickerPanel: NSPanel?
    private var settingsWindow: NSWindow?

    /// App que estava em foreground ANTES do picker abrir — alvo do auto-paste.
    private var previousApp: NSRunningApplication?
    /// Monitor global de cliques (fora do panel) para fechar o picker.
    private var globalClickMonitor: Any?

    private let pickerSize = NSSize(width: 360, height: 460)

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusBar()
        clipboardMonitor.startMonitoring()

        hotKeyManager.onPressed = { [weak self] in
            self?.togglePicker()
        }
        if !hotKeyManager.registerCurrentCombo() {
            print("⚠️ Atalho global não pôde ser registrado — talvez outra app já o use.")
        }

        // Acessibilidade habilita auto-paste (CGEvent Cmd+V) e fechar-ao-clicar-fora
        // (NSEvent.addGlobalMonitorForEvents). Pede prompt 1x; se negado, app
        // continua funcionando — usuario apenas perde essas duas conveniencias.
        let granted = ensureAccessibilityPermission(prompt: true)
        print("✅ XGBoard pronto — atalho \(hotKeyManager.currentCombo.displayString) · acessibilidade=\(granted)")
    }

    func applicationWillTerminate(_ notification: Notification) {
        uninstallGlobalClickMonitor()
        clipboardMonitor.stopMonitoring()
        hotKeyManager.unregister()
    }

    // MARK: - Status bar

    private func setupStatusBar() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "XGBoard")
            button.action = #selector(statusBarButtonTapped(_:))
            button.target = self
        }
        item.menu = makeStatusMenu()
        statusItem = item
    }

    private func makeStatusMenu() -> NSMenu {
        let menu = NSMenu()

        let openItem = NSMenuItem(title: "Abrir XGBoard", action: #selector(openPickerFromMenu), keyEquivalent: "o")
        openItem.target = self
        menu.addItem(openItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Configurações…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let helpItem = NSMenuItem(title: "Como Usar", action: #selector(showHelp), keyEquivalent: "")
        helpItem.target = self
        menu.addItem(helpItem)

        let aboutItem = NSMenuItem(title: "Sobre", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Sair", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc private func statusBarButtonTapped(_ sender: Any?) {
        togglePicker(anchorAtMouse: false)
    }

    // MARK: - Picker panel

    private func togglePicker(anchorAtMouse: Bool = true) {
        if let panel = pickerPanel, panel.isVisible {
            dismissPicker(restoreFocus: true, autoPaste: false)
        } else {
            openPicker(anchorAtMouse: anchorAtMouse)
        }
    }

    @objc private func openPickerFromMenu() {
        openPicker(anchorAtMouse: false)
    }

    private func openPicker(anchorAtMouse: Bool) {
        // Captura quem estava em foreground ANTES de ativarmos o nosso app.
        if let frontApp = NSWorkspace.shared.frontmostApplication,
           frontApp.bundleIdentifier != Bundle.main.bundleIdentifier {
            previousApp = frontApp
        }

        let panel = pickerPanel ?? makePickerPanel()
        pickerPanel = panel

        if anchorAtMouse {
            position(panel, near: NSEvent.mouseLocation)
        } else if let button = statusItem?.button, let window = button.window {
            let buttonFrame = window.convertToScreen(button.convert(button.bounds, to: nil))
            let anchor = NSPoint(x: buttonFrame.midX, y: buttonFrame.minY)
            position(panel, near: anchor)
        } else {
            position(panel, near: NSEvent.mouseLocation)
        }

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        installGlobalClickMonitor()
    }

    /// Seleciona um item: copia para o clipboard, fecha o picker, restaura o app
    /// anterior e (se Acessibilidade estiver concedida) dispara Cmd+V automatico.
    func pickAndPaste(_ item: ClipboardItem) {
        clipboardMonitor.copyItem(item)
        dismissPicker(restoreFocus: true, autoPaste: true)
    }

    func dismissPicker(restoreFocus: Bool, autoPaste: Bool) {
        uninstallGlobalClickMonitor()
        pickerPanel?.orderOut(nil)

        let target = previousApp
        previousApp = nil

        guard restoreFocus, let target else { return }
        target.activate(options: [.activateIgnoringOtherApps])

        guard autoPaste else { return }
        // Pequeno delay para o app anterior recuperar foco antes do post.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            Self.simulatePasteShortcut()
        }
    }

    private func installGlobalClickMonitor() {
        guard globalClickMonitor == nil else { return }
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        ) { [weak self] _ in
            self?.dismissPicker(restoreFocus: true, autoPaste: false)
        }
    }

    private func uninstallGlobalClickMonitor() {
        if let monitor = globalClickMonitor {
            NSEvent.removeMonitor(monitor)
        }
        globalClickMonitor = nil
    }

    /// Posta Cmd+V no app frontmost (que ja foi reativado).
    /// Requer permissao de Acessibilidade.
    private static func simulatePasteShortcut() {
        let source = CGEventSource(stateID: .combinedSessionState)
        let keyV = CGKeyCode(kVK_ANSI_V)
        guard
            let down = CGEvent(keyboardEventSource: source, virtualKey: keyV, keyDown: true),
            let up = CGEvent(keyboardEventSource: source, virtualKey: keyV, keyDown: false)
        else { return }
        down.flags = .maskCommand
        up.flags = .maskCommand
        down.post(tap: .cgAnnotatedSessionEventTap)
        up.post(tap: .cgAnnotatedSessionEventTap)
    }

    /// Pede permissao de Acessibilidade ao sistema (mostra prompt apenas uma vez).
    @discardableResult
    func ensureAccessibilityPermission(prompt: Bool = true) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
        let options: [String: Bool] = [key as String: prompt]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    private func makePickerPanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: pickerSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .popUpMenu
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.becomesKeyOnlyIfNeeded = false
        panel.worksWhenModal = true
        panel.delegate = self
        panel.isReleasedWhenClosed = false

        let view = ContentView().environmentObject(clipboardMonitor)
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(origin: .zero, size: pickerSize)
        panel.contentView = hosting
        return panel
    }

    private func position(_ window: NSWindow, near point: NSPoint) {
        let size = window.frame.size
        let screen = NSScreen.screens.first(where: { NSMouseInRect(point, $0.frame, false) })
            ?? NSScreen.main
            ?? NSScreen.screens.first

        var origin = NSPoint(x: point.x - 16, y: point.y - size.height + 16)

        if let visible = screen?.visibleFrame {
            origin.x = max(visible.minX + 8, min(origin.x, visible.maxX - size.width - 8))
            origin.y = max(visible.minY + 8, min(origin.y, visible.maxY - size.height - 8))
        }
        window.setFrameOrigin(origin)
    }

    // MARK: - Settings window

    @objc private func openSettings() {
        if let window = settingsWindow {
            present(window: window, activate: true)
            return
        }
        let view = SettingsView()
        let window = makeWindow(
            title: "Configurações do XGBoard",
            size: NSSize(width: 480, height: 720),
            rootView: view,
            resizable: false
        )
        settingsWindow = window
        present(window: window, activate: true)
    }

    private func makeWindow<RootView: View>(
        title: String,
        size: NSSize,
        rootView: RootView,
        resizable: Bool = true
    ) -> NSWindow {
        var styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable]
        if resizable { styleMask.insert(.resizable) }

        let hosting = NSHostingController(rootView: rootView)
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.contentViewController = hosting
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        return window
    }

    private func present(window: NSWindow, activate: Bool) {
        if activate { NSApp.activate(ignoringOtherApps: true) }
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }

    // MARK: - Menu actions

    @objc private func showHelp() {
        let alert = NSAlert()
        alert.messageText = "Como Usar o XGBoard"
        alert.informativeText = """
        • \(hotKeyManager.currentCombo.displayString) abre o XGBoard onde estiver o cursor.
        • Digite para filtrar; ↑/↓ para navegar.
        • ↩ ou clique no item: copia E cola automaticamente no campo onde voce estava.
        • ⎋ ou clique fora do picker: fecha sem copiar.
        • Clique direito em um item para favoritar ou apagar.

        Auto-paste e clique-fora-fecha exigem permissao de Acessibilidade
        (Configuracoes do Sistema → Privacidade e Seguranca → Acessibilidade).
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Entendi")
        alert.runModal()
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Sobre o XGBoard"
        alert.informativeText = """
        XGBoard v2.0
        Gerenciador de área de transferência para macOS.

        © 2025 Julio Carvalho Guimarães
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Fechar")
        alert.runModal()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - NSWindowDelegate

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if window === settingsWindow { settingsWindow = nil }
        if window === pickerPanel { pickerPanel = nil }
    }

    func windowDidResignKey(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              window === pickerPanel else { return }
        window.orderOut(nil)
    }
}
