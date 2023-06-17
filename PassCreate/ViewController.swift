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
//

import UIKit

let globalVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

class ViewController: UIViewController {
    
    let feedBack = UINotificationFeedbackGenerator()
    var fadeOutTimer = Timer()
    let userDefaults = UserDefaults.standard
    
    let createTitle = [NSLocalizedString("履歴", comment: "")]
    var createContent0 = [String](repeating: "", count: 20)
    
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var copyAlertLabel: UILabel!
    @IBOutlet weak var howToUse: UILabel!
    @IBOutlet var createButton: UIButton!
    @IBOutlet weak var tapRecognizer: UIButton!
    @IBOutlet weak var createToolBar: UIToolbar!
    @IBOutlet weak var createToolBarButton: UIBarButtonItem!
    @IBOutlet weak var createTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createTableView.delegate = self
        createTableView.dataSource = self
        
        // 触感フィードバック準備
        feedBack.prepare()
        
        //macOSで動作時のウィンドウサイズ指定
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
            windowScene.sizeRestrictions?.minimumSize = CGSize(width: 550, height: 800)
            windowScene.sizeRestrictions?.maximumSize = CGSize(width: 550, height: 800)
        }
        
        // passLengthデフォルト値
        userDefaults.register(defaults: ["passLengthDataStore": "10"])
        // letterTypeデフォルト値
        userDefaults.register(defaults: ["letterType0DataStore": true])
        userDefaults.register(defaults: ["letterType1DataStore": true])
        userDefaults.register(defaults: ["letterType2DataStore": true])
        userDefaults.register(defaults: ["letterType3DataStore": false])

        setupView()
    }

    func setupView() {

        let screenWidth: CGFloat = self.view.frame.width
        let screenHeight: CGFloat = self.view.frame.height

        // パスワード表示ラベル
        passLabel.text = NSLocalizedString("生成ボタンを押してください", comment: "")
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
        howToUse.text = NSLocalizedString("↑タップでコピーされます↑", comment: "")
        howToUse.frame = CGRect(x: screenWidth/8, y: screenHeight-160, width: screenWidth*0.75, height: 30)
        howToUse.textAlignment = NSTextAlignment.center
        howToUse.alpha = 0.0
        // 生成ボタン設定
        createButton.setTitle(NSLocalizedString("パスワードを生成", comment: ""), for: .normal)
        createButton.frame = CGRect(x: screenWidth/8, y: screenHeight-130, width: screenWidth*0.75, height: 50)
        createButton.layer.cornerRadius = 10
        // コピーボタン
        tapRecognizer.setTitle("", for: .normal)
        tapRecognizer.frame = CGRect(x: screenWidth/8, y: screenHeight-205, width: screenWidth*0.75, height: 60)
        // ツールバー設定(ボタンではない)
        createToolBar.frame = CGRect(x: 0, y: screenHeight-65, width: screenWidth, height: 45)
    }
    
    // 生成ボタン処理
    @IBAction func createButton(_ sender: Any) {
        // 文字数ロード
        let length = userDefaults.object(forKey: "passLengthDataStore") as? String
        howToUse.alpha = 1.0
        if passLabel.text != NSLocalizedString("生成ボタンを押してください", comment: "") {
            // セルの内容をひとつずつ移動
            for i in stride(from: 19, to: 0, by: -1) {
                createContent0[i] = createContent0[i-1]
            }
            // 改行を消去
            let result = passLabel.text?.range(of: "\n")
            if let theRange = result {
                passLabel.text?.removeSubrange(theRange)
            }
            createContent0[0] = passLabel.text!
            // 再ロード
            createTableView.reloadData()
        }
        // 無効な文字の種類を判定
        if userDefaults.object(forKey: "letterType0DataStore") as! Bool == false && userDefaults.object(forKey: "letterType1DataStore") as! Bool == false && userDefaults.object(forKey: "letterType2DataStore") as! Bool == false && userDefaults.object(forKey: "letterType3DataStore") as! Bool == false {
            // ダイアログ
            let dialog = UIAlertController(title: NSLocalizedString("パスワードを生成できません", comment: ""), message: NSLocalizedString("パスワードに使用する文字を最低ひとつ\n選んでください。", comment: ""), preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog, animated: true, completion: nil)
        } else {
            // パスワード生成
            passLabel.text = passGenerate(length: Int(length!)!)
        }
    }

    // passLabel(button)タップ時処理
    @IBAction func passLabelTap(_ sender: Any) {
        if passLabel.text != NSLocalizedString("生成ボタンを押してください", comment: "") {
            // 改行を消去
            let befDelete = passLabel.text
            let result = passLabel.text?.range(of: "\n")
            if let theRange = result {
                passLabel.text?.removeSubrange(theRange)
            }
            // クリップボードにコピー
            UIPasteboard.general.string = passLabel.text!
            // 改行を復活
            passLabel.text = befDelete
            // 触覚フィードバック
            feedBack.notificationOccurred(.success)
            // タイマー停止ののちフェードアウト実行
            fadeOutTimer.invalidate()
            copyAlertLabel.alpha = 1.0
            // タップから0.5秒後に実行
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.fadeOutTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.fade_in), userInfo: nil, repeats: true)
            }
        }
    }

    // 設定画面へ移動
    @IBAction func gotoConfigPage(_ sender: Any) {
        let configVC = self.storyboard?.instantiateViewController(identifier: "configPage")
        configVC?.modalTransitionStyle = .coverVertical
        present(configVC!, animated: true, completion: nil)
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
        return createTitle[section] as String
    }
    
    // セル数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return createContent0.count
        } else {
            return 0
        }
    }
    
    // セルを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを指定する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "create", for: indexPath)
        // データのないセルを非表示
        createTableView.tableFooterView = UIView(frame: .zero)
        // セルのステータスを決定
        if cell.accessoryView == nil {
            
        }
        // セルに表示する値を設定する
        if indexPath.section == 0 {
            cell.textLabel!.text = createContent0[indexPath.row]
            return cell
        } else {
            return cell
        }
    }
    
    // 選択したセルの情報を取得
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルを取得する
        let cell = tableView.cellForRow(at:indexPath)
        // タップ後に灰色を消す
        tableView.deselectRow(at: indexPath, animated: true)
        // クリップボードにコピー
        if cell?.textLabel!.text != "" {
            UIPasteboard.general.string = cell?.textLabel!.text
            // 触覚フィードバック
            feedBack.notificationOccurred(.success)
            // タイマー停止ののちフェードアウト実行
            fadeOutTimer.invalidate()
            copyAlertLabel.alpha = 1.0
            // タップから0.5秒後に実行
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.fadeOutTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.fade_in), userInfo: nil, repeats: true)
            }
        }
    }
    
    // 0.05秒ごとに実行される関数
    @objc func fade_in() {
        copyAlertLabel.alpha -= 0.1
        // 透明度がなくなったらタイマーを止める
        if (copyAlertLabel.alpha <= 0.0) {
            fadeOutTimer.invalidate()
        }
    }
    
    // パスワード生成関数
    func passGenerate(length: Int) -> String {
        //0oO 1lI| gq9
        let data0 = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        let data1 = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
        let data2 = ["1","2","3","4","5","6","7","8","9","0"]
        let data3 = ["`","~","!","@","#","$","%","^","&","*","(",")","-","_","=","+","[","{","]","}","|",";",":","'",",","<",".",">","/","?"]
        var usedData: [String] = []
        var randomString = ""
        
        if userDefaults.object(forKey: "letterType0DataStore") as! Bool == true {
            usedData += data0
        }
        if userDefaults.object(forKey: "letterType1DataStore") as! Bool == true {
            usedData += data1
        }
        if userDefaults.object(forKey: "letterType2DataStore") as! Bool == true {
            usedData += data2
        }
        if userDefaults.object(forKey: "letterType3DataStore") as! Bool == true {
            usedData += data3
        }

        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(usedData.count))
            if randomString.count == 20 {
                randomString += "\n"
            }
            randomString += usedData[Int(randomValue)]
        }

        return randomString
    }
}

