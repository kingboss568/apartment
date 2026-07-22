//
//  ContentView.swift
//  公寓大廈管理條例全圖解
//
//  Six-tab commercial navigation: illustrations, full text, gallery, knowledge,
//  100 interactive tools, and regulatory resources.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var iapManager: IAPManager
    @AppStorage("hasShownOnboarding") private var hasShownOnboarding = false
    @State private var selectedTab = AppLaunchOptions.initialTab
    @State private var showingScreenshotPaywall = AppLaunchOptions.showPaywall

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0: IllustrationsHomeView()
                case 1: FullTextHomeView()
                case 2: GalleryView()
                case 3: CondoQuizView()
                case 4:
                    if let tool = AppLaunchOptions.tool {
                        NavigationStack { ProfessionalToolDetailView(tool: tool) }
                    } else {
                        ProfessionalToolsHomeView()
                    }
                case 5: RegulatoryResourcesView()
                default: IllustrationsHomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            FloatingTabBar(selected: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(AppTheme.paper.ignoresSafeArea())
        .sheet(isPresented: .init(
            get: { !hasShownOnboarding && !AppLaunchOptions.isScreenshotMode },
            set: { hasShownOnboarding = !$0 }
        )) {
            OnboardingView { hasShownOnboarding = true }
        }
        .sheet(isPresented: $showingScreenshotPaywall) {
            PaywallView()
        }
        .onAppear {
            if AppLaunchOptions.isScreenshotMode {
                hasShownOnboarding = true
            }
        }
    }
}

private enum AppLaunchOptions {
    private static let arguments = ProcessInfo.processInfo.arguments

    static var isScreenshotMode: Bool {
        arguments.contains("--screenshot")
            || arguments.contains("-screenshot-mode")
            || ProcessInfo.processInfo.environment["CONDO_SCREENSHOT_TAB"] != nil
    }

    static var showPaywall: Bool {
        arguments.contains("--screenshot-paywall")
            || arguments.contains("-screenshot-paywall")
            || ProcessInfo.processInfo.environment["CONDO_SCREENSHOT_PAYWALL"] == "1"
    }

    static var initialTab: Int {
        for flag in ["--screenshot-tab", "-screenshot-tab"] {
            if let index = arguments.firstIndex(of: flag),
               arguments.indices.contains(index + 1),
               let tab = Int(arguments[index + 1]) {
                return min(max(tab, 0), 5)
            }
        }
        switch ProcessInfo.processInfo.environment["CONDO_SCREENSHOT_TAB"] {
        case "fulltext": return 1
        case "gallery": return 2
        case "common", "quiz": return 3
        case "calculator", "tools": return 4
        case "resources": return 5
        default: return 0
        }
    }

    static var tool: ProfessionalTool? {
        guard let index = arguments.firstIndex(of: "--screenshot-tool"),
              arguments.indices.contains(index + 1),
              let id = Int(arguments[index + 1]) else { return nil }
        return ProfessionalToolCatalog.tools.first { $0.id == id }
    }
}

private struct FloatingTabBar: View {
    @Binding var selected: Int

    private let tabs: [(label: String, icon: String)] = [
        ("圖解", "square.stack.3d.up.fill"),
        ("條文", "doc.text.fill"),
        ("快覽", "rectangle.grid.2x2.fill"),
        ("題庫", "checkmark.circle.fill"),
        ("工具", "wrench.and.screwdriver.fill"),
        ("資源", "books.vertical.fill")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                        selected = index
                    }
                } label: {
                    tabItem(label: tab.label, icon: tab.icon, active: selected == index)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("tab-\(index)")
            }
        }
        .padding(.horizontal, 6)
        .frame(height: 64)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: AppTheme.primary.opacity(0.18), radius: 20, x: 0, y: 6)
        .padding(.horizontal, 14)
        .padding(.bottom, 18)
    }

    private func tabItem(label: String, icon: String, active: Bool) -> some View {
        let color: Color = active ? AppTheme.rust : AppTheme.mute
        return VStack(spacing: 4) {
            ZStack {
                if active {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(AppTheme.rust)
                        .frame(width: 18, height: 3)
                        .offset(y: -15)
                }
                Image(systemName: icon)
                    .font(.system(size: 18, weight: active ? .heavy : .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(color)
                    .frame(width: 22, height: 22)
            }
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ArticleStore.preview)
        .environmentObject(BookmarkStore())
        .environmentObject(IAPManager())
}
