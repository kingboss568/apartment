//
//  IAPManager.swift
//  公寓大廈管理條例全圖解
//
//  StoreKit 2 wrapper for the single non-consumable unlock product.
//

import Foundation
import StoreKit

@MainActor
final class IAPManager: ObservableObject {

    @Published private(set) var isUnlocked: Bool = false
    @Published private(set) var product: Product?
    @Published private(set) var purchaseError: String?
    @Published private(set) var isPurchasing: Bool = false
    @Published private(set) var isLoadingProduct: Bool = false

    private var transactionTask: Task<Void, Never>?
    private let fallbackDisplayPrice = Constants.fallbackPriceText

    var purchaseButtonPriceText: String {
        fallbackDisplayPrice
    }

    // MARK: - Setup

    func loadProduct() async {
        guard !isLoadingProduct else { return }
        isLoadingProduct = true
        defer { isLoadingProduct = false }
        purchaseError = nil
        do {
            let products = try await Product.products(for: [Constants.unlockProductID])
            if let product = products.first {
                self.product = product
            } else {
                self.product = nil
            }
        } catch {
            self.product = nil
        }
    }

    func clearPurchaseError() {
        purchaseError = nil
    }

    /// Re-check current entitlements; flips isUnlocked.
    func refreshEntitlements() async {
        await loadProduct()
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, t.productID == Constants.unlockProductID {
                self.isUnlocked = true
                return
            }
        }
        self.isUnlocked = false
    }

    /// Background listener for transactions (refunds, family sharing, etc.)
    func startTransactionListener() async {
        transactionTask?.cancel()
        transactionTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let t) = result {
                    await t.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
    }

    // MARK: - User actions

    func purchase() async {
        if product == nil {
            await loadProduct()
        }
        guard let product else {
            purchaseError = "商品尚未載入完成，請再點一次「立即解鎖」。"
            return
        }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let t) = verification {
                    await t.finish()
                    await refreshEntitlements()
                }
            case .userCancelled:
                break
            case .pending:
                purchaseError = "付款待確認，完成後將自動解鎖。"
            @unknown default:
                break
            }
        } catch {
            purchaseError = "購買失敗：\(error.localizedDescription)"
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            purchaseError = "恢復購買失敗：\(error.localizedDescription)"
        }
    }

    // MARK: - Gating helper

    /// 圖解存取管控：
    ///   - 權利義務篇（design）開放前 freeDesignIllustrationCount 張
    ///   - 會議基金篇（struct）、管理罰則篇（equip）需解鎖
    ///   - 排序後取前 N，確保免費預覽順序穩定（不依賴 JSON 原始順序）
    func canAccess(article: Article, allArticles: [Article]) -> Bool {
        if isUnlocked { return true }
        guard article.seriesId == "design" else { return false }
        let designArticles = allArticles
            .filter { $0.seriesId == "design" }
            .sorted {
                if $0.chapter != $1.chapter { return $0.chapter < $1.chapter }
                return $0.serial < $1.serial
            }
        let freeIDs = Set(designArticles.prefix(Constants.freeDesignIllustrationCount).map(\.id))
        return freeIDs.contains(article.id)
    }

    /// 圖解存取管控（輕量版，不需要 allArticles）：
    ///   - Ch01 依序開放前 freeDesignIllustrationCount 張作為免費預覽
    ///   - 其餘圖解全部鎖定
    func canAccessIllustration(for article: Article) -> Bool {
        if isUnlocked { return true }
        guard article.seriesId == "design" else { return false }
        return article.chapter == "01" && article.serial <= Constants.freeDesignIllustrationCount
    }

    /// 常用條文存取管控：
    ///   - groupIndex 0（基本定義與權利義務）→ 前 freeCommonClausesFirstGroup 條免費
    ///   - groupIndex 1–7 → 只開放第 freeCommonClausesOtherGroups 條
    func canAccess(commonClauseArticleId: String,
                   groupIndex: Int,
                   allIdsInGroup: [String]) -> Bool {
        if isUnlocked { return true }
        let freeCount = groupIndex == 0
            ? Constants.freeCommonClausesFirstGroup
            : Constants.freeCommonClausesOtherGroups
        return allIdsInGroup.prefix(freeCount).contains(commonClauseArticleId)
    }
}
