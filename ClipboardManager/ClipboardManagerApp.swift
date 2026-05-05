import SwiftUI
import AppKit

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
    private let clipboardMonitor = ClipboardMonitor.shared
    private let hotKeyManager = HotKeyManager.shared

    private var statusItem: NSStatusItem?
    private var mainWindow: NSWindow?
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusBar()
        clipboardMonitor.startMonitoring()

        hotKeyManager.onPressed = { [weak self] in
            self?.toggleMainWindow()
        }
        if !hotKeyManager.registerCurrentCombo() {
            print("⚠️ Atalho global não pôde ser registrado — talvez outra app já o use.")
        }

        print("✅ XGBoard pronto — atalho \(hotKeyManager.currentCombo.displayString)")
    }

    func applicationWillTerminate(_ notification: Notification) {
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
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        item.menu = makeStatusMenu()
        statusItem = item
    }

    private func makeStatusMenu() -> NSMenu {
        let menu = NSMenu()

        let openItem = NSMenuItem(title: "Abrir XGBoard", action: #selector(openMainWindow), keyEquivalent: "o")
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
        toggleMainWindow()
    }

    // MARK: - Windows

    private func toggleMainWindow() {
        if let window = mainWindow, window.isVisible {
            window.performClose(nil)
        } else {
            openMainWindow()
        }
    }

    @objc private func openMainWindow() {
        if let window = mainWindow {
            present(window: window)
            return
        }
        let view = ContentView().environmentObject(clipboardMonitor)
        let window = makeWindow(
            title: "XGBoard",
            size: NSSize(width: 900, height: 600),
            rootView: view
        )
        mainWindow = window
        present(window: window)
    }

    @objc private func openSettings() {
        if let window = settingsWindow {
            present(window: window)
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
        present(window: window)
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

    private func present(window: NSWindow) {
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }

    // MARK: - Menu actions

    @objc private func showHelp() {
        let alert = NSAlert()
        alert.messageText = "Como Usar o XGBoard"
        alert.informativeText = """
        Funcionalidades:
        • Monitoramento automático: tudo que você copiar (Cmd+C) é salvo no histórico.
        • Atalho global: \(hotKeyManager.currentCombo.displayString) abre o XGBoard rapidamente.
        • Lista à esquerda, detalhes à direita.
        • Favoritos: clique no coração.

        Como usar:
        1. Copie qualquer texto, imagem ou arquivo normalmente.
        2. Use o atalho ou o ícone na barra de status.
        3. Clique para ver detalhes; duplo-clique para copiar de volta.
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
        if window === mainWindow { mainWindow = nil }
        if window === settingsWindow { settingsWindow = nil }
    }
}
