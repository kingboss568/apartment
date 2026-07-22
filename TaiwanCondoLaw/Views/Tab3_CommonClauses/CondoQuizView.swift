//
//  CondoQuizView.swift
//  公寓大廈管理條例全圖解
//

import SwiftUI

struct CondoQuizView: View {
    @EnvironmentObject private var iap: IAPManager
    @State private var selectedAnswers: [CondoQuizQuestion.ID: Int] = [:]
    @State private var showPaywall = false

    private let questions = CondoQuizQuestion.bank

    private var visibleQuestions: [CondoQuizQuestion] {
        iap.isUnlocked ? questions : Array(questions.prefix(Constants.freeQuizQuestionCount))
    }

    private var score: Int {
        visibleQuestions.filter { selectedAnswers[$0.id] == $0.correctIndex }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        scoreCard
                        ForEach(visibleQuestions) { question in
                            questionCard(question)
                        }
                        if !iap.isUnlocked {
                            lockedQuizCard
                        }
                        Spacer().frame(height: 104)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 54)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CONDO LAW QUIZ")
                .font(.system(size: 9, weight: .medium))
                .italic()
                .kerning(3)
                .foregroundStyle(AppTheme.mute)
            Text("題庫測驗")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
            Text("用住戶、管委會、公共基金、規約與罰則情境快速複習。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.mute)
            Rectangle().fill(AppTheme.line).frame(height: 1).padding(.top, 4)
        }
    }

    private var scoreCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("目前答對")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.mute)
                Text("\(score) / \(visibleQuestions.count)")
                    .font(.custom("Times New Roman", size: 34))
                    .italic()
                    .foregroundStyle(AppTheme.resourceBlue)
            }
            Spacer()
            if !iap.isUnlocked {
                Button {
                    showPaywall = true
                } label: {
                    Label("解鎖全部題庫", systemImage: "lock.fill")
                        .font(.system(size: 13, weight: .heavy))
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.rust)
            }
        }
        .padding(16)
        .background(AppTheme.resourceSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line, lineWidth: 1))
    }

    private func questionCard(_ question: CondoQuizQuestion) -> some View {
        let selected = selectedAnswers[question.id]
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(question.article)
                    .font(.custom("Times New Roman", size: 12))
                    .italic()
                    .foregroundStyle(AppTheme.rust)
                Spacer()
                Text(question.chapter)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppTheme.mute)
            }
            Text(question.prompt)
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
                .lineSpacing(3)

            VStack(spacing: 8) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { idx, option in
                    Button {
                        selectedAnswers[question.id] = idx
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: answerSymbol(question: question, index: idx, selected: selected))
                                .foregroundStyle(answerColor(question: question, index: idx, selected: selected))
                            Text(option)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppTheme.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(answerColor(question: question, index: idx, selected: selected).opacity(selected == nil ? 0.18 : 0.55), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }

            if let selected {
                Text(selected == question.correctIndex ? question.correctNote : "解析：\(question.correctNote)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(selected == question.correctIndex ? AppTheme.leaf : AppTheme.fail)
                    .lineSpacing(3)
                    .padding(.top, 2)
            }
        }
        .padding(16)
        .background(AppTheme.kraft, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.line, lineWidth: 1))
    }

    private var lockedQuizCard: some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "lock.square.stack.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(AppTheme.rust)
                VStack(alignment: .leading, spacing: 4) {
                    Text("完整版解鎖 \(questions.count - Constants.freeQuizQuestionCount) 題情境測驗")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(AppTheme.primary)
                    Text("包含規約、會議、公共基金、起造人移交、管理維護公司與罰則。")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.mute)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.mute)
            }
            .padding(16)
            .background(.white, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func answerSymbol(question: CondoQuizQuestion, index: Int, selected: Int?) -> String {
        guard let selected else { return "circle" }
        if index == question.correctIndex { return "checkmark.circle.fill" }
        if index == selected { return "xmark.circle.fill" }
        return "circle"
    }

    private func answerColor(question: CondoQuizQuestion, index: Int, selected: Int?) -> Color {
        guard let selected else { return AppTheme.mute }
        if index == question.correctIndex { return AppTheme.leaf }
        if index == selected { return AppTheme.fail }
        return AppTheme.mute.opacity(0.65)
    }
}

private struct CondoQuizQuestion: Identifiable {
    let id: String
    let chapter: String
    let article: String
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let correctNote: String

