//
//  LetterTypeViewController.swift
//  Dobermann
//
//  Created by 丹羽雄一朗
//  Copyright © 2020 Niwa Yuichirou. All rights reserved.
//

import UIKit

class LetterTypeViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    let letterTypeCellId = "letterTypeTableViewCell"
    
    let sectionTitle = [""]
    let section0Content = [
        NSLocalizedString("A-Z 英字(大文字)", comment: ""),
        NSLocalizedString("a-z 英字(小文字)", comment: ""),
        NSLocalizedString("1-9 数字", comment: ""),
        NSLocalizedString("@ 記号", comment: "")
    ]

    @IBOutlet weak var letterTypeTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    var dismissButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        letterTypeTableView.delegate = self
        letterTypeTableView.dataSource = self

        dismissButton = UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: self,
            action: #selector(backToTop)
        )
        self.navigationItem.rightBarButtonItem = dismissButton

        navigationBar.title = NSLocalizedString("使用する文字の設定", comment: "")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let letterType = userDefaults.dictionary(forKey: "letterType") as! [String: Bool]
        if letterType["upperCase"] == false &&
            letterType["lowerCase"] == false &&
            letterType["number"] == false &&
            letterType["symbol"] == false {
            // ダイアログ
            let dialog = UIAlertController(
                title: NSLocalizedString("パスワードを生成できません", comment: ""),
                message: NSLocalizedString("パスワードに使用する文字を最低ひとつ\n選んでください。", comment: ""),
                preferredStyle: .alert
            )
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog, animated: true, completion: nil)
            return
        }
    }

    @objc func backToTop() {
        dismiss(animated: true, completion: nil)
    }
}

extension LetterTypeViewController: UITableViewDelegate, UITableViewDataSource {
    
    // セクション数を指定
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // セクションタイトルを指定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section] as String
    }
    
    // セル数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return section0Content.count
        } else {
            return 0
        }
    }
    
    // セルを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを指定する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: letterTypeCellId, for: indexPath)
        // データのないセルを非表示
        letterTypeTableView.tableFooterView = UIView(frame: .zero)
        let letterType = userDefaults.dictionary(forKey: LetterType.letterType.rawValue) as! [String: Bool]
        // チェックマーク描画
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                if letterType[LetterType.upperCase.rawValue] == true {
                    cell.accessoryType = .checkmark
                }
            case 1:
                if letterType[LetterType.lowerCase.rawValue] == true {
                    cell.accessoryType = .checkmark
                }
            case 2:
                if letterType[LetterType.number.rawValue] == true {
                    cell.accessoryType = .checkmark
                }
            case 3:
                if letterType[LetterType.symbol.rawValue] == true {
                    cell.accessoryType = .checkmark
                }
            default:
                return cell
            }
        }
        // セルの値を設定する
        if indexPath.section == 0 {
            cell.textLabel!.text = section0Content[indexPath.row]
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
        let letterType = userDefaults.dictionary(forKey: LetterType.letterType.rawValue) as! [String: Bool]
        var letterTypeToSave: [String: Bool] = letterType
        // タップで文字数設定
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                letterTypeToSave[LetterType.upperCase.rawValue]?.toggle()
                toggleAccessoryType(letterType: letterType[LetterType.upperCase.rawValue]!)
            case 1:
                letterTypeToSave[LetterType.lowerCase.rawValue]?.toggle()
                toggleAccessoryType(letterType: letterType[LetterType.lowerCase.rawValue]!)
            case 2:
                letterTypeToSave[LetterType.number.rawValue]?.toggle()
                toggleAccessoryType(letterType: letterType[LetterType.number.rawValue]!)
            case 3:
                letterTypeToSave[LetterType.symbol.rawValue]?.toggle()
                toggleAccessoryType(letterType: letterType[LetterType.symbol.rawValue]!)
            default:
                return
            }
        }
        userDefaults.set(letterTypeToSave, forKey: LetterType.letterType.rawValue)
        return

        func toggleAccessoryType(letterType: Bool) {
            if letterType == false {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
        }
    }
}
