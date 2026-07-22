//
//  IllustrationsHomeView.swift
//  Tab 1 root — 公寓大廈管理條例圖解分類
//  三大類大卡片 → 章節 → 縮圖網格 → 圖解詳情
//

import SwiftUI

// MARK: - Home

struct IllustrationsHomeView: View {
    @EnvironmentObject var store: ArticleStore
    @EnvironmentObject var iap: IAPManager

    private let series: [(id: String, title: String, en: String,
                          range: String, icon: IsoIconKind, summary: String)] = [
        ("design", "權利義務", "RIGHTS", "Ch 01-02", .boxBasic, "專有、共用、住戶義務"),
        ("struct", "會議基金", "MEETINGS", "Ch 03-04", .lightbulb, "區權會、公共基金、管委會"),
        ("equip",  "管理罰則", "OPERATIONS", "Ch 05-08", .gear, "修繕、移交、罰鍰、爭議"),
    ]
    private let featuredArticleIDs = ["01-01", "02-04", "03-03", "04-05", "05-03", "06-04", "07-02", "08-05"]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                AppTheme.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        headerBar
                            .padding(.top, 18)
                        HomeHeroCard()
                        statsBar
                        PremiumSearchLink()
                        categoryDeck
                        priorityFocus
                        UnlockPromoCard(isUnlocked: iap.isUnlocked)
                        featuredStrip
                        quickActions
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { SearchView() } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppTheme.primary)
                    }
                }
                if !iap.isUnlocked {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink { PaywallView() } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill").font(.caption)
                                Text("Pro 解鎖").font(.callout.bold())
                            }
                            .foregroundStyle(AppTheme.rust)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerBar: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CONDOMINIUM ACT")
                    .font(.system(size: 9, weight: .regular))
                    .italic()
                    .kerning(3.2)
                    .foregroundStyle(AppTheme.mute)
                Text("公寓大廈管理條例全圖解")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text("250 張圖解・會議基金工具・題庫測驗")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.mute)
            }
            Spacer()
            if !iap.isUnlocked {
                NavigationLink { PaywallView() } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 15, weight: .bold))
                        Text("PRO")
                            .font(.system(size: 10, weight: .heavy))
                    }
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(AppTheme.rust, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var statsBar: some View {
        let total = max(store.allArticles.count, 250)
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 8)], spacing: 8) {
            StatCell(value: "\(total)", label: "圖解")
            StatCell(value: "8", label: "章節")
            StatCell(value: "100", label: "工具")
            StatCell(value: "20", label: "免費")
        }
    }

    private var categoryDeck: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "圖解分類", subtitle: "依社區管理流程快速進入")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: 10)], spacing: 10) {
                ForEach(series, id: \.id) { s in
                    let count = store.articles(inSeries: s.id).count
                    NavigationLink {
                        SeriesChapterListView(seriesId: s.id, seriesTitle: s.title)
                    } label: {
                        SeriesPillCard(seriesId: s.id,
                                       title: s.title,
                                       en: s.en,
                                       range: s.range,
                                       icon: s.icon,
                                       summary: s.summary,
                                       count: count)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var priorityFocus: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "今日焦點", subtitle: "社區最常查的高頻問題")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: 10)], spacing: 10) {
                FocusLink(title: "區權會決議",
                          caption: "召集、出席、委託、表決比例",
                          systemImage: "person.3.sequence.fill",
                          tint: AppTheme.designSeries,
                          destination: SearchView())
                FocusLink(title: "公共基金",
                          caption: "收支公告、欠費催告、帳冊移交",
                          systemImage: "banknote.fill",
                          tint: AppTheme.rust,
                          destination: SearchView())
                FocusLink(title: "修繕爭議",
                          caption: "專有共用判斷、漏水與費用分擔",
                          systemImage: "wrench.and.screwdriver.fill",
                          tint: AppTheme.resourceBlue,
                          destination: ProfessionalToolsHomeView())
                FocusLink(title: "罰鍰風險",
                          caption: "占用、防火、公告與主管機關流程",
                          systemImage: "checkmark.shield.fill",
                          tint: AppTheme.equipSeries,
                          destination: ProfessionalToolsHomeView())
            }
        }
    }

    private var featuredStrip: some View {
        let articles = featuredArticleIDs.compactMap { store.article(by: $0) }
        return Group {
            if !articles.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "推薦圖解", subtitle: "從管理委員會日常問題開始看")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(articles) { article in
                                let canAccess = iap.canAccess(article: article,
                                                               allArticles: store.allArticles)
                                NavigationLink {
                                    if canAccess { ArticleDetailView(article: article) }
                                    else { PaywallView() }
                                } label: {
                                    FeaturedArticleCard(article: article, locked: !canAccess)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "加值服務", subtitle: "圖解之外的查法規與測驗工具")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                QuickActionLink(title: "全文索引", caption: "依章節看條文摘要", systemImage: "doc.text.magnifyingglass", tint: AppTheme.blueprint, destination: FullTextHomeView())
                QuickActionLink(title: "圖卡快覽", caption: "Pinterest 式雙欄瀏覽", systemImage: "rectangle.grid.2x2.fill", tint: AppTheme.rust, destination: GalleryView())
                QuickActionLink(title: "題庫測驗", caption: "住戶與管委會情境題", systemImage: "checklist.checked", tint: AppTheme.structSeries, destination: CondoQuizView())
                QuickActionLink(title: "100 個工具", caption: "會議基金修繕檢核", systemImage: "wrench.and.screwdriver.fill", tint: AppTheme.resourceBlue, destination: ProfessionalToolsHomeView())
                QuickActionLink(title: "法規連結", caption: "全國法規與主管機關", systemImage: "link", tint: AppTheme.leaf, destination: RegulatoryResourcesView())
            }
        }
    }
}

