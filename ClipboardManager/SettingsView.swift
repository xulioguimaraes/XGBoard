import SwiftUI
import ServiceManagement
import Carbon.HIToolbox

struct SettingsView: View {
    @AppStorage("maxItems") private var maxItems: Int = 500
    @AppStorage("startAtLogin") private var startAtLogin: Bool = true
    @AppStorage("darkMode") private var darkMode: Bool = true
    @AppStorage("monitoringInterval") private var monitoringInterval: Double = 0.5

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Configurações")
                .font(.largeTitle)
                .fontWeight(.bold)

            Divider()

            appearanceSection
            Divider()
            generalSection
            Divider()
            shortcutSection
            Divider()
            systemSection

            Spacer()
            footer
        }
        .padding(20)
        .frame(width: 480, height: 720)
        .preferredColorScheme(darkMode ? .dark : .light)
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aparência").font(.headline)

            Picker("Tema", selection: $darkMode) {
                Label("Escuro", systemImage: "moon.fill").tag(true)
                Label("Claro", systemImage: "sun.max.fill").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: darkMode) { value in
                updateAppearance(darkMode: value)
            }
        }
    }

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Geral").font(.headline)

            HStack {
                Text("Número máximo de itens:")
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        TextField("", value: $maxItems, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                            .onSubmit {
                                if maxItems < 10 { maxItems = 10 }
                                else if maxItems > 2000 { maxItems = 2000 }
                            }
                        Stepper("", value: $maxItems, in: 10...2000, step: 50)
                            .labelsHidden()
                    }
                    Text("Padrão: 500 itens").font(.caption2).foregroundColor(.secondary)
                }
            }

            Text("Define quantos itens do histórico serão mantidos.")
                .font(.caption)
                .foregroundColor(.secondary)

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
    }

    private var shortcutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Atalho Global").font(.headline)
            ShortcutRecorder()
            Text("Pressione a combinação para gravar. Use Cmd+Shift+V (padrão) ou outra de sua preferência.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var systemSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sistema").font(.headline)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Toggle("Iniciar automaticamente ao ligar o computador", isOn: $startAtLogin)
                        .onChange(of: startAtLogin) { value in setLoginItem(enabled: value) }
                    Text("Recomendado: manter ativo para melhor experiência")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if startAtLogin {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                }
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 12) {
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dicas:").font(.caption).fontWeight(.semibold)
                    Text("• Use o atalho global para abrir rapidamente")
                        .font(.caption2).foregroundColor(.secondary)
                    Text("• Clique no ícone da barra de status")
                        .font(.caption2).foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("XGBoard v2.0").font(.caption).foregroundColor(.secondary)
                    Text("macOS 13.0+").font(.caption2).foregroundColor(.secondary)
                }
            }
        }
    }

    private func updateAppearance(darkMode: Bool) {
        DispatchQueue.main.async {
            for window in NSApp.windows {
                window.appearance = darkMode ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
            }
        }
    }

    private func setLoginItem(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    if SMAppService.mainApp.status == .notRegistered {
                        try SMAppService.mainApp.register()
                    }
                } else {
                    if SMAppService.mainApp.status != .notRegistered {
                        try SMAppService.mainApp.unregister()
                    }
                }
            } catch {
                print("⚠️ Login item: \(error.localizedDescription)")
            }
        }
    }
}

struct ShortcutRecorder: View {
    @State private var combo: HotKeyCombo = HotKeyManager.shared.currentCombo
    @State private var isRecording = false
    @State private var monitor: Any?
    @State private var feedback: String?

    var body: some View {
        HStack(spacing: 12) {
            Text("Atalho:").frame(width: 70, alignment: .leading)

            Button(action: toggleRecording) {
                Text(isRecording ? "Pressione a combinação…" : combo.displayString)
                    .font(.system(.body, design: .monospaced))
                    .frame(minWidth: 180)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isRecording ? Color.blue.opacity(0.15) : Color.secondary.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isRecording ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())

            Button("Padrão") {
                apply(.default)
            }
            .help("Restaurar Cmd+Shift+V")

            if let feedback {
                Text(feedback)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onDisappear { stopRecording() }
    }

    private func toggleRecording() {
        if isRecording { stopRecording() } else { startRecording() }
    }

    private func startRecording() {
        isRecording = true
        feedback = nil
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handle(event: event)
            return nil
        }
    }

    private func stopRecording() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        isRecording = false
    }

    private func handle(event: NSEvent) {
        let mods = HotKeyCombo.carbonModifiers(from: event.modifierFlags)
        guard mods != 0 else {
            feedback = "Use ao menos um modificador (⌘ ⌥ ⌃ ⇧)."
            return
        }
        let candidate = HotKeyCombo(keyCode: UInt32(event.keyCode), carbonModifiers: mods)
        apply(candidate)
        stopRecording()
    }

    private func apply(_ candidate: HotKeyCombo) {
        if HotKeyManager.shared.register(candidate) {
            combo = candidate
            feedback = "Atalho atualizado: \(candidate.displayString)"
        } else {
            feedback = "Não foi possível registrar (combinação já em uso)."
        }
    }
}

#Preview {
    SettingsView()
}
