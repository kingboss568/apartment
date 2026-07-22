import Foundation

struct ProfessionalTool: Identifiable, Hashable {
    let id: Int
    let title: String
    let group: String
    let focus: String
    let icon: String

    var checklist: [String] {
        [
            "確認「\(title)」的適用場所、對象、條件、法源與負責角色。",
            "逐項核對重點：\(focus)。",
            "完成必要量測、圖說、照片、證明或紀錄，標示版本與日期。",
            "記錄缺失、改善責任人、完成期限、複查結果與待追蹤事項。"
        ]
    }
}

enum ProfessionalToolCatalog {
    static let headerEyebrow = "PROFESSIONAL CONDO GOVERNANCE TOOLBOX"
    static let headerTitle = "公寓治理專業工具箱"
    static let headerSubtitle = "每個工具都有可勾選查核、風險分數速算、持久化案件筆記與分享紀錄。"
    static let searchPrompt = "搜尋會議、基金或修繕重點"
    static let storageKeyPrefix = "condo-law-tool.notes"
    static let disclaimer = Constants.calculatorDisclaimer

    private static let specs: [(String, String, [String])] = [
        ("權利義務", "person.2.fill", ["區分所有權範圍檢核", "住戶共同義務檢核", "使用收益限制檢核", "容忍義務情境檢核", "修繕進入權檢核", "公共安全義務檢核", "住戶資料管理檢核", "管理費義務檢核", "規約拘束力檢核", "承租人義務告知"]),
        ("專有共用", "square.split.2x2.fill", ["專有部分辨識", "共用部分辨識", "約定專用檢核", "約定共用檢核", "外牆權屬初判", "屋頂平台權屬初判", "法定空地使用檢核", "管線權責初判", "停車位權屬初判", "界面爭議證據整理"]),
        ("區權會議", "person.3.sequence.fill", ["召集人資格檢核", "開會通知期限檢核", "議程內容檢核", "出席人數門檻", "表決權數門檻", "重新召集程序", "委託書資格檢核", "會議紀錄檢核", "決議公告送達", "決議效力初判"]),
        ("管委會", "building.columns.fill", ["管委會成立檢核", "主任委員選任", "委員資格檢核", "任期連任檢核", "職務分工檢核", "會議程序檢核", "管理負責人權責", "報備文件檢核", "印鑑帳戶交接", "年度工作計畫"]),
        ("公共基金", "banknote.fill", ["公共基金來源盤點", "管理費收支檢核", "專戶設置檢核", "支出授權檢核", "重大修繕預算", "欠費催繳流程", "利息與孳息管理", "基金移交檢核", "基金查核程序", "基金運用公告"]),
        ("財務帳冊", "books.vertical.fill", ["年度預算編製", "年度決算編製", "收支憑證檢核", "採購比價紀錄", "零用金管理檢核", "會計科目檢核", "財務報表公告", "住戶查閱程序", "外部查核準備", "財務資料保存"]),
        ("修繕漏水", "wrench.adjustable.fill", ["共用部分修繕判定", "專有部分修繕判定", "漏水來源初判", "緊急修繕程序", "修繕廠商選任", "修繕費用分攤", "公共管線修繕", "外牆修繕檢核", "電梯修繕檢核", "修繕驗收保固"]),
        ("車位住戶", "car.fill", ["法定停車位辨識", "增設停車位檢核", "車位使用規則", "充電樁申請檢核", "機械車位維護", "訪客停車管理", "違規停車處理", "寵物管理規範", "噪音爭議處理", "公共空間堆物處理"]),
        ("規約違規", "doc.badge.exclamationmark.fill", ["規約訂定程序", "規約修訂程序", "住戶違規通知", "制止程序檢核", "強制遷離初判", "管理費欠繳催收", "違規罰鍰初判", "存證信函資料檢核", "調解程序準備", "訴訟證據整理"]),
        ("移交爭議", "arrow.left.arrow.right.circle.fill", ["起造人移交清冊", "公共基金移交", "公共設施點交", "竣工圖說移交", "設備保固文件", "檢測報告移交", "管委會改選移交", "印鑑帳冊移交", "缺失改善追蹤", "社區文件總歸檔"])
    ]

    static let groups = specs.map(\.0)

    static let tools: [ProfessionalTool] = specs.enumerated().flatMap { groupIndex, spec in
        spec.2.enumerated().map { itemIndex, title in
            ProfessionalTool(
                id: groupIndex * 10 + itemIndex + 1,
                title: title,
                group: spec.0,
                focus: "\(spec.0)情境的適用條件、現場狀態、文件完整性與期限風險",
                icon: spec.1
            )
        }
    }
}
