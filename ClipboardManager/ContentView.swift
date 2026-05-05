import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardMonitor: ClipboardMonitor
    @State private var searchText = ""
    @State private var selectedType: ClipboardItemType? = nil
    @State private var selectedItem: ClipboardItem? = nil
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var showOnlyFavorites = false
    @AppStorage("darkMode") private var darkMode: Bool = true
    
    var filteredItems: [ClipboardItem] {
        var items = clipboardMonitor.clipboardItems
        
        // Filtrar por favoritos
        if showOnlyFavorites {
            items = items.filter { $0.isFavorite }
        }
        
        // Filtrar por tipo
        if let selectedType = selectedType {
            items = items.filter { $0.type == selectedType }
        }
        
        // Filtrar por texto de busca
        if !searchText.isEmpty {
            items = items.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
        
        return items
    }
    
    var body: some View {
        HSplitView {
            // Lado esquerdo - Lista de itens
            VStack(spacing: 0) {
                // Barra de ferramentas
                VStack(spacing: 8) {
                    HStack {
                        SearchBar(text: $searchText)
                        
                        Picker("Tipo", selection: $selectedType) {
                            Text("Todos").tag(nil as ClipboardItemType?)
                            ForEach(ClipboardItemType.allCases, id: \.self) { type in
                                Label(type.displayName, systemImage: type.iconName)
                                    .tag(type as ClipboardItemType?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 120)
                        
                        Button(action: clipboardMonitor.clearAll) {
                            Image(systemName: "trash")
                        }
                        .help("Limpar tudo")
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Filtros adicionais
                    HStack {
                        Button(action: { showOnlyFavorites.toggle() }) {
                            HStack {
                                Image(systemName: showOnlyFavorites ? "heart.fill" : "heart")
                                    .foregroundColor(showOnlyFavorites ? .red : .secondary)
                                Text("Favoritos")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(showOnlyFavorites ? Color.red.opacity(0.1) : Color.clear)
                        )
                        
                        Spacer()
                        
                        if showOnlyFavorites {
                            Text("\(filteredItems.count) favoritos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(filteredItems.count) itens")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                
                Divider()
                
                // Lista de itens
                if filteredItems.isEmpty {
                    EmptyStateView(hasItems: !clipboardMonitor.clipboardItems.isEmpty)
                } else {
                    List(selection: $selectedItem) {
                        ForEach(filteredItems) { item in
                            ClipboardItemRow(
                                item: item, 
                                clipboardMonitor: clipboardMonitor,
                                isSelected: selectedItem?.id == item.id,
                                onCopy: { showCopyToast() },
                                onSelect: { selectedItem = item },
                                onToggleFavorite: { clipboardMonitor.toggleFavorite(item) }
                            )
                            .tag(item)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .frame(width: 400) // Largura fixa para o lado esquerdo
            
            // Lado direito - Detalhes do item selecionado
            DetailView(
                selectedItem: selectedItem,
                clipboardMonitor: clipboardMonitor,
                onCopy: { showCopyToast() }
            )
                .frame(minWidth: 300)
        }
        .frame(minWidth: 700, minHeight: 500) // Tamanho mínimo, mas redimensionável
        .navigationTitle("XGBoard")
        .preferredColorScheme(darkMode ? .dark : .light)
        .overlay(
            // Toast para feedback de cópia
            ToastView(message: toastMessage, isShowing: $showToast)
                .animation(.easeInOut(duration: 0.3), value: showToast),
            alignment: .top
        )
    }
    
    private func showCopyToast() {
        toastMessage = "Item copiado!"
        withAnimation {
            showToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showToast = false
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Buscar...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let clipboardMonitor: ClipboardMonitor
    let isSelected: Bool
    let onCopy: () -> Void
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: item.type.iconName)
                        .foregroundColor(isSelected ? .blue : .secondary)
                        .frame(width: 16)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.truncatedContent)
                            .lineLimit(2)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(isSelected ? .primary : .primary)
                    }
                    
                    Spacer(minLength: 0)
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            if item.isFavorite {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            
                            Text(item.formattedTimestamp)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if item.content.count > 100 {
                    Text("\(item.content.count) caracteres")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Botões sempre presentes para manter layout estável
            HStack(spacing: 2) {
                Button(action: {
                    onToggleFavorite()
                }) {
                    Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(item.isFavorite ? .red : .secondary)
                        .frame(width: 14, height: 14)
                }
                .help(item.isFavorite ? "Remover dos favoritos" : "Adicionar aos favoritos")
                .buttonStyle(PlainButtonStyle())
                .opacity(isHovering ? 1.0 : 0.0)
                
                Button(action: {
                    clipboardMonitor.copyItem(item)
                    onCopy()
                }) {
                    Image(systemName: "doc.on.clipboard")
                        .foregroundColor(.blue)
                        .frame(width: 14, height: 14)
                }
                .help("Copiar")
                .buttonStyle(PlainButtonStyle())
                .opacity(isHovering ? 1.0 : 0.0)
                
                Button(action: {
                    clipboardMonitor.deleteItem(item)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 14, height: 14)
                }
                .help("Deletar")
                .buttonStyle(PlainButtonStyle())
                .opacity(isHovering ? 1.0 : 0.0)
            }
            .frame(width: 50, height: 20) // Frame maior para 3 botões
            .animation(.easeInOut(duration: 0.15), value: isHovering)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
                    .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .onTapGesture {
            onSelect()
        }
        .onTapGesture(count: 2) {
            clipboardMonitor.copyItem(item)
            onCopy()
        }
        .contextMenu {
            Button(item.isFavorite ? "Remover dos Favoritos" : "Adicionar aos Favoritos") {
                onToggleFavorite()
            }
            
            Button("Copiar") {
                clipboardMonitor.copyItem(item)
                onCopy()
            }
            
            Button("Ver Detalhes") {
                onSelect()
            }
            
            Divider()
            
            Button("Deletar") {
                clipboardMonitor.deleteItem(item)
            }
        }
    }
}

struct EmptyStateView: View {
    let hasItems: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: hasItems ? "magnifyingglass" : "doc.on.clipboard")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(hasItems ? "Nenhum item encontrado" : "Nenhum item copiado ainda")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(hasItems ? "Tente ajustar os filtros de busca" : "Copie algo para começar a usar o gerenciador")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DetailView: View {
    let selectedItem: ClipboardItem?
    let clipboardMonitor: ClipboardMonitor
    let onCopy: () -> Void
    
    @State private var isEditing = false
    @State private var editedContent = ""
    
    var body: some View {
        VStack {
            if let item = selectedItem {
                VStack(alignment: .leading, spacing: 16) {
                    // Cabeçalho
                    HStack {
                        Image(systemName: item.type.iconName)
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(item.type.displayName)
                                    .font(.headline)
                                
                                if item.isFavorite {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                            
                            Text(item.formattedTimestamp)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            // Mostrar informação apropriada baseada no tipo
                            Group {
                                switch item.type {
                                case .text, .rtf:
                                    Text("\(item.content.count) caracteres")
                                case .image:
                                    if let data = item.data {
                                        Text("\(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))")
                                    } else {
                                        Text("Dados não disponíveis")
                                    }
                                case .file:
                                    Text("Arquivo")
                                }
                            }
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                            
                            // Botões de ação
                            DetailActionButtons(
                                item: item,
                                clipboardMonitor: clipboardMonitor,
                                onCopy: onCopy
                            )
                        }
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                    
                    // Conteúdo
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Conteúdo:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                // Botão de editar (apenas para texto e RTF)
                                if item.type == .text || item.type == .rtf {
                                    EditControlButtons(
                                        isEditing: $isEditing,
                                        editedContent: $editedContent,
                                        item: item,
                                        clipboardMonitor: clipboardMonitor
                                    )
                                }
                            }
                            
                            switch item.type {
                            case .image:
                                if let data = item.data, let nsImage = NSImage(data: data) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity, maxHeight: 300)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                        )
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo.badge.exclamationmark")
                                            .font(.largeTitle)
                                            .foregroundColor(.secondary)
                                        
                                        Text("Visualização de imagem não disponível")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                        
                                        Text("Os dados da imagem podem ter sido corrompidos ou não são suportados.")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 200)
                                    .padding()
                                    .background(Color(NSColor.textBackgroundColor))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                
                            case .file:
                                VStack(spacing: 12) {
                                    Image(systemName: "doc.text")
                                        .font(.largeTitle)
                                        .foregroundColor(.blue)
                                    
                                    Text(item.content)
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Clique em 'Copiar' para reutilizar este arquivo")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(24)
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                )
                                
                            case .text, .rtf:
                                if isEditing {
                                    TextEditingView(
                                        editedContent: $editedContent,
                                        isEditing: $isEditing,
                                        item: item,
                                        clipboardMonitor: clipboardMonitor
                                    )
                                } else {
                                    TextDisplayView(
                                        content: item.content,
                                        isEditing: $isEditing,
                                        editedContent: $editedContent
                                    )
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Divider()
                    
                    // Seção fixa de origem do aplicativo
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Origem:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "app")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text(item.sourceApp)
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("Copiado em \(item.formattedTimestamp)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.blue.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.vertical, 8)
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
            } else {
                // Estado vazio - nenhum item selecionado
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Selecione um item")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Clique em um item da lista para ver os detalhes completos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .onChange(of: selectedItem?.id) { _ in
            // Resetar modo de edição quando item selecionado mudar
            isEditing = false
            editedContent = ""
        }
    }
}

struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text(message)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.regularMaterial)
                    .shadow(radius: 4)
            )
            .padding(.top, 16)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Componentes Auxiliares

struct TextEditingView: View {
    @Binding var editedContent: String
    @Binding var isEditing: Bool
    let item: ClipboardItem
    let clipboardMonitor: ClipboardMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            textEditor
            helpInfo
        }
    }
    
    private var textEditor: some View {
        TextEditor(text: $editedContent)
            .font(.system(.body, design: .monospaced))
            .scrollContentBackground(.hidden)
            .padding()
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
            .overlay(editorBorder)
            .frame(minHeight: 200)
    }
    
    private var editorBorder: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
    }
    
    private var helpInfo: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(.blue)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Editando como bloco de notas - suas alterações serão salvas no histórico")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("💡 Use os botões 'Salvar' e 'Cancelar' acima")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

struct TextDisplayView: View {
    let content: String
    @Binding var isEditing: Bool
    @Binding var editedContent: String
    @State private var isHovering = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(content)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(backgroundColor)
                .cornerRadius(8)
                .overlay(border)
                .onTapGesture {
                    startEditing()
                }
                .onHover { hovering in
                    isHovering = hovering
                }
            
            // Ícone de edição no hover
            if isHovering {
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(radius: 2)
                    .transition(.opacity)
            }
        }
        .cursor(.pointingHand)
    }
    
    private var backgroundColor: Color {
        isHovering ? Color.blue.opacity(0.05) : Color(NSColor.textBackgroundColor)
    }
    
    private var border: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(isHovering ? Color.blue.opacity(0.3) : Color.secondary.opacity(0.3), lineWidth: 1)
    }
    
    private func startEditing() {
        editedContent = content
        isEditing = true
    }
}

extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        self.onHover { inside in
            if inside {
                cursor.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

struct EditControlButtons: View {
    @Binding var isEditing: Bool
    @Binding var editedContent: String
    let item: ClipboardItem
    let clipboardMonitor: ClipboardMonitor
    
    var body: some View {
        if isEditing {
            editingButtons
        } else {
            editButton
        }
    }
    
    private var editingButtons: some View {
        HStack(spacing: 8) {
            Button("Cancelar") {
                isEditing = false
                editedContent = ""
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.secondary)
            .font(.caption)
            
            Button("Salvar") {
                clipboardMonitor.updateItem(item, newContent: editedContent)
                isEditing = false
                editedContent = ""
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.blue)
            .font(.caption)
            .fontWeight(.medium)
        }
    }
    
    private var editButton: some View {
        Button(action: {
            editedContent = item.content
            isEditing = true
        }) {
            HStack(spacing: 4) {
                Image(systemName: "pencil")
                Text("Editar")
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(editButtonBackground)
    }
    
    private var editButtonBackground: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.blue.opacity(0.1))
    }
}

struct DetailActionButtons: View {
    let item: ClipboardItem
    let clipboardMonitor: ClipboardMonitor
    let onCopy: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            favoriteButton
            copyButton
            deleteButton
        }
    }
    
    private var favoriteButton: some View {
        Button(action: { clipboardMonitor.toggleFavorite(item) }) {
            HStack {
                Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                Text(item.isFavorite ? "Favorito" : "Favoritar")
            }
            .font(.caption)
            .foregroundColor(item.isFavorite ? .red : .blue)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(favoriteBackground)
    }
    
    private var favoriteBackground: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(item.isFavorite ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
    }
    
    private var copyButton: some View {
        Button(action: { 
            clipboardMonitor.copyItem(item)
            onCopy()
        }) {
            HStack {
                Image(systemName: "doc.on.clipboard")
                Text("Copiar")
            }
            .font(.caption)
            .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(copyBackground)
    }
    
    private var copyBackground: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.blue)
    }
    
    private var deleteButton: some View {
        Button(action: { clipboardMonitor.deleteItem(item) }) {
            Image(systemName: "trash")
                .font(.caption)
                .foregroundColor(.red)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(deleteBackground)
    }
    
    private var deleteBackground: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.red.opacity(0.1))
    }
}

#Preview {
    ContentView()
        .environmentObject(ClipboardMonitor.shared)
}