//
//  RegulatoryResource.swift
//  公寓大廈管理條例全圖解
//
//  Curated official links for condominium law lookup and community governance.
//

import Foundation

struct RegulatoryResource: Identifiable, Hashable {
    enum Category: String, CaseIterable, Identifiable {
        case law = "法規"
        case agency = "機關"
        case local = "地方"
        case system = "系統"

        var id: String { rawValue }
    }

    let id: String
    let title: String
    let subtitle: String
    let category: Category
    let url: URL
    let symbolName: String
    let keywords: [String]

    static let official: [RegulatoryResource] = [
        .init(
            id: "condominium-act-law-moj",
            title: "公寓大廈管理條例",
            subtitle: "全國法規資料庫：公寓大廈管理主法規",
            category: .law,
            url: URL(string: "https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=D0070118")!,
            symbolName: "building.2.fill",
            keywords: ["公寓大廈管理條例", "區分所有權", "管委會", "公共基金", "D0070118"]
        ),
        .init(
            id: "condominium-act-rules-law-moj",
            title: "公寓大廈管理條例施行細則",
            subtitle: "全國法規資料庫：條例施行細節",
            category: .law,
            url: URL(string: "https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=D0070119")!,
            symbolName: "scroll.fill",
            keywords: ["施行細則", "公寓大廈", "管理委員會", "D0070119"]
        ),
        .init(
            id: "nlma-official",
            title: "內政部國土管理署",
            subtitle: "建築管理、公寓大廈與住宅政策主管機關",
            category: .agency,
            url: URL(string: "https://www.nlma.gov.tw/")!,
            symbolName: "building.columns.fill",
            keywords: ["國土管理署", "內政部", "公寓大廈", "建築管理"]
        ),
        .init(
            id: "taipei-laws-condo",
            title: "臺北市法規查詢系統",
            subtitle: "中央與地方公寓大廈相關法規查詢",
            category: .local,
            url: URL(string: "https://laws.gov.taipei/Law/")!,
            symbolName: "building.2.crop.circle.fill",
            keywords: ["臺北市", "公寓大廈", "法規查詢", "地方規定"]
        ),
        .init(
            id: "new-taipei-building",
            title: "新北市政府工務局",
            subtitle: "地方建築管理與公寓大廈管理資訊",
            category: .local,
            url: URL(string: "https://www.publicwork.ntpc.gov.tw/")!,
            symbolName: "checkmark.shield.fill",
            keywords: ["新北市", "工務局", "公寓大廈", "建築管理"]
        ),
        .init(
            id: "law-search-system",
            title: "全國法規資料庫",
            subtitle: "法規全文、條文沿革與最新公告查詢",
            category: .system,
            url: URL(string: "https://law.moj.gov.tw/")!,
            symbolName: "network",
            keywords: ["全國法規資料庫", "法規查詢", "公寓大廈", "條文"]
        )
    ]

    static func filtered(query: String, category: Category?) -> [RegulatoryResource] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return official.filter { resource in
            let categoryMatches = category == nil || resource.category == category
            guard !normalized.isEmpty else { return categoryMatches }
            let haystack = ([resource.title, resource.subtitle, resource.category.rawValue] + resource.keywords)
                .joined(separator: " ")
            return categoryMatches && haystack.localizedCaseInsensitiveContains(normalized)
        }
    }
}