private struct HomeHeroCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 154)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            LinearGradient(colors: [.black.opacity(0.46), .clear],
                           startPoint: .bottom,
                           endPoint: .center)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            VStack(alignment: .leading, spacing: 4) {
                Text("PRO REFERENCE")
                    .font(.system(size: 9, weight: .heavy))
                    .kerning(2)
                    .foregroundStyle(.white.opacity(0.82))
                Text("住戶、主委、物管公司都能快速對照")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
            .padding(16)
        }
        .frame(height: 154)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppTheme.line, lineWidth: 1))
    }
}

private struct StatCell: View {
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
        .background(.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.line, lineWidth: 1))
    }
}

private struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
            Text(subtitle)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppTheme.mute)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
        }
    }
}

private struct PremiumSearchLink: View {
    var body: some View {
        NavigationLink { SearchView() } label: {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(AppTheme.primary, in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text("快速搜尋條號、會議、基金、修繕")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(AppTheme.primary)
                    Text("搜尋 250 張圖解與條文摘要")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.mute)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppTheme.mute)
            }
            .padding(12)
            .background(AppTheme.resourceSurface, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct SeriesPillCard: View {
    let seriesId: String
    let title: String
    let en: String
    let range: String
    let icon: IsoIconKind
    let summary: String
    let count: Int

    var body: some View {
        HStack(spacing: 10) {
            IsoIcon(kind: icon, size: 46)
            VStack(alignment: .leading, spacing: 3) {
                Text(en)
                    .font(.custom("Times New Roman", size: 9))
                    .italic()
                    .kerning(1.4)
                    .foregroundStyle(AppTheme.color(for: seriesId))
                Text(title)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                Text(summary)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.mute)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                HStack(spacing: 5) {
                    Text(range)
                    Text("\(count) 張")
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppTheme.color(for: seriesId))
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(minHeight: 92)
        .background(AppTheme.kraft, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line, lineWidth: 1))
    }
}

private struct FocusLink<Destination: View>: View {
    let title: String
    let caption: String
    let systemImage: String
    let tint: Color
    let destination: Destination

    var body: some View {
        NavigationLink { destination } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(tint, in: RoundedRectangle(cornerRadius: 9))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.mute)
                }
                Text(title)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                Text(caption)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.mute)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 114, alignment: .topLeading)
            .background(.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct UnlockPromoCard: View {
    let isUnlocked: Bool

    var body: some View {
        NavigationLink { PaywallView() } label: {
            HStack(spacing: 12) {
                Image(systemName: isUnlocked ? "checkmark.seal.fill" : "crown.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.rust, in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 3) {
                    Text(isUnlocked ? "已解鎖完整圖解" : "Pro / 解鎖完整圖解")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(AppTheme.primary)
                    Text(isUnlocked ? "250 張圖解、完整工具與題庫已可使用" : "一次買斷・250 張圖解・完整工具・無訂閱無廣告")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.mute)
                        .lineLimit(2)
                }
                Spacer()
                Text(isUnlocked ? "查看" : "Pro 解鎖")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.primary, in: Capsule())
            }
            .padding(14)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct FeaturedArticleCard: View {
    let article: Article
    let locked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ZStack(alignment: .topTrailing) {
                ResourceJPEG(name: article.imageAssetName)
                    .aspectRatio(3/4, contentMode: .fill)
                    .frame(width: 86, height: 112)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                if locked {
                    Color.black.opacity(0.34)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(7)
                }
            }
            Text(article.title_zh)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
                .lineLimit(2)
                .frame(width: 114, alignment: .leading)
            Text(article.article_no)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AppTheme.mute)
                .lineLimit(1)
        }
        .padding(10)
        .frame(width: 134, alignment: .leading)
        .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line, lineWidth: 1))
    }
}

