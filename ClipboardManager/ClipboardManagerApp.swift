import SwiftUI
import AppKit

@main
struct XGBoardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
        
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var clipboardMonitor = ClipboardMonitor()
    var hotKeyManager = HotKeyManager()
    var settingsWindow: NSWindow?
    var mainWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 XGBoard iniciando...")
        
        // Configurar app como accessory (apenas barra de status)
        NSApp.setActivationPolicy(.accessory)
        
        // Criar item na barra de status
        setupStatusBar()
        
        // Iniciar monitoramento da área de transferência
        clipboardMonitor.startMonitoring()
        
        // Configurar atalho de teclado global (Cmd+F2)
        setupHotKey()
        
        // Verificar permissões de acessibilidade após um tempo
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.checkAccessibilityPermissions()
        }
        
        print("✅ XGBoard iniciado com sucesso!")
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem?.button {
            statusButton.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "XGBoard")
            statusButton.action = #selector(statusBarButtonTapped)
            statusButton.target = self
        }
        
        setupStatusBarMenu()
    }
    
    private func setupHotKey() {
        hotKeyManager.onHotKeyPressed = { [weak self] in
            self?.openMainWindow()
        }
    }
    
    private func checkAccessibilityPermissions() {
        if !hotKeyManager.checkAccessibilityPermissions() {
            showAccessibilityAlert()
        }
    }
    
    @objc func statusBarButtonTapped() {
        openMainWindow()
    }
    
    private func setupStatusBarMenu() {
        let menu = NSMenu()
        
        // Abrir
        let openItem = NSMenuItem(title: "Abrir XGBoard", action: #selector(openMainWindow), keyEquivalent: "o")
        openItem.target = self
        menu.addItem(openItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Configurações
        let settingsItem = NSMenuItem(title: "Configurações", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Ajuda
        let helpItem = NSMenuItem(title: "Como Usar", action: #selector(showHelp), keyEquivalent: "h")
        helpItem.target = self
        menu.addItem(helpItem)
        
        // Sobre
        let aboutItem = NSMenuItem(title: "Sobre", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Fechar
        let quitItem = NSMenuItem(title: "Fechar", action: #selector(quitApplication), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func openMainWindow() {
        print("🚀 Abrindo janela principal...")
        
        DispatchQueue.main.async {
            // Sempre criar uma nova janela para garantir que funcione
            print("🔨 Criando nova janela principal...")
            
            let contentView = ContentView()
            let hostingController = NSHostingController(rootView: contentView)
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 900, height: 600),
                styleMask: [.titled, .closable, .resizable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            
            window.title = "XGBoard - Gerenciador de Área de Transferência"
            window.contentViewController = hostingController
            window.center()
            window.isReleasedWhenClosed = false
            window.delegate = self
            
            // Definir como janela principal
            self.mainWindow = window
            
            // Mostrar janela de forma simples e direta
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            window.makeKey()
            
            print("✅ Janela principal criada e exibida!")
        }
    }
    
    @objc private func openSettings() {
        print("🔧 Abrindo configurações...")
        
        DispatchQueue.main.async {
            // Criar nova janela de configurações
            print("🔨 Criando nova janela de configurações")
            
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 650),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            
            window.title = "Configurações do XGBoard"
            window.contentViewController = hostingController
            window.center()
            window.isReleasedWhenClosed = false
            window.delegate = self
            
            self.settingsWindow = window
            
            // Mostrar janela de forma simples
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            window.makeKey()
            
            print("✅ Janela de configurações criada e exibida!")
        }
    }
    
    @objc private func showHelp() {
        let alert = NSAlert()
        alert.messageText = "Como Usar o XGBoard"
        alert.informativeText = """
        📋 FUNCIONALIDADES PRINCIPAIS:
        
        • Monitoramento Automático: Tudo que você copiar (Cmd+C) será salvo automaticamente
        
        • Atalho Global: Use Cmd+F2 para abrir rapidamente o histórico
        
        • Interface Dividida: Lista de itens à esquerda, detalhes completos à direita
        
        • Favoritos: Clique no ❤️ para marcar itens importantes
        
        📱 COMO USAR:
        
        1. Copie qualquer texto, imagem ou arquivo normalmente
        2. Clique no ícone da barra de status OU use Cmd+F2
        3. Selecione um item para ver detalhes completos
        4. Duplo-clique OU use o botão 'Copiar' para reutilizar
        5. Use o filtro 'Favoritos' para ver apenas itens marcados
        6. Clique em 'Editar' para modificar textos como bloco de notas
        
        🔍 RECURSOS EXTRAS:
        
        • Busca em tempo real no histórico
        • Filtros por tipo (texto, imagem, RTF, arquivo)
        • Suporte a múltiplos formatos de imagem e arquivos
        • Edição de texto intuitiva (clique para editar)
        • Detecção automática do aplicativo de origem
        • Histórico persistente entre sessões
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Entendi")
        alert.runModal()
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Sobre o XGBoard"
        alert.informativeText = """
        📱 XGBoard v1.1
        
        Desenvolvido por: Julio Carvalho Guimarães
        
        Um gerenciador de área de transferência nativo para macOS, inspirado nas funcionalidades do Windows. 
        
        Recursos principais:
        • Histórico completo de itens copiados
        • Suporte a texto, imagens e RTF
        • Atalhos de teclado globais
        • Sistema de favoritos
        • Interface nativa em SwiftUI
        
        © 2025 Julio Carvalho Guimarães
        Todos os direitos reservados.
        
        Tecnologias utilizadas: SwiftUI, AppKit, Combine
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Fechar")
        alert.runModal()
    }
    
    @objc private func quitApplication() {
        NSApplication.shared.terminate(nil)
    }
    
    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Permissão de Acessibilidade Necessária"
        alert.informativeText = """
        Para que os atalhos de teclado funcionem globalmente (Cmd+F2), é necessário conceder permissão de acessibilidade ao XGBoard.
        
        ⚠️ IMPORTANTE: Se você já tinha uma versão anterior instalada, remova-a primeiro das configurações de acessibilidade.
        
        Você será redirecionado para as Configurações do Sistema.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Abrir Configurações")
        alert.addButton(withTitle: "Mais Tarde")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            hotKeyManager.requestAccessibilityPermissions()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("🔄 XGBoard finalizando...")
        clipboardMonitor.stopMonitoring()
    }
}

// MARK: - NSWindowDelegate
extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            if window == settingsWindow {
                print("🔄 Limpando referência da janela de configurações")
                settingsWindow = nil
            } else if window == mainWindow {
                print("🔄 Limpando referência da janela principal")
                mainWindow = nil
            }
            
            // Verificar se não há mais janelas e voltar para accessory
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let visibleWindows = NSApp.windows.filter { $0.isVisible && !$0.title.isEmpty }
                
                if visibleWindows.isEmpty {
                    print("🔄 Voltando para modo accessory - não há janelas visíveis")
                    NSApp.setActivationPolicy(.accessory)
                }
            }
        }
    }

} 