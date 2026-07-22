//
//  CondoChecklistView.swift
//  公寓大廈管理條例全圖解
//

import SwiftUI

struct CondoChecklistView: View {
    @EnvironmentObject private var iap: IAPManager
    @State private var selectedCategory = CondoToolCategory.meeting
    @State private var checkedItems: Set<String> = []
    @State private var showPaywall = false

    private var tools: [CondoToolMeta] {
        CondoToolMeta.all.filter { $0.category == selectedCategory }
    }

    private var freeToolIDs: Set<String> {
        Set(CondoToolMeta.all.prefix(8).map(\.id))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        metricsRow
                        categoryPicker
                        selectedCategoryPanel
                        toolGrid
                        ProToolUnlockRow(isUnlocked: iap.isUnlocked) {
                            showPaywall = true
                        }
                        disclaimer
                        Spacer().frame(height: 104)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("COMMUNITY TOOLKIT")
                .font(.system(size: 9, weight: .medium))
                .italic()
                .kerning(3)
                .foregroundStyle(AppTheme.mute)
            Text("社區管理工具箱")
                .font(.system(size: 32, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
            Text("會議、基金、修繕、規約、移交、罰鍰六大情境，30 個可逐項勾核的治理工具。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.mute)
                .lineSpacing(3)
            Rectangle().fill(AppTheme.line).frame(height: 1).padding(.top, 4)
        }
    }

    private var metricsRow: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 86), spacing: 8)], spacing: 8) {
            ToolMetric(value: "30", label: "工具")
            ToolMetric(value: "6", label: "情境")
            ToolMetric(value: "\(checkedItems.count)", label: "已勾核")
            ToolMetric(value: iap.isUnlocked ? "PRO" : "8", label: iap.isUnlocked ? "已解鎖" : "免費")
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CondoToolCategory.allCases) { category in
                    let selected = category == selectedCategory
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: category.systemImage)
                            Text(category.title)
                        }
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(selected ? .white : AppTheme.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(selected ? category.tint : Color.white, in: Capsule())
                        .overlay(Capsule().stroke(selected ? category.tint : AppTheme.line, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var selectedCategoryPanel: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: selectedCategory.systemImage)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(selectedCategory.tint, in: RoundedRectangle(cornerRadius: 13))
            VStack(alignment: .leading, spacing: 3) {
                Text(selectedCategory.headline)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                Text(selectedCategory.summary)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.mute)
                    .lineLimit(2)
            }
            Spacer()
            Text("\(tools.count) 個")
                .font(.custom("Times New Roman", size: 21))
                .italic()
                .foregroundStyle(selectedCategory.tint)
        }
        .padding(14)
        .background(AppTheme.resourceSurface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.line, lineWidth: 1))
    }

    private var toolGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 166), spacing: 10)], spacing: 10) {
            ForEach(tools) { tool in
                let canAccess = iap.isUnlocked || freeToolIDs.contains(tool.id)
                NavigationLink {
                    if canAccess {
                        CondoToolDetailView(tool: tool, checkedItems: $checkedItems)
                    } else {
                        PaywallView()
                    }
                } label: {
                    CondoToolCard(tool: tool, locked: !canAccess)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var disclaimer: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundStyle(AppTheme.leaf)
            Text(Constants.calculatorDisclaimer)
                .font(.system(size: 12, weight: .medium))
                .lineSpacing(3)
                .foregroundStyle(AppTheme.mute)
        }
        .padding(14)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct ToolMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.custom("Times New Roman", size: 22))
                .italic()
                .foregroundStyle(AppTheme.primary)
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppTheme.mute)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.line, lineWidth: 1))
    }
}

private struct CondoToolCard: View {
    let tool: CondoToolMeta
    let locked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .top) {
                Image(systemName: tool.systemImage)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(tool.tint, in: RoundedRectangle(cornerRadius: 10))
                Spacer()
                Image(systemName: locked ? "lock.fill" : "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(locked ? AppTheme.rust : AppTheme.mute)
            }
            Text(tool.title)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(tool.caption)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.mute)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 5) {
                Text(tool.article)
                Text("・\(tool.checks.count) 項")
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(tool.tint)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 154, alignment: .topLeading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line, lineWidth: 1))
    }
}

private struct CondoToolDetailView: View {
    let tool: CondoToolMeta
    @Binding var checkedItems: Set<String>

    private func key(for check: CondoToolCheck) -> String {
        "\(tool.id)-\(check.id)"
    }

