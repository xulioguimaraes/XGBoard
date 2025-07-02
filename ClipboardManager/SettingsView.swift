import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("maxItems") private var maxItems: Int = 500
    @AppStorage("startAtLogin") private var startAtLogin: Bool = true
    @AppStorage("showInDock") private var showInDock: Bool = false
    @AppStorage("darkMode") private var darkMode: Bool = true
    @AppStorage("monitoringInterval") private var monitoringInterval: Double = 0.5
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Configurações")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Aparência")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                  
                    
                    Picker("Tema", selection: $darkMode) {
                        HStack {
                            Image(systemName: "moon.fill")
                           
                        }
                        .tag(true)
                        
                        HStack {
                            Image(systemName: "sun.max.fill")
                            
                        }
                        .tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: darkMode) { value in
                        updateAppearance(darkMode: value)
                    }
                }
                
                Toggle("Mostrar no Dock", isOn: $showInDock)
                    .onChange(of: showInDock) { value in
                        updateAppPolicy(showInDock: value)
                    }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Geral")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Número máximo de itens:")
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack {
                                TextField("", value: $maxItems, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 80)
                                    .onSubmit {
                                        // Validar entrada
                                        if maxItems < 10 {
                                            maxItems = 10
                                        } else if maxItems > 2000 {
                                            maxItems = 2000
                                        }
                                    }
                                
                                Stepper("", value: $maxItems, in: 10...2000, step: 50)
                                    .labelsHidden()
                            }
                            
                            Text("Padrão: 500 itens")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("Define quantos itens do histórico serão mantidos em memória.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
                
                HStack {
                    Text("Intervalo de monitoramento:")
                    Spacer()
                    Picker("Intervalo", selection: $monitoringInterval) {
                        Text("Rápido (0.1s)").tag(0.1)
                        Text("Normal (0.5s)").tag(0.5)
                        Text("Lento (1.0s)").tag(1.0)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Sistema")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Toggle("Iniciar automaticamente ao ligar o computador", isOn: $startAtLogin)
                                .onChange(of: startAtLogin) { value in
                                    setLoginItem(enabled: value)
                                }
                            
                            Text("Recomendado: Manter ativo para melhor experiência")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if startAtLogin {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("💡 Dicas:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Text("• Use Cmd+F2 para abrir rapidamente")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("• Clique no ícone da barra de status")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("XGBoard v1.1")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("macOS 13.0+")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .frame(width: 480, height: 650)
        .preferredColorScheme(darkMode ? .dark : .light)
    }
    
    private func updateAppearance(darkMode: Bool) {
        DispatchQueue.main.async {
            for window in NSApp.windows {
                window.appearance = darkMode ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
            }
            
            print("🎨 Tema alterado para: \(darkMode ? "Escuro" : "Claro")")
        }
    }
    
    private func updateAppPolicy(showInDock: Bool) {
        DispatchQueue.main.async {
            // Mudanças de política de ativação agora são gerenciadas pelo AppDelegate
            // para evitar crashes relacionados ao gerenciamento de janelas
            print("🔄 Configuração de política de ativação alterada: \(showInDock ? "Dock visível" : "Apenas barra de status")")
            
            if showInDock {
                NSApp.setActivationPolicy(.regular)
            } else {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
    
    private func setLoginItem(enabled: Bool) {
        if enabled {
            // Usar implementação simplificada com ServiceManagement framework para macOS 13+
            if #available(macOS 13.0, *) {
                do {
                    if SMAppService.mainApp.status == .notRegistered {
                        try SMAppService.mainApp.register()
                        print("✅ XGBoard adicionado aos itens de login")
                    } else {
                        print("ℹ️ XGBoard já está nos itens de login")
                    }
                } catch {
                    print("❌ Erro ao adicionar aos itens de login: \(error)")
                    // Fallback para método manual
                    addToLoginItemsManually()
                }
            } else {
                // Fallback para versões mais antigas
                addToLoginItemsManually()
            }
        } else {
            // Remover dos itens de login
            if #available(macOS 13.0, *) {
                do {
                    if SMAppService.mainApp.status != .notRegistered {
                        try SMAppService.mainApp.unregister()
                        print("✅ XGBoard removido dos itens de login")
                    } else {
                        print("ℹ️ XGBoard não estava nos itens de login")
                    }
                } catch {
                    print("❌ Erro ao remover dos itens de login: \(error)")
                    // Fallback para método manual
                    removeFromLoginItemsManually()
                }
            } else {
                // Fallback para versões mais antigas
                removeFromLoginItemsManually()
            }
        }
    }
    
    private func addToLoginItemsManually() {
        print("🔄 Usando método manual para adicionar aos itens de login")
        print("💡 Para ativar manualmente: Configurações do Sistema > Geral > Itens de Login")
    }
    
    private func removeFromLoginItemsManually() {
        print("🔄 Usando método manual para remover dos itens de login")
        print("💡 Para desativar manualmente: Configurações do Sistema > Geral > Itens de Login")
    }
}

#Preview {
    SettingsView()
} 