    static let bank: [CondoQuizQuestion] = [
        .init(id: "q01", chapter: "權利義務", article: "第3條、第4條", prompt: "區分所有權通常包含哪一組權利關係？", options: ["只有室內專有部分", "專有部分、共用部分與基地權利", "只有停車位使用權"], correctIndex: 1, correctNote: "區分所有權須同時理解專有部分、共用部分與基地應有部分。"),
        .init(id: "q02", chapter: "共用部分", article: "第7條、第8條", prompt: "外牆、樓頂平台等共用部分變更或使用限制，通常應優先確認什麼？", options: ["住戶個人口頭同意", "規約、區權會決議與法定限制", "只要管委會主委同意即可"], correctIndex: 1, correctNote: "共用部分管理須回到規約、區分所有權人會議決議與法定不得違反事項。"),
        .init(id: "q03", chapter: "公共基金", article: "第18條、第20條", prompt: "公共基金與管理費收支最容易被要求補強的是哪個面向？", options: ["公告、專戶、憑證與移交紀錄", "只看主任委員個人記帳", "每年口頭說明一次"], correctIndex: 0, correctNote: "收支透明、專戶管理、憑證保存與移交紀錄是社區治理核心。"),
        .init(id: "q04", chapter: "規約會議", article: "第25條、第31條", prompt: "區分所有權人會議決議效力，最常需要核對哪一組資料？", options: ["出席人數、表決權數、決議門檻與通知程序", "只看會議場地是否在社區", "只看管理員是否到場"], correctIndex: 0, correctNote: "會議程序、出席與表決權數、決議門檻會直接影響決議效力。"),
        .init(id: "q05", chapter: "管委會", article: "第29條、第35條", prompt: "住戶要求閱覽規約、會議紀錄或財務資料時，管理組織應如何處理？", options: ["一律拒絕", "依規定提供閱覽或說明，並留下紀錄", "要求住戶先放棄異議"], correctIndex: 1, correctNote: "文件閱覽與資訊透明是降低社區爭議的重要機制。"),
        .init(id: "q06", chapter: "管理服務", article: "第42條、第43條", prompt: "管理維護公司或管理服務人員進場前，社區最該確認什麼？", options: ["是否有必要許可、契約範圍與職責邊界", "制服顏色是否一致", "是否願意免費加班"], correctIndex: 0, correctNote: "管理維護公司與服務人員涉及許可、契約、執業規範與禁止事項。"),
        .init(id: "q07", chapter: "起造人移交", article: "第56條、第57條", prompt: "新建社區移交時，最不應缺少哪類文件？", options: ["規約草約、圖說、設備資料與移交清冊", "住戶聊天截圖", "廣告文宣即可"], correctIndex: 0, correctNote: "起造人移交資料會影響後續修繕、責任歸屬與公共設施管理。"),
        .init(id: "q08", chapter: "罰則爭議", article: "第47條至第49條", prompt: "社區發生違規或爭議時，App 提供的罰則資訊應如何使用？", options: ["直接取代主管機關裁量", "作為速查輔助，仍以主管機關與正式法律意見為準", "只要截圖就能裁罰"], correctIndex: 1, correctNote: "罰則與爭議處理需以主管機關最新法規、事實證據與正式程序為準。"),
        .init(id: "q09", chapter: "欠費處理", article: "第21條、第22條", prompt: "管理費欠繳處理較穩妥的第一步是什麼？", options: ["立即停水停電", "確認費用依據、帳務明細與催告程序", "在社群公開住戶個資"], correctIndex: 1, correctNote: "欠費處理要先有清楚費用依據、明細、催告與合法程序。"),
        .init(id: "q10", chapter: "共用安全", article: "第16條", prompt: "防火巷弄、樓梯間或共同走廊堆置物品時，社區檢核重點是什麼？", options: ["是否影響安全、通行與法定共用部分使用", "物品是否看起來漂亮", "是否由長住戶放置"], correctIndex: 0, correctNote: "共用部分不得任意堆置或妨害安全與通行，應依規約與法令處理。"),
        .init(id: "q11", chapter: "會議通知", article: "第25條", prompt: "召開區分所有權人會議時，哪件事最容易造成程序爭議？", options: ["通知期間、議題、出席與委託程序不清", "會議茶點不足", "投影機亮度太低"], correctIndex: 0, correctNote: "通知與議程程序不清會使決議效力受到挑戰。"),
        .init(id: "q12", chapter: "修繕責任", article: "第10條、第11條", prompt: "漏水或管線修繕爭議通常要先釐清什麼？", options: ["專有、共用或約定專用部分的範圍", "誰比較早入住", "誰在群組發言最多"], correctIndex: 0, correctNote: "修繕責任通常先從專有部分、共用部分與約定專用範圍判斷。")
    ]
}

#Preview {
    CondoQuizView()
        .environmentObject(IAPManager())
}