private struct QuickActionLink<Destination: View>: View {
    let title: String
    let caption: String
    let systemImage: String
    let tint: Color
    let destination: Destination

    var body: some View {
        NavigationLink { destination } label: {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(tint, in: RoundedRectangle(cornerRadius: 9))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(AppTheme.primary)
                    Text(caption)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppTheme.mute)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                Spacer(minLength: 0)
            }
            .padding(11)
            .frame(minHeight: 60)
            .background(.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(AppTheme.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Big series card

private struct BigSeriesCard: View {
    let seriesId: String
    let title: String
    let en: String
    let range: String
    let icon: IsoIconKind
    let count: Int

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(en)
                    .font(.custom("Times New Roman", size: 10))
                    .italic().kerning(1.8)
                    .foregroundStyle(AppTheme.mute)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(AppTheme.line, in: Capsule())
                Text(title)
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                Text(range)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.mute)
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(count)")
                        .font(.custom("Times New Roman", size: 32))
                        .italic()
                        .foregroundStyle(AppTheme.color(for: seriesId))
                    Text("張")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.mute)
                }
            }
            .padding(.leading, 20).padding(.vertical, 18)
            Spacer()
            IsoIcon(kind: icon, size: 110)
                .padding(.trailing, 12).padding(.vertical, 10)
        }
        .frame(minHeight: 130)
        .background(AppTheme.kraft, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.line, lineWidth: 1))
    }
}

// MARK: - Chapter list inside a series

struct SeriesChapterListView: View {
    let seriesId: String
    let seriesTitle: String
    @EnvironmentObject var store: ArticleStore

    private func iconKind(_ id: String) -> IsoIconKind {
        switch id {
        case "01": return .boxBasic;   case "02": return .stairs
        case "03": return .lightbulb;  case "04": return .boxBand
        case "05": return .gear;       case "06": return .wheelchair
        case "07": return .columnSmall
        default: return .gear
        }
    }

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()
            List(store.chapters(inSeries: seriesId)) { ch in
                NavigationLink { ChapterGridView(chapter: ch) } label: {
                    HStack(spacing: 12) {
                        IsoIcon(kind: iconKind(ch.id), size: 40)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Ch \(ch.id)")
                                .font(.custom("Times New Roman", size: 11))
                                .italic().kerning(1.8)
                                .foregroundStyle(AppTheme.rust)
                            Text(ch.title_zh)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(AppTheme.primary)
                            Text(ch.intro)
                                .font(.system(size: 11))
                                .foregroundStyle(AppTheme.mute)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text("\(store.articles(inChapter: ch.id).count)")
                            .font(.custom("Times New Roman", size: 14))
                            .italic().foregroundStyle(AppTheme.mute)
                    }
                    .padding(.vertical, 10)
                }
                .listRowBackground(AppTheme.paper)
                .listRowSeparatorTint(AppTheme.line)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(seriesTitle)
    }
}

// MARK: - Thumbnail grid for one chapter

struct ChapterGridView: View {
    let chapter: Chapter
    @EnvironmentObject var store: ArticleStore
    @EnvironmentObject var iap: IAPManager

    private let cols = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(store.articles(inChapter: chapter.id)) { article in
                        let canAccess = iap.canAccess(article: article,
                                                       allArticles: store.allArticles)
                        NavigationLink {
                            if canAccess { ArticleDetailView(article: article) }
                            else { PaywallView() }
                        } label: {
                            ThumbnailCard(article: article, locked: !canAccess)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                Spacer().frame(height: 80)
            }
        }
        .navigationTitle("Ch\(chapter.id) \(chapter.title_zh)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ThumbnailCard: View {
    let article: Article
    let locked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                ResourceJPEG(name: article.imageAssetName)
                    .aspectRatio(3/4, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        if locked {
                            Color.black.opacity(0.42)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.white).font(.title2)
                        }
                    }
                Text(article.id)
                    .font(.custom("Times New Roman", size: 10)).italic()
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(.thinMaterial, in: Capsule())
                    .padding(6)
            }
            Text(article.title_zh)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.primary)
                .lineLimit(2)
        }
        .padding(10)
        .background(AppTheme.kraft, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line, lineWidth: 1))
    }
}
