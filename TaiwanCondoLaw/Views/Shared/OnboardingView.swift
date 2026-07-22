//
//  OnboardingView.swift
//  公寓大廈管理條例全圖解
//
//  3-page intro shown on first launch.
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0

    var body: some View {
        VStack {
            TabView(selection: $page) {
                isoHousePage(
                    title: "250 張公寓法規圖解",
                    body: "把權利義務、共用部分、公共基金、會議與管委會重點整理成一張就懂的圖說。"
                ).tag(0)

                onboardPage(
                    icon: "checklist",
                    title: "題庫與社區檢核",
                    body: "用情境題和檢核表快速確認會議、修繕、基金、文件移交與爭議處理重點。",
                    color: AppTheme.structSeries
                ).tag(1)

                onboardPage(
                    icon: "lock.shield.fill",
                    title: "一次買斷 永久使用",
                    body: "免費試用前 20 張圖解與基礎題庫；NT$390 一次買斷全功能，沒有訂閱、沒有廣告。",
                    color: AppTheme.primary
                ).tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .background(AppTheme.paperBG.ignoresSafeArea())

            Button(page < 2 ? "下一步" : "開始使用") {
                if page < 2 {
                    withAnimation { page += 1 }
                } else {
                    onFinish()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.primary, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
            .padding()
        }
    }

    private func onboardPage(icon: String, title: String, body: String, color: Color) -> some View {
        VStack(spacing: 22) {
            Spacer()
            Image(systemName: icon).font(.system(size: 84)).foregroundStyle(color)
            Text(title).font(.largeTitle.bold())
            Text(body)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }

    private func isoHousePage(title: String, body: String) -> some View {
        VStack(spacing: 22) {
            Spacer()
            IsoHouseView(size: 220)
            Text(title).font(.largeTitle.bold())
            Text(body)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