    private var progress: Double {
        guard !tool.checks.isEmpty else { return 0 }
        let done = tool.checks.filter { checkedItems.contains(key(for: $0)) }.count
        return Double(done) / Double(tool.checks.count)
    }

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: tool.systemImage)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 54)
                            .background(tool.tint, in: RoundedRectangle(cornerRadius: 16))
                        Text(tool.title)
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(AppTheme.primary)
                        Text(tool.caption)
                            .font(.system(size: 13, weight: .medium))
                            .lineSpacing(3)
                            .foregroundStyle(AppTheme.mute)
                        Text(tool.article)
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(tool.tint)
                    }
                    .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("\(Int(progress * 100))% 完成")
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundStyle(AppTheme.primary)
                            Spacer()
                            Text("\(tool.checks.filter { checkedItems.contains(key(for: $0)) }.count)/\(tool.checks.count)")
                                .font(.custom("Times New Roman", size: 18))
                                .italic()
                                .foregroundStyle(tool.tint)
                        }
                        ProgressView(value: progress)
                            .tint(tool.tint)
                    }
                    .padding(14)
                    .background(AppTheme.resourceSurface, in: RoundedRectangle(cornerRadius: 14))

                    VStack(spacing: 10) {
                        ForEach(tool.checks) { check in
                            detailRow(check)
                        }
                    }
                    Text(Constants.calculatorDisclaimer)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.mute)
                        .lineSpacing(3)
                        .padding(14)
                        .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(20)
                Spacer().frame(height: 80)
            }
        }
        .navigationTitle(tool.category.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(_ check: CondoToolCheck) -> some View {
        let isChecked = checkedItems.contains(key(for: check))
        return Button {
            if isChecked {
                checkedItems.remove(key(for: check))
            } else {
                checkedItems.insert(key(for: check))
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isChecked ? tool.tint : AppTheme.mute)
                VStack(alignment: .leading, spacing: 5) {
                    Text(check.title)
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(AppTheme.primary)
                    Text(check.detail)
                        .font(.system(size: 12, weight: .medium))
                        .lineSpacing(3)
                        .foregroundStyle(AppTheme.mute)
                }
                Spacer()
            }
            .padding(14)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isChecked ? tool.tint.opacity(0.65) : AppTheme.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct ProToolUnlockRow: View {
    let isUnlocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isUnlocked ? "checkmark.seal.fill" : "crown.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.rust, in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 3) {
                    Text(isUnlocked ? "Pro 工具已完整開放" : "Pro / 解鎖完整圖解與全部工具")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(AppTheme.primary)
                    Text(isUnlocked ? "可使用所有社區治理檢核工具。" : "開啟 250 張圖解、完整工具箱、題庫與收藏。")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.mute)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.mute)
            }
            .padding(14)
            .background(AppTheme.kraft, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(isUnlocked)
    }
}

private enum CondoToolCategory: String, CaseIterable, Identifiable {
    case meeting
    case finance
    case repair
    case rules
    case handover
    case risk

    var id: String { rawValue }

    var title: String {
        switch self {
        case .meeting: return "會議"
        case .finance: return "基金"
        case .repair: return "修繕"
        case .rules: return "規約"
        case .handover: return "移交"
        case .risk: return "風險"
        }
    }

    var headline: String {
        switch self {
        case .meeting: return "區分所有權人會議流程"
        case .finance: return "公共基金與財務紀錄"
        case .repair: return "共用部分與修繕責任"
        case .rules: return "規約、委員會與物管合約"
        case .handover: return "起造人、新舊管委會移交"
        case .risk: return "罰鍰、申訴與公告風險"
        }
    }

    var summary: String {
        switch self {
        case .meeting: return "從召集、委託、門檻到會議紀錄一次檢查。"
        case .finance: return "收支、欠費、專戶、憑證與財務公開。"
        case .repair: return "漏水、外牆、屋頂、停車與共用空間占用。"
        case .rules: return "規約修訂、管委會權責與服務契約審查。"
        case .handover: return "圖說、設備、公共基金與缺失追蹤清冊。"
        case .risk: return "主管機關、裁罰、個資公告與文件保存。"
        }
    }

    var systemImage: String {
        switch self {
        case .meeting: return "person.3.sequence.fill"
        case .finance: return "banknote.fill"
        case .repair: return "wrench.and.screwdriver.fill"
        case .rules: return "doc.badge.gearshape.fill"
        case .handover: return "archivebox.fill"
        case .risk: return "checkmark.shield.fill"
        }
    }

