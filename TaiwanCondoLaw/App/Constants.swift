//
//  Constants.swift
//  公寓大廈管理條例全圖解
//

import Foundation

enum Constants {
    // MARK: - IAP
    static let unlockProductID = "com.taiwanarch.condolaw.fullunlock"
    static let fallbackPriceText = "NT$390"

    // MARK: - Free preview limits
    /// 圖解：第一版免費開放前 20 張，完整 250 張需進階解鎖。
    static let freeDesignIllustrationCount  = 20
    static let freeCalculatorCount          = 3
    static let freeBookmarkLimit            = 3
    /// 題庫與檢核：免費版可試用前幾題與基礎檢核，完整版解鎖完整加值服務。
    static let freeCommonClausesFirstGroup  = 2
    static let freeCommonClausesOtherGroups = 1
    static let freeQuizQuestionCount        = 5

    // MARK: - Series mapping
    /// chapter id → series id
    /// rights: Ch01–02, governance: Ch03–04, operations: Ch05–08
    static func seriesId(forChapter chapter: String) -> String {
        guard let n = Int(chapter) else { return "design" }
        if n <= 2 { return "design" }
        if n <= 4 { return "struct" }
        return "equip"
    }

    static func seriesName(forSeriesId id: String) -> String {
        switch id {
        case "design": return "權利義務"
        case "struct": return "會議基金"
        case "equip":  return "管理罰則"
        default:       return id
        }
    }

    // MARK: - Disclaimer
    static let calculatorDisclaimer =
        "⚠️ 本檢核為社區管理與法規速查輔助，實際爭議、催繳、修繕、會議決議與裁罰仍應以主管機關最新公告、全國法規資料庫與專業法律意見為準。"
}
