//
//  ArticleStore.swift
//  公寓大廈管理條例全圖解
//
//  Loads articles.json from the app bundle and exposes derived collections.
//

import Foundation
import Combine

@MainActor
final class ArticleStore: ObservableObject {

    @Published private(set) var bundle: ArticleBundle?
    @Published private(set) var loadError: String?

    init(autoload: Bool = true) {
        if autoload { load() }
    }

    func load() {
        Task {
            guard let url = Bundle.main.url(forResource: "articles", withExtension: "json") else {
                self.loadError = "articles.json not found in bundle"
                return
            }
            do {
                let decoded = try await Task.detached(priority: .userInitiated) {
                    let raw = try Data(contentsOf: url)
                    return try JSONDecoder().decode(ArticleBundle.self, from: raw)
                }.value
                self.bundle = decoded
                self.loadError = nil
            } catch {
                self.loadError = error.localizedDescription
            }
        }
    }

    // MARK: - Derived collections

    var allArticles: [Article] { bundle?.articles ?? [] }
    var allChapters: [Chapter] { bundle?.chapters ?? [] }

    func articles(inChapter id: String) -> [Article] {
        allArticles.filter { $0.chapter == id }.sorted { $0.serial < $1.serial }
    }

    func articles(inSeries seriesId: String) -> [Article] {
        allArticles.filter { $0.seriesId == seriesId }
    }

    func chapters(inSeries seriesId: String) -> [Chapter] {
        allChapters.filter { $0.seriesId == seriesId }
    }

    func article(by id: String) -> Article? {
        allArticles.first { $0.id == id }
    }

    func chapter(by id: String) -> Chapter? {
        allChapters.first { $0.id == id }
    }

    // MARK: - Search

    /// Simple linear search across title_zh / title_en / summary / key_visual / article_no.
    /// 250 entries is small enough for a linear scan.
    func search(_ q: String) -> [Article] {
        let needle = q.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return [] }
        return allArticles.filter { a in
            a.title_zh.lowercased().contains(needle) ||
            a.title_en.lowercased().contains(needle) ||
            a.summary.lowercased().contains(needle) ||
            a.key_visual.lowercased().contains(needle) ||
            a.article_no.lowercased().contains(needle) ||
            a.id.contains(needle)
        }
    }

    // MARK: - Preview

    static var preview: ArticleStore {
        let s = ArticleStore(autoload: false)
        // Inject a tiny sample so SwiftUI Previews don't crash without the bundle.
        let sampleSeries = SeriesMeta(
            title_zh: "公寓大廈管理條例全圖解",
            title_en: "Taiwan Condominium Administration Act Illustrated",
            subtitle_zh: "公寓大廈管理條例 250 張圖解速查",
            version: "1.0", language: "zh-TW",
            source: "全國法規資料庫：公寓大廈管理條例",
            publisher: "中華民國 內政部／全國法規資料庫",
            total_articles: 1, chapters: 1
        )
        let sampleChapter = Chapter(id: "01",
                                    title_zh: "基本定義與權利義務",
                                    title_en: "Definitions and Rights",
                                    intro: "公寓大廈、區分所有、專有部分、共用部分與住戶義務。")
        let sampleArticle = Article(id: "01-01", chapter: "01",
                                    article_no: "公寓大廈管理條例 第3條",
                                    title_zh: "公寓大廈定義圖解",
                                    title_en: "Condominium Definition",
                                    key_visual: "公寓大廈、基地、專有部分、共用部分、明確界線",
                                    summary: "公寓大廈包含可區分之建築物及其基地，應先辨識專有與共用範圍。",
                                    filename: "01-01-公寓大廈定義圖解")
        s.bundle = ArticleBundle(series: sampleSeries,
                                 chapters: [sampleChapter],
                                 articles: [sampleArticle])
        return s
    }
}
