import SwiftUI

struct ProfessionalToolsHomeView: View {
    @State private var query = ""
    @State private var selectedGroup = "全部"

    private let columns = [GridItem(.adaptive(minimum: 158), spacing: 10)]

    private var filteredTools: [ProfessionalTool] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return ProfessionalToolCatalog.tools.filter { tool in
            let matchesGroup = selectedGroup == "全部" || tool.group == selectedGroup
            let matchesQuery = needle.isEmpty || tool.title.localizedCaseInsensitiveContains(needle)
                || tool.group.localizedCaseInsensitiveContains(needle)
                || tool.focus.localizedCaseInsensitiveContains(needle)
            return matchesGroup && matchesQuery
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.paper.ignoresSafeArea()
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 14) {
                        header
                        searchField
                        groupFilter
                        resultHeader
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(filteredTools) { tool in
                                NavigationLink {
                                    ProfessionalToolDetailView(tool: tool)
                                } label: {
                                    ProfessionalToolCard(tool: tool)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("tool-\(tool.id)")
                            }
                        }
                        Spacer().frame(height: 96)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("100 個工具")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ProfessionalToolCatalog.headerEyebrow)
                        .font(.system(size: 9, weight: .bold))
                        .kerning(2.1)
                        .foregroundStyle(AppTheme.mute)
                    Text(ProfessionalToolCatalog.headerTitle)
                        .font(.system(size: 29, weight: .heavy, design: .serif))
                        .foregroundStyle(AppTheme.primary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text("100")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.rust)
                    Text("個工具・全部可操作")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppTheme.mute)
                }
            }
            Text(ProfessionalToolCatalog.headerSubtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.mute)
                .lineSpacing(3)
        }
        .padding(16)
        .background(
            LinearGradient(colors: [AppTheme.primary.opacity(0.10), AppTheme.gold.opacity(0.11)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.line))
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(AppTheme.primary)
            TextField(ProfessionalToolCatalog.searchPrompt, text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier("tools-search-field")
            if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(AppTheme.mute)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("清除工具搜尋")
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line))
    }

    private var groupFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(["全部"] + ProfessionalToolCatalog.groups, id: \.self) { group in
                    Button {
                        withAnimation(.snappy(duration: 0.24)) { selectedGroup = group }
                    } label: {
                        Text(group)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(selectedGroup == group ? .white : AppTheme.primary)
                            .padding(.horizontal, 12)
                            .frame(height: 34)
                            .background(selectedGroup == group ? AppTheme.primary : .white, in: Capsule())
                            .overlay(Capsule().stroke(AppTheme.line))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var resultHeader: some View {
        HStack {
            Text(selectedGroup == "全部" ? "全部工具" : selectedGroup)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
            Spacer()
            Text("\(filteredTools.count) 項")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.mute)
                .accessibilityIdentifier("tools-result-count")
        }
    }
}

private struct ProfessionalToolCard: View {
    let tool: ProfessionalTool

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Image(systemName: tool.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.primary.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                Spacer()
                Text(String(format: "%03d", tool.id))
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(AppTheme.rust)
            }
            Text(tool.title)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
                .lineLimit(2)
            Text(tool.group)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppTheme.mute)
            Text(tool.focus)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.mute)
                .lineLimit(2)
            Label("開啟工具", systemImage: "arrow.up.right")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(AppTheme.rust)
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 172, alignment: .topLeading)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(AppTheme.line))
        .shadow(color: AppTheme.primary.opacity(0.05), radius: 7, y: 3)
    }
}

struct ProfessionalToolDetailView: View {
    let tool: ProfessionalTool
    @AppStorage private var notes: String
    @State private var completed: Set<Int> = []
    @State private var likelihood = 1
    @State private var severity = 1

    init(tool: ProfessionalTool) {
        self.tool = tool
        _notes = AppStorage(wrappedValue: "", "\(ProfessionalToolCatalog.storageKeyPrefix).\(tool.id)")
    }

    private var riskScore: Int { likelihood * severity }
    private var riskLabel: String {
        switch riskScore {
        case 1...4: return "低風險"
        case 5...9: return "中風險"
        case 10...16: return "高風險"
        default: return "立即處置"
        }
    }
    private var riskColor: Color {
        switch riskScore {
        case 1...4: return AppTheme.leaf
        case 5...9: return AppTheme.gold
        default: return AppTheme.rust
        }
    }

    var body: some View {
        Form {
            Section {
                HStack(spacing: 14) {
                    Image(systemName: tool.icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.primary)
                        .frame(width: 56, height: 56)
                        .background(AppTheme.primary.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tool.group).font(.caption.bold()).foregroundStyle(AppTheme.rust)
                        Text(tool.focus).font(.subheadline.weight(.semibold)).foregroundStyle(AppTheme.primary)
                    }
                }
            }
            Section("案件查核清單") {
                ForEach(Array(tool.checklist.enumerated()), id: \.offset) { index, row in
                    Button {
                        if completed.contains(index) { completed.remove(index) } else { completed.insert(index) }
                    } label: {
                        Label(row, systemImage: completed.contains(index) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(completed.contains(index) ? AppTheme.leaf : AppTheme.primary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("tool-check-\(index)")
                }
                ProgressView(value: Double(completed.count), total: Double(tool.checklist.count)).tint(AppTheme.leaf)
                Text("已完成 \(completed.count) / \(tool.checklist.count) 項")
                    .font(.caption.bold()).foregroundStyle(AppTheme.mute)
            }
            Section("案件風險速算") {
                Picker("發生可能性", selection: $likelihood) {
                    ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                }.pickerStyle(.segmented)
                Picker("影響嚴重度", selection: $severity) {
                    ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                }.pickerStyle(.segmented)
                LabeledContent("風險分數") {
                    Text("\(riskScore)・\(riskLabel)")
                        .font(.headline).foregroundStyle(riskColor)
                        .accessibilityIdentifier("tool-risk-result")
                }
                Text("分數為可能性 × 影響嚴重度；10 分以上應先補齊關鍵條件、文件或專業確認再繼續。")
                    .font(.footnote).foregroundStyle(AppTheme.mute)
            }
            Section("案件紀錄") {
                TextEditor(text: $notes).frame(minHeight: 130).accessibilityIdentifier("tool-notes")
                if !notes.isEmpty {
                    Button("清除紀錄", role: .destructive) { notes = "" }
                }
            }
            Section {
                ShareLink(item: shareText) { Label("分享查核紀錄", systemImage: "square.and.arrow.up") }
            }
            Section {
                Text(ProfessionalToolCatalog.disclaimer).font(.footnote).foregroundStyle(AppTheme.mute)
            }
        }
        .navigationTitle(tool.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var shareText: String {
        """
        \(tool.title)（\(tool.group)）
        已完成 \(completed.count)/\(tool.checklist.count) 項查核
        風險分數：\(riskScore)・\(riskLabel)
        案件紀錄：\(notes.isEmpty ? "無" : notes)
        """
    }
}
