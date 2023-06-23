//
//  ViewController.swift
//  Dobermann -強固なパスワードをワンタップで-
//
//  Created by 丹羽雄一朗
//  Copyright © 2020-2021 Niwa Yuichiro. All rights reserved.
//
//  2020/03/30 Alpha 1.0.0(1)
//       04/05 Alpha 2.0.0(2)
//       04/07 Alpha 2.1.0(3)
//       04/10 Alpha 2.2.0(4)
//       04/13 Alpha 3.0.0(5)
//       04/22 Alpha 3.0.1(6)
//       05/02 Alpha 3.1.0(7)
//  2021/08/01 Alpha 4.0.0(8)
//       12/18 Alpha 4.0.1(9)
//  2022/04/17 Alpha 4.0.2(10)
//       04/20 Alpha 4.0.3(11)
//  2023/06/19 Alpha 4.1.0(12)
//
//TODO: パスワードの文字数を設定するUIStepperを直す
//TODO: UIをアップデート

import UIKit

let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let appBuildNum = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

let excluded = ["!","$","'","(",")",",",".","/","0","1",":",";","I","O","[","]","_","`","l","o","{","}","|","~"]

class ViewController: UIViewController {

    private let userDefaults = UserDefaults.standard
    private let password = Password()

    private let passHistoryCellId = "passHistoryTableViewCell"

    private var fadeOutTimer = Timer()

    private var passHistory = [String](repeating: "", count: 20)

    @IBOutlet weak var copyAlertLabel: UILabel!
    @IBOutlet var generatePassButton: UIButton!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var toolBarButton: UIBarButtonItem!
    @IBOutlet weak var passHistoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passHistoryTableView.delegate = self
        passHistoryTableView.dataSource = self

        setupUserDefaults()
        setupView()
    }

    private func setupUserDefaults() {
        let letterTypeKey: String = LetterType.letterType.rawValue
        let upperCaseKey: String = LetterType.upperCase.rawValue
        let lowerCaseKey: String = LetterType.lowerCase.rawValue
        let numberKey: String = LetterType.number.rawValue
        let symbolKey: String = LetterType.symbol.rawValue
        let passLengthKey: String = PassLength.passLength.rawValue
        let excludeCharactersKey: String = ExcludeCharacters.excludeCharacters.rawValue

        let defaultLetterType: [String: Bool] = [
            upperCaseKey: true,
            lowerCaseKey: true,
            numberKey: true,
            symbolKey: false
        ]
        userDefaults.register(defaults: [passLengthKey: 10])
        userDefaults.register(defaults: [letterTypeKey: defaultLetterType])
        userDefaults.register(defaults: [excludeCharactersKey: false])
    }

    private func setupView() {

        let screenWidth: CGFloat = self.view.frame.width
        let screenHeight: CGFloat = self.view.frame.height

        //macOSで動作時のウィンドウサイズ指定
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
            windowScene.sizeRestrictions?.minimumSize = CGSize(width: 550, height: 800)
            windowScene.sizeRestrictions?.maximumSize = CGSize(width: 550, height: 800)
        }

        // コピー通知ラベル設定
        copyAlertLabel.text = NSLocalizedString("コピーしました", comment: "")
        copyAlertLabel.frame = CGRect(x: screenWidth/4, y: screenHeight-240, width: screenWidth/2, height: 30)
        copyAlertLabel.layer.cornerRadius = 10
        copyAlertLabel.clipsToBounds = true // 領域外への描画を許可しない
        copyAlertLabel.textAlignment = NSTextAlignment.center
        copyAlertLabel.numberOfLines = 2
        copyAlertLabel.alpha = 0.0
        // 生成ボタン設定
        generatePassButton.setTitle(NSLocalizedString("パスワードを生成", comment: ""), for: .normal)
        generatePassButton.layer.cornerRadius = 10
    }
    
    // 生成ボタン処理
    @IBAction func generatePassButtonTapped(_ sender: Any) {
        let passLength = userDefaults.integer(forKey: PassLength.passLength.rawValue)
        let newPass = password.generate(length: passLength)
        shiftPassHistoryTableView(newPass: newPass)
    }

    private func shiftPassHistoryTableView(newPass: String) {
        // 改行を削除
        let trimmed: String = newPass.trimmingCharacters(in: .newlines)
        passHistory.insert(trimmed, at: 0) // 先頭に要素を追加
        passHistory.removeLast()
        passHistoryTableView.reloadData()
    }

    // 設定画面へ移動
    @IBAction func gotoConfigPage(_ sender: Any) {
        let configVC = self.storyboard?.instantiateViewController(identifier: "configView")
        configVC?.modalTransitionStyle = .coverVertical
        present(configVC!, animated: true, completion: nil)
    }

    private func copyToClipboard(copyTarget: String) {
        // 改行を削除
        let trimmed = copyTarget.trimmingCharacters(in: .newlines)
        // クリップボードにコピー
        UIPasteboard.general.string = trimmed
        //触覚フィードバック
        hapticFeedback(type: .success)
        //copyAlertLabelをフェードアウト
        fadeOutCopyAlertLabel()
    }

    private func hapticFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let feedBack = UINotificationFeedbackGenerator()
        feedBack.prepare()
        feedBack.notificationOccurred(type)
    }

    private func fadeOutCopyAlertLabel() {
        fadeOutTimer.invalidate()
        copyAlertLabel.alpha = 1.0
        // タップから1秒後にタイマーを実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.fadeOutTimer = Timer.scheduledTimer(
                timeInterval: 0.05,
                target: self,
                selector: #selector(self.lowerAlpha),
                userInfo: nil,
                repeats: true
            )
        }
    }

    // 0.05秒ごとに実行される
    @objc func lowerAlpha() {
        // 透明度がなくなったらタイマーを止める
        if copyAlertLabel.alpha <= 0 {
            fadeOutTimer.invalidate()
        }
        copyAlertLabel.alpha -= 0.1
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // セクション数を指定
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // セクションタイトルを指定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("履歴", comment: "")
    }
    
    // セル数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return passHistory.count
        } else {
            return 0
        }
    }
    
    // セルを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: passHistoryCellId, for: indexPath)
        // データのないセルを非表示
        passHistoryTableView.tableFooterView = UIView(frame: .zero)
        // セルに表示する値を設定する
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = passHistory[indexPath.row]
            cell.textLabel!.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .regular)
        default:
            break
        }
        return cell
    }
    
    // 選択したセルの情報を取得
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルを取得する
        let cell = tableView.cellForRow(at:indexPath)
        // タップ後に灰色を消す
        tableView.deselectRow(at: indexPath, animated: true)
        // クリップボードにコピー
        if let cellContent = cell?.textLabel?.text, !cellContent.isEmpty {
            copyToClipboard(copyTarget: cellContent)
        }
    }
}

