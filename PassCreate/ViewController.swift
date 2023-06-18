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

import UIKit

let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
let appBuildNum = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

let excluded = ["!","$","'","(",")",",",".","/","0","1",":",";","I","O","[","]","_","`","l","o","{","}","|","~"]

class ViewController: UIViewController {

    let userDefaults = UserDefaults.standard
    let feedBack = UINotificationFeedbackGenerator()
    var fadeOutTimer = Timer()
    let passHistoryCellId = "passHistoryTableViewCell"

    var passHistory = [String](repeating: "", count: 20)
    
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var copyAlertLabel: UILabel!
    @IBOutlet weak var howToUseLabel: UILabel!
    @IBOutlet var generateButton: UIButton!
    @IBOutlet weak var tapRecognizer: UIButton!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var toolBarButton: UIBarButtonItem!
    @IBOutlet weak var passHistoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passHistoryTableView.delegate = self
        passHistoryTableView.dataSource = self
        
        // 触感フィードバック準備
        feedBack.prepare()
        
        //macOSで動作時のウィンドウサイズ指定
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
            windowScene.sizeRestrictions?.minimumSize = CGSize(width: 550, height: 800)
            windowScene.sizeRestrictions?.maximumSize = CGSize(width: 550, height: 800)
        }

        setupUserDefaults()
        setupView()
    }

    private func setupUserDefaults() {
        let defaultLetterType: [String: Bool] = [
            LetterType.upperCase.rawValue: true,
            LetterType.lowerCase.rawValue: true,
            LetterType.number.rawValue: true,
            LetterType.symbol.rawValue: false
        ]
        userDefaults.register(defaults: [PassLength.passLength.rawValue: 10])
        userDefaults.register(defaults: [LetterType.letterType.rawValue: defaultLetterType])
        userDefaults.register(defaults: [ExcludeCharacters.excludeCharacters.rawValue: false])
    }

    private func setupView() {

        let screenWidth: CGFloat = self.view.frame.width
        let screenHeight: CGFloat = self.view.frame.height

        // パスワード表示ラベル
        passLabel.text = NSLocalizedString("生成ボタンを押してください", comment: "")
        passLabel.font = UIFont.monospacedSystemFont(ofSize: 22, weight: .regular)
        passLabel.frame = CGRect(x: screenWidth/8, y: screenHeight-215, width: screenWidth*0.75, height: 60)
        passLabel.textAlignment = NSTextAlignment.center // 中央に配置
        passLabel.numberOfLines = 2
        // コピー通知ラベル設定
        copyAlertLabel.text = NSLocalizedString("コピーしました", comment: "")
        copyAlertLabel.frame = CGRect(x: screenWidth/4, y: screenHeight-240, width: screenWidth/2, height: 30)
        copyAlertLabel.layer.cornerRadius = 10
        copyAlertLabel.clipsToBounds = true // 領域外への描画を許可しない
        copyAlertLabel.textAlignment = NSTextAlignment.center
        copyAlertLabel.numberOfLines = 2
        copyAlertLabel.alpha = 0.0
        // 使用方法表示
        howToUseLabel.text = NSLocalizedString("↑タップでコピーされます↑", comment: "")
        howToUseLabel.frame = CGRect(x: screenWidth/8, y: screenHeight-160, width: screenWidth*0.75, height: 30)
        howToUseLabel.textAlignment = NSTextAlignment.center
        howToUseLabel.alpha = 0.0
        // 生成ボタン設定
        generateButton.setTitle(NSLocalizedString("パスワードを生成", comment: ""), for: .normal)
        generateButton.frame = CGRect(x: screenWidth/8, y: screenHeight-130, width: screenWidth*0.75, height: 50)
        generateButton.layer.cornerRadius = 10
        // コピーボタン
        tapRecognizer.setTitle("", for: .normal)
        tapRecognizer.frame = CGRect(x: screenWidth/8, y: screenHeight-205, width: screenWidth*0.75, height: 60)
        // ツールバー設定(ボタンではない)
        toolBar.frame = CGRect(x: 0, y: screenHeight-65, width: screenWidth, height: 45)
    }
    
    // 生成ボタン処理
    @IBAction func createButton(_ sender: Any) {
        howToUseLabel.alpha = 1.0
        if passLabel.text != NSLocalizedString("生成ボタンを押してください", comment: "") {
            // 改行を削除
            let trimmed: String = passLabel.text!.trimmingCharacters(in: .newlines)
            passHistory.insert(trimmed, at: 0) // 先頭に要素を追加
            passHistory.removeLast()
            passHistoryTableView.reloadData()
        }
        let passLength = userDefaults.integer(forKey: PassLength.passLength.rawValue)
        passLabel.text = generatePass(length: passLength)
    }

    // passLabel(button)タップ時処理
    @IBAction func passLabelTap(_ sender: Any) {
        if passLabel.text != NSLocalizedString("生成ボタンを押してください", comment: "") {
            copyToClipboard(copyTarget: passLabel.text!)
        }
    }

    // 設定画面へ移動
    @IBAction func gotoConfigPage(_ sender: Any) {
        let configVC = self.storyboard?.instantiateViewController(identifier: "configView")
        configVC?.modalTransitionStyle = .coverVertical
        present(configVC!, animated: true, completion: nil)
    }

    // パスワード生成関数
    private func generatePass(length: Int) -> String {
        let upperCases = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        let lowerCases = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
        let numbers = ["1","2","3","4","5","6","7","8","9","0"]
        let symbols = ["`","~","!","@","#","$","%","^","&","*","(",")","-","_","=","+","[","{","]","}","|",";",":","'",",","<",".",">","/","?"]

        var usedData: [String] = []
        var result = ""

        let letterType = userDefaults.dictionary(forKey: "letterType") as! [String: Bool]

        if letterType["upperCase"] == true {
            usedData += upperCases
        }
        if letterType["lowerCase"] == true {
            usedData += lowerCases
        }
        if letterType["number"] == true {
            usedData += numbers
        }
        if letterType["symbol"] == true {
            usedData += symbols
        }

        for _ in 0..<length {
            var randomValue: Int = 0
            let shouldExclude: Bool = userDefaults.bool(forKey: ExcludeCharacters.excludeCharacters.rawValue)
            repeat {
                randomValue = Int.random(in: 0..<usedData.endIndex)
            } while excluded.contains(usedData[randomValue]) && shouldExclude
            if result.count == 20 {
                result += "\n"
            }
            result += usedData[randomValue]
        }

        return result
    }

    private func copyToClipboard(copyTarget: String) {
        // 改行を削除
        let trimmed = copyTarget.trimmingCharacters(in: .newlines)
        // クリップボードにコピー
        UIPasteboard.general.string = trimmed
        // 触覚フィードバック
        feedBack.notificationOccurred(.success)
        // タイマー停止ののちフェードアウト実行
        fadeOutTimer.invalidate()
        copyAlertLabel.alpha = 1.0
        // タップから0.5秒後に実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.fadeOutTimer = Timer.scheduledTimer(
                timeInterval: 0.05,
                target: self,
                selector: #selector(self.fadeOutCopyAlertLabel),
                userInfo: nil,
                repeats: true
            )
        }
    }

    // 0.05秒ごとに実行される関数
    @objc func fadeOutCopyAlertLabel() {
        copyAlertLabel.alpha -= 0.1
        // 透明度がなくなったらタイマーを止める
        if (copyAlertLabel.alpha <= 0.0) {
            fadeOutTimer.invalidate()
        }
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
        if let cellContent = cell?.textLabel?.text, cellContent != "" {
            copyToClipboard(copyTarget: cellContent)
        }
    }
}

