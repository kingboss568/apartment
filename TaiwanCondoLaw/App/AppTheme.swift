//
//  AppTheme.swift
//  公寓大廈管理條例全圖解
//
//  Centralized colors & typography — 山形屋等角投影設計系統 v2
//

import SwiftUI

enum AppTheme {
    // ─── 主要品牌色 ───────────────────────────────────────────
    /// 深墨綠 / civic ink  ← 法規工具主色
    static let primary       = Color(red: 0.071, green: 0.188, blue: 0.169)
    /// 琥珀金 / amber      ← CTA / active 強調色
    static let rust          = Color(red: 0.753, green: 0.463, blue: 0.149)

    // ─── 紙本背景 ─────────────────────────────────────────────
    static let paper         = Color(red: 0.973, green: 0.976, blue: 0.965)
    static let kraft         = Color(red: 0.910, green: 0.934, blue: 0.914)
    static let paperBG       = Color(red: 0.894, green: 0.929, blue: 0.910)

    // ─── 三大篇系列配色（等角圖面色） ─────────────────────────
    /// kraft-2 / 米黃淺  #cdb88a  設計篇
    static let designSeries  = Color(red: 0.180, green: 0.420, blue: 0.376)
    static let structSeries  = Color(red: 0.439, green: 0.373, blue: 0.671)
    static let equipSeries   = Color(red: 0.646, green: 0.322, blue: 0.204)

    // ─── 等角圖面輔助色 ───────────────────────────────────────
    /// 窗戶天空藍 / sky  #a8c4d8
    static let sky           = Color(red: 0.659, green: 0.769, blue: 0.847)
    /// 暖黃金 / gold     #f0c674  燈泡 / 星號 / 齒輪
    static let gold          = Color(red: 0.941, green: 0.776, blue: 0.455)
    static let mute          = Color(red: 0.431, green: 0.475, blue: 0.455)
    static let line          = Color(red: 0.820, green: 0.859, blue: 0.839)
    /// 葉綠 / leaf       #7d8f60
    static let leaf          = Color(red: 0.490, green: 0.561, blue: 0.376)
    /// 藍圖深藍 / blueprint #274060
    static let blueprint     = Color(red: 0.153, green: 0.251, blue: 0.376)
    /// 法規資源藍 / resource #2f6f8f
    static let resourceBlue  = Color(red: 0.184, green: 0.435, blue: 0.561)
    /// 資源頁淡底 / resource surface #edf4f3
    static let resourceSurface = Color(red: 0.929, green: 0.957, blue: 0.953)

    // ─── 計算結果三段式回饋 ────────────────────────────────────
    static let pass          = Color.green
    static let warn          = Color.orange
    static let fail          = Color.red

    // ─── 通用背景 ─────────────────────────────────────────────
    static let cardBG        = Color(.secondarySystemBackground)

    // ─── 已棄用相容名稱（保留以防其他舊檔引用） ──────────────
    static var accentBlue: Color { sky }
    static var accentGold: Color { gold }

    // ─── Series helper ─────────────────────────────────────────
    static func color(for seriesId: String) -> Color {
        switch seriesId {
        case "design":  return designSeries
        case "struct":  return structSeries
        case "equip":   return equipSeries
        default:        return primary
        }
    }
}
