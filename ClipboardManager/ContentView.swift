import SwiftUI
import AppKit
import Carbon.HIToolbox

struct ContentView: View {
    @EnvironmentObject var monitor: ClipboardMonitor
    @State private var searchText = ""
    @State private var selection: Int = 0
    @State private var keyboardScrollTrigger = UUID()
    @State private var keyMonitor: Any?
    @FocusState private var searchFocused: Bool

    private let panelWidth: CGFloat = 360
    private let panelHeight: CGFloat = 460

    var filteredItems: [ClipboardItem] {
        guard !searchText.isEmpty else { return monitor.clipboardItems }
        return monitor.clipboardItems.filter {
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchHeader
            Divider().opacity(0.3)
            list
            Divider().opacity(0.3)
            footer
        }
        .frame(width: panelWidth, height: panelHeight)
        .background(VisualEffectBackground(material: .popover))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .onAppear { setupKeyHandling() }
        .onDisappear { teardownKeyHandling() }
        .onChange(of: searchText) { _ in selection = 0 }
    }

    // MARK: - Sections

    private var searchHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            TextField("Buscar no histórico…", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .focused($searchFocused)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .help("Limpar busca")
            }
            CloseButton(action: closePanel)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
    }

    private var list: some View {
        Group {
            if filteredItems.isEmpty {
                emptyState
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                                CompactRow(
                                    item: item,
                                    isSelected: index == selection,
                                    onPick: { pick(at: index) },
                                    onToggleFavorite: { monitor.toggleFavorite(item) },
                                    onDelete: { monitor.deleteItem(item) }
                                )
                                .id(index)
                                .onHover { hovering in
                                    if hovering { selection = index }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onChange(of: keyboardScrollTrigger) { _ in
                        withAnimation(.linear(duration: 0.08)) {
                            proxy.scrollTo(selection, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: searchText.isEmpty ? "doc.on.clipboard" : "magnifyingglass")
                .font(.system(size: 28))
                .foregroundStyle(.tertiary)
            Text(searchText.isEmpty ? "Nenhum item copiado ainda" : "Nada encontrado")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footer: some View {
        HStack(spacing: 10) {
            Text("\(filteredItems.count) itens")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Spacer()
            ShortcutHint(key: "↩", label: "Copiar")
            ShortcutHint(key: "⎋", label: "Fechar")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Actions

    private func pick(at index: Int) {
        guard filteredItems.indices.contains(index) else { return }
        monitor.copyItem(filteredItems[index])
        closePanel()
    }

    private func closePanel() {
        if let panel = NSApp.keyWindow ?? NSApp.windows.first(where: { $0.isVisible && $0 is NSPanel }) {
            panel.orderOut(nil)
        }
    }

    private func setupKeyHandling() {
        searchFocused = true
        selection = 0
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handle(event: event) ? nil : event
        }
    }

    private func teardownKeyHandling() {
        if let m = keyMonitor { NSEvent.removeMonitor(m) }
        keyMonitor = nil
    }

    private func handle(event: NSEvent) -> Bool {
        switch Int(event.keyCode) {
        case kVK_DownArrow:
            selection = min(selection + 1, max(filteredItems.count - 1, 0))
            keyboardScrollTrigger = UUID()
            return true
        case kVK_UpArrow:
            selection = max(selection - 1, 0)
            keyboardScrollTrigger = UUID()
            return true
        case kVK_Return, kVK_ANSI_KeypadEnter:
            pick(at: selection)
            return true
        case kVK_Escape:
            closePanel()
            return true
        default:
            return false
        }
    }
}

// MARK: - Row

private struct CompactRow: View {
    let item: ClipboardItem
    let isSelected: Bool
    let onPick: () -> Void
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            icon
            content
            Spacer(minLength: 6)
            timestamp
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isSelected ? Color.accentColor.opacity(0.85) : Color.clear)
        )
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .onTapGesture { onPick() }
        .contextMenu {
            Button("Copiar") { onPick() }
            Button(item.isFavorite ? "Remover dos Favoritos" : "Favoritar") { onToggleFavorite() }
            Divider()
            Button("Apagar", role: .destructive) { onDelete() }
        }
        .help(item.content)
    }

    private var icon: some View {
        Group {
            if item.type == .image, let data = item.data, let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 22, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            } else {
                Image(systemName: item.type.iconName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? Color.white : Color.secondary)
                    .frame(width: 22, height: 22)
            }
        }
    }

    private var content: some View {
        HStack(spacing: 4) {
            if item.isFavorite {
                Image(systemName: "heart.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(isSelected ? Color.white : Color.pink)
            }
            Text(displayText)
                .font(.system(size: 12, design: item.type == .text ? .monospaced : .default))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    private var displayText: String {
        item.content
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
    }

    private var timestamp: some View {
        Text(item.formattedTimestamp)
            .font(.system(size: 10))
            .foregroundStyle(isSelected ? Color.white.opacity(0.85) : Color.secondary)
    }
}

// MARK: - Close button

private struct CloseButton: View {
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(hovering ? Color.red : Color.primary.opacity(0.12))
                    .frame(width: 14, height: 14)
                Image(systemName: "xmark")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(hovering ? Color.white : Color.secondary)
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help("Fechar (⎋)")
    }
}

// MARK: - Footer hint

private struct ShortcutHint: View {
    let key: String
    let label: String
    var body: some View {
        HStack(spacing: 3) {
            Text(key)
                .font(.system(size: 10, weight: .medium))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.primary.opacity(0.08))
                )
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Vibrancy background

struct VisualEffectBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    var state: NSVisualEffectView.State = .active

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
    }
}

#Preview {
    ContentView()
        .environmentObject(ClipboardMonitor.shared)
}