    var tint: Color {
        switch self {
        case .meeting: return AppTheme.designSeries
        case .finance: return AppTheme.rust
        case .repair: return AppTheme.resourceBlue
        case .rules: return AppTheme.structSeries
        case .handover: return AppTheme.leaf
        case .risk: return AppTheme.equipSeries
        }
    }
}

private struct CondoToolMeta: Identifiable {
    let id: String
    let title: String
    let caption: String
    let category: CondoToolCategory
    let article: String
    let systemImage: String
    let tint: Color
    let checks: [CondoToolCheck]
}

private struct CondoToolCheck: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
}

private extension CondoToolMeta {
    init(_ id: String,
         _ title: String,
         _ caption: String,
         _ category: CondoToolCategory,
         _ article: String,
         _ systemImage: String,
         checks: [CondoToolCheck]) {
        self.id = id
        self.title = title
        self.caption = caption
        self.category = category
        self.article = article
        self.systemImage = systemImage
        self.tint = category.tint
        self.checks = checks
    }
}

private extension CondoToolCheck {
    init(_ id: String, _ title: String, _ detail: String) {
        self.id = id
        self.title = title
        self.detail = detail
    }
}

private extension CondoToolMeta {
    static let all: [CondoToolMeta] = [
        .init("meeting-call", "區權會召集檢核", "確認召集人、事由、通知與議題內容。", .meeting, "第25條", "calendar.badge.exclamationmark", checks: [
            .init("1", "確認召集權限", "核對召集人身份、任期與召集原因。"),
            .init("2", "列明會議議題", "通知內容應足以讓住戶理解表決事項。"),
            .init("3", "保存送達證明", "保留郵寄、公告、電子通知或簽收紀錄。"),
            .init("4", "區分定期或臨時會", "不同會議類型應對應不同議程與通知管理。")
        ]),
        .init("meeting-quorum", "決議門檻判斷", "快速檢查一般決議、特別決議與規約修訂比例。", .meeting, "第31條、第32條", "number.circle.fill", checks: [
            .init("1", "確認出席權數", "同時核對人數、區分所有權比例與委託。"),
            .init("2", "判定事項類型", "一般事項、重大修繕或規約修訂不可混用門檻。"),
            .init("3", "逐案記錄表決結果", "每一議案需有贊成、反對、棄權與權數統計。"),
            .init("4", "公告決議內容", "公告文字需與會議紀錄一致。")
        ]),
        .init("meeting-proxy", "委託出席稽核", "整理委託書、代理限制與表決權計算。", .meeting, "第27條", "person.crop.circle.badge.checkmark", checks: [
            .init("1", "核對委託書格式", "確認委託人、受託人、會議名稱與日期。"),
            .init("2", "排除重複委託", "同一戶或同一權利人不得重複列計。"),
            .init("3", "標註代理權數", "代理權數應與建物持分資料一致。"),
            .init("4", "歸檔正本或影本", "保存可查核版本，避免事後爭議。")
        ]),
        .init("meeting-minutes", "會議紀錄歸檔", "會議紀錄、簽到、表決與公告文件一次整理。", .meeting, "第34條、第35條", "doc.text.fill", checks: [
            .init("1", "附上簽到表", "紀錄出席人、委託人與表決權數。"),
            .init("2", "逐案載明決議", "避免只寫籠統結論。"),
            .init("3", "公告與送達留痕", "保留公告照片、日期與移除日期。"),
            .init("4", "建立查閱管道", "住戶查閱應有一致申請流程。")
        ]),
        .init("meeting-dispute", "決議異議處理", "追蹤異議期限、溝通紀錄與後續處置。", .meeting, "會議實務", "exclamationmark.bubble.fill", checks: [
            .init("1", "記錄異議來源", "整理住戶姓名、時間、內容與附件。"),
            .init("2", "回到原決議資料", "核對通知、出席、門檻與紀錄是否完整。"),
            .init("3", "避免群組口水化", "以正式公告或書面回覆處理。"),
            .init("4", "必要時排入下次會議", "重大爭議應以會議程序修正或確認。")
        ]),

        .init("fund-income", "公共基金收支", "建立收入、支出、餘額與專戶憑證檢核。", .finance, "第18條、第20條", "chart.pie.fill", checks: [
            .init("1", "分開管理科目", "公共基金、管理費、修繕費應清楚分列。"),
            .init("2", "保留專戶資料", "存摺、印鑑、授權與轉帳紀錄應可追溯。"),
            .init("3", "每月彙整收支", "列出收入、支出、餘額與待付款。"),
            .init("4", "重大支出附決議", "大型修繕或採購需對應會議或規約依據。")
        ]),
        .init("fund-arrears", "欠費催告流程", "管理費欠繳從提醒、催告到法律程序的紀錄。", .finance, "第21條", "envelope.badge.fill", checks: [
            .init("1", "核對欠費明細", "確認月份、金額、滯納或利息依據。"),
            .init("2", "先行友善提醒", "保留電話、訊息或公告提醒紀錄。"),
            .init("3", "正式催告留證", "催告金額、期限與送達方式要明確。"),
            .init("4", "避免公開個資", "公告欠費資訊須兼顧必要性與個資風險。")
        ]),
        .init("fund-ledger", "財務移交清冊", "新舊委員會交接帳冊、印鑑、存摺與憑證。", .finance, "第20條、第29條", "list.bullet.clipboard.fill", checks: [
            .init("1", "列出帳冊清單", "總帳、明細帳、收入支出表與憑證冊。"),
            .init("2", "核對銀行餘額", "與帳上餘額、未兌現票據及待付款項比對。"),
            .init("3", "移交印鑑與權限", "銀行印鑑、網銀權限與保管人需列明。"),
            .init("4", "雙方簽收", "交接人、接收人、見證人與日期完整留存。")
        ]),
        .init("fund-budget", "年度預算檢核", "把年度管理費、保全清潔與修繕預算拆成可審項目。", .finance, "社區財務實務", "calendar.badge.clock", checks: [
            .init("1", "固定費用列清楚", "保全、清潔、機電、保險與垃圾清運等固定支出。"),
            .init("2", "預留修繕準備", "電梯、消防、水電與外牆保養需規劃週期。"),
            .init("3", "對比前年度實績", "找出超支或節餘原因。"),
            .init("4", "公開說明調整", "管理費調整應有明確試算與溝通資料。")
        ]),
        .init("fund-receipt", "收支憑證整理", "避免憑證散落造成查帳與交接困難。", .finance, "第20條", "folder.fill.badge.plus", checks: [
            .init("1", "依月份編碼", "每張發票、收據、報價與驗收單建立編號。"),
            .init("2", "拍照備份", "紙本與電子檔都應可搜尋。"),
            .init("3", "付款對單", "憑證、匯款紀錄與合約金額互相對得上。"),
            .init("4", "保管年限一致", "依規約或社區內控制度保存。")
        ]),

        .init("repair-scope", "修繕責任分流", "先判定專有、共用、約定專用或管理維護責任。", .repair, "第10條、第11條", "arrow.triangle.branch", checks: [
            .init("1", "定位問題位置", "樓板、管道間、外牆、屋頂或專有空間。"),
            .init("2", "查規約與圖說", "約定專用或特殊分擔規則需先確認。"),
            .init("3", "判斷受益範圍", "費用分攤常與受益或責任範圍有關。"),
            .init("4", "保留初判依據", "照片、圖說、技師或廠商意見應歸檔。")
        ]),
        .init("repair-leak", "漏水爭議初判", "建立漏水通報、勘查、進入修繕與費用追蹤。", .repair, "第6條、第10條", "drop.fill", checks: [
            .init("1", "記錄發現時間", "拍照、錄影並標註位置。"),
            .init("2", "通知可能責任戶", "必要進入專有部分時應留下通知紀錄。"),
            .init("3", "委請專業勘查", "重大爭議避免僅用主觀判斷。"),
            .init("4", "修繕前後留證", "施工、驗收與付款資料一併保存。")
        ]),
        .init("repair-common", "共用空間占用", "檢查樓梯間、走廊、防火巷弄與法定空地。", .repair, "第16條", "rectangle.3.group.fill", checks: [
            .init("1", "拍攝占用位置", "標明樓層、時間與影響動線。"),
            .init("2", "確認消防逃生影響", "涉及逃生或消防安全應優先處理。"),
            .init("3", "依規約通知改善", "通知期限、內容與送達應一致。"),
            .init("4", "必要時通報主管機關", "長期不改善可依法處理。")
        ]),
        .init("repair-parking", "停車位專用/共用", "釐清停車空間權屬、約定專用與使用限制。", .repair, "第7條、第58條", "car.fill", checks: [
            .init("1", "查建物登記與圖說", "確認停車位性質與使用範圍。"),
            .init("2", "比對規約內容", "約定專用與管理辦法是否一致。"),
            .init("3", "檢查違規堆置", "停車位不得任意改作危害安全用途。"),
            .init("4", "保存租借或使用紀錄", "租借、轉讓或借用應有書面依據。")
        ]),
        .init("repair-safety", "公共安全巡檢", "電梯、消防、機電、外牆與屋頂例行巡檢。", .repair, "公共安全實務", "bolt.shield.fill", checks: [
            .init("1", "建立週期表", "月檢、季檢、年檢項目分開管理。"),
            .init("2", "缺失分級", "立即危險、限期改善、觀察項目分層處理。"),
            .init("3", "追蹤改善完成", "每一缺失都要有完成日期與照片。"),
            .init("4", "連動預算", "重大維修需回到基金與會議決議。")
        ]),

        .init("rules-required", "規約應載事項", "檢查規約是否涵蓋專共用、費用、會議與管理組織。", .rules, "第23條", "doc.plaintext.fill", checks: [
            .init("1", "專有共用定義", "先確認空間範圍與使用限制。"),
            .init("2", "費用分擔規則", "管理費、公共基金與修繕分擔要具體。"),
            .init("3", "會議與委員會", "召集、任期、職務與授權要明確。"),
            .init("4", "違規處理程序", "通知、改善、罰則與申訴管道要一致。")
        ]),
        .init("rules-amend", "規約修訂門檻", "把規約修訂提案、門檻與公告流程分解。", .rules, "第31條、第32條", "pencil.and.list.clipboard", checks: [
            .init("1", "提出修訂草案", "修訂前後條文應並列。"),
            .init("2", "確認表決門檻", "依事項性質判斷是否需特別決議。"),
            .init("3", "保存表決紀錄", "贊成權數與人數需可查核。"),
            .init("4", "公告新版規約", "住戶應能取得最新版本。")
        ]),
        .init("rules-committee", "管委會成立", "從第一次會議到委員、主委與報備資料整理。", .rules, "第29條、第36條", "person.2.badge.gearshape.fill", checks: [
            .init("1", "選任委員", "任期、名額與資格依規約確認。"),
            .init("2", "推選主委財委監委", "職務分工應記入會議紀錄。"),
            .init("3", "整理報備資料", "主管機關要求文件需一次備齊。"),
            .init("4", "公告聯絡窗口", "住戶應知道管理組織與聯絡方式。")
        ]),
        .init("rules-contract", "管理維護公司合約", "審查服務範圍、費用、違約與交接條款。", .rules, "第42條", "doc.badge.gearshape.fill", checks: [
            .init("1", "列明服務範圍", "保全、清潔、機電與行政工作不可籠統。"),
            .init("2", "設定驗收方式", "服務缺失要有回報與扣款規則。"),
            .init("3", "確認保險與證照", "人員資格、保險與法定責任需明確。"),
            .init("4", "設交接義務", "終止契約時文件與帳務不可斷線。")
        ]),
        .init("rules-access", "住戶文件閱覽", "建立帳冊、會議紀錄與規約查閱流程。", .rules, "第35條、第36條", "eye.text.fill", checks: [
            .init("1", "定義可閱覽範圍", "會議紀錄、財務表與規約應分類。"),
            .init("2", "建立申請表", "申請人、目的、日期與交付方式留紀錄。"),
            .init("3", "遮蔽個資", "公開資料前先檢查個人資料。"),
            .init("4", "保留交付紀錄", "避免事後爭執是否提供。")
        ]),

        .init("handover-builder", "起造人移交", "規約草約、圖說、設備與公共基金資料交付。", .handover, "第56條、第57條", "building.2.crop.circle.fill", checks: [
            .init("1", "核對規約草約", "確認起造人提供版本與公告版本。"),
            .init("2", "核對竣工圖說", "平面、設備、管線與公共設施資料。"),
            .init("3", "盤點設備文件", "保固書、操作手冊與維護契約。"),
            .init("4", "列出缺漏事項", "未交付項目要列管追蹤。")
        ]),
        .init("handover-assets", "圖說設備清冊", "把公共設備、鑰匙、門禁、遙控器與保固列冊。", .handover, "第57條", "shippingbox.fill", checks: [
            .init("1", "設備逐項編號", "電梯、消防、發電機、水電機房分開列。"),
            .init("2", "交接鑰匙門禁", "機房、屋頂、公共空間與系統權限。"),
            .init("3", "保固期限表", "每項設備標示保固起迄與廠商電話。"),
            .init("4", "異常拍照", "缺件、損壞或無法測試需留影像。")
        ]),
        .init("handover-finance", "新舊管委會交接", "文件、帳務、合約、印鑑與未結案件移交。", .handover, "第20條、第29條", "arrow.left.arrow.right.square.fill", checks: [
            .init("1", "先排交接會議", "雙方與見證人確認時間地點。"),
            .init("2", "分冊移交文件", "規約、會議、合約、財務與修繕案件。"),
            .init("3", "未結案件清單", "爭議、欠費、修繕與採購不可遺漏。"),
            .init("4", "簽署移交紀錄", "雙方各持一份完整清冊。")
        ]),
        .init("handover-old", "舊公寓補強管理", "舊有公寓建立組織、規約與安全管理資料。", .handover, "第55條", "house.lodge.fill", checks: [
            .init("1", "確認戶數與權屬", "先整理住戶名冊與區分所有權資料。"),
            .init("2", "補訂規約", "從費用、共用空間與會議程序開始。"),
            .init("3", "建立公共安全清冊", "消防、電梯、水電與外牆狀態。"),
            .init("4", "逐步成立管理組織", "先有聯絡窗口，再推動正式會議。")
        ]),
        .init("handover-defect", "缺失追蹤看板", "把交屋、設備、修繕與廠商回覆集中管理。", .handover, "移交實務", "rectangle.and.pencil.and.ellipsis", checks: [
            .init("1", "每項缺失編號", "位置、描述、照片與責任單位。"),
            .init("2", "設定改善期限", "不同缺失應有合理期限。"),
            .init("3", "追蹤複驗結果", "完成、未完成、需追加資料分狀態。"),
            .init("4", "結案留證", "完成照片與住戶確認紀錄。")
        ]),

        .init("risk-fine", "罰鍰風險速查", "占用、妨害、未改善與主管機關裁罰前置檢查。", .risk, "第47條至第49條", "exclamationmark.triangle.fill", checks: [
            .init("1", "確認違規事實", "照片、時間、地點與行為人。"),
            .init("2", "確認通知改善", "改善期限與送達紀錄要完整。"),
            .init("3", "整理主管機關依據", "法條、自治規定或消防建管規範。"),
            .init("4", "避免自行裁罰越權", "社區管理與行政裁罰權限需區分。")
        ]),
        .init("risk-complaint", "主管機關申訴包", "把通報、陳情、回覆與改善資料整理成一包。", .risk, "第59條", "tray.and.arrow.up.fill", checks: [
            .init("1", "列明請求事項", "希望主管機關協助的事項要具體。"),
            .init("2", "附上證據", "照片、公告、會議紀錄與往來文件。"),
            .init("3", "保留收文編號", "電子或紙本送件都要可追蹤。"),
            .init("4", "建立回覆期限", "追蹤承辦與補正要求。")
        ]),
        .init("risk-privacy", "個資公告風險", "社區公告、群組與欠費資料揭露前先檢查。", .risk, "個資與管理實務", "person.text.rectangle.fill", checks: [
            .init("1", "判斷揭露必要性", "能不揭露姓名就避免揭露。"),
            .init("2", "最小化資訊", "金額、戶別、姓名與電話不應一次全露。"),
            .init("3", "限制公告期間", "公告移除時間也要記錄。"),
            .init("4", "改用正式通知", "敏感資訊優先採個別通知。")
        ]),
        .init("risk-notice", "社區公告檢核", "公告語氣、法源、期限、附件與張貼位置整理。", .risk, "社區治理實務", "megaphone.fill", checks: [
            .init("1", "標題明確", "住戶能一眼知道事項與期限。"),
            .init("2", "附法源或決議", "規約、會議決議或法規依據要寫清楚。"),
            .init("3", "保留公告照片", "拍到日期、位置與內容。"),
            .init("4", "同步電子管道", "App、群組或信件應與紙本一致。")
        ]),
        .init("risk-archive", "爭議文件保存", "把催告、裁罰、調解、訴訟與修繕爭議歸檔。", .risk, "爭議處理實務", "externaldrive.badge.shield.checkmark", checks: [
            .init("1", "依案件建資料夾", "同一爭議集中保管，避免散落在群組。"),
            .init("2", "保存原始檔", "照片、錄影與公文不要只留截圖。"),
            .init("3", "記錄時間線", "發現、通知、改善、回覆、結案時間。"),
            .init("4", "交接時列入清冊", "未結爭議必須移交新委員會。")
        ])
    ]
}

#Preview {
    CondoChecklistView()
        .environmentObject(IAPManager())
}
