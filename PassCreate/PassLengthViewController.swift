//
//  passLengthViewController.swift
//  Dobermann
//
//  Created by 丹羽雄一朗
//  Copyright © 2020 Niwa Yuichirou. All rights reserved.
//

import UIKit

//*1: これが原因でフリーズ(R3/12/8)
class PassLengthViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    let lengthStepper: UIStepper = UIStepper()

    let sectionTitle = [NSLocalizedString("簡易設定", comment: ""), NSLocalizedString("詳細設定", comment: "")]
    let section0Content = ["4","6","8","10","12","15","20","30","40"]
    let section1Content = [""]
    
    @IBOutlet weak var passLengthTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        passLengthTableView.delegate = self
        passLengthTableView.dataSource = self

        //dismissボタンを生成
        let dismissButton = UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: self,
            action: #selector(backToTop)
        )
        //dismissボタンを追加
        self.navigationItem.rightBarButtonItem = dismissButton

        navigationBar.title = NSLocalizedString("パスワードの文字数", comment: "")
    }

    @objc func backToTop() {
        dismiss(animated: true, completion: nil)
    }
}

extension PassLengthViewController: UITableViewDelegate, UITableViewDataSource {
    // セクション数を指定
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    // セクションタイトルを指定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section] as String
    }

    // セル数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return section0Content.count
        } else if section == 1 {
            return section1Content.count
        } else {
            return 0
        }
    }

    // セルを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを指定する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "passLength", for: indexPath)
        // データのないセルを非表示
        passLengthTableView.tableFooterView = UIView(frame: .zero)
        // セルのステータスを決定
        if cell.accessoryView == nil {
            if indexPath.section == 1 {
                if indexPath.row == 0 {
                    // セルの選択を不可にする
                    cell.selectionStyle = .none
                    // 最大値,最小値,初期値を設定
                    lengthStepper.maximumValue = 40
                    lengthStepper.minimumValue = 4
                    lengthStepper.value = Double(userDefaults.object(forKey: "passLengthDataStore") as! String)!
                    // stepperを設置
                    cell.accessoryView = lengthStepper
                }
            }
        }
        // チェックマーク描画
        if indexPath.section == 0 {
            let passLength = userDefaults.object(forKey: "passLengthDataStore") as! String
            if passLength == section0Content[indexPath.row] {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        // stepperタップで反応するメソッドを用意
        lengthStepper.addTarget(self, action: #selector(stepperDetector(_:)), for: UIControl.Event.touchUpInside)
        // セルの値を設定する
        if indexPath.section == 0 {
            cell.textLabel!.text = section0Content[indexPath.row]
            return cell
        } else if indexPath.section == 1 {
            cell.textLabel!.text = String(Int(lengthStepper.value))
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
        // すべてのチェックマークを消す
        for i in 0..<section0Content.count {
            let indexPath: NSIndexPath = NSIndexPath(row: i, section: indexPath.section)
            if let cell: UITableViewCell = tableView.cellForRow(at: indexPath as IndexPath) {
                cell.accessoryType = .none
            }
        }
        // タップで文字数設定
        if indexPath.section == 0 {
            for i in 4...section0Content.count+4 {
                if indexPath.row == i-4 {
                    // チェックマークを描画
                    cell?.accessoryType = .checkmark
                    lengthStepper.value = Double(Int(section0Content[i-4])!)
                    // 選択を保存
                    userDefaults.set(section0Content[i-4], forKey: "passLengthDataStore")
                    UserDefaults.standard.synchronize()
                }
            }
        }
        //passLengthTableView.reloadData()
        //*1
    }
    
    // stepperの操作で実行
    @objc func stepperDetector(_ sender: UIStepper) {
        userDefaults.set(String(Int(lengthStepper.value)), forKey: "passLengthDataStore")
        //passLengthTableView.reloadData()
        //*1
    }
}
