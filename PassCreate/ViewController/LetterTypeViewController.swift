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

        setupView()
    }

    private func setupView() {
        navigationBar.title = NSLocalizedString("使用する文字の設定", comment: "")

        dismissButton = UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: self,
            action: #selector(backToTop)
        )
        self.navigationItem.rightBarButtonItem = dismissButton
    }

    @objc func backToTop() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
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
        switch section {
        case 0:
            return section0Content.count
        default:
            return 0
        }
    }
    
    // セルを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを指定する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: letterTypeCellId, for: indexPath)
        let letterType = userDefaults.dictionary(forKey: LetterType.letterType.rawValue) as! [String: Bool]
        // データのないセルを非表示
        letterTypeTableView.tableFooterView = UIView(frame: .zero)
        // チェックマーク描画
        if indexPath.section == 0 {
            cell.textLabel!.text = section0Content[indexPath.row]
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
                break
            }
        }
        return cell
    }
    
    // 選択したセルの情報を取得
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルを取得する
        let cell = tableView.cellForRow(at:indexPath)
        let letterType = userDefaults.dictionary(forKey: LetterType.letterType.rawValue) as! [String: Bool]
        var letterTypeToSave: [String: Bool] = letterType
        // タップ後に灰色を消す
        tableView.deselectRow(at: indexPath, animated: true)
        // タップで文字数設定
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                letterTypeToSave[LetterType.upperCase.rawValue]?.toggle()
                drawCheckMark(letterType: letterType[LetterType.upperCase.rawValue]!)
            case 1:
                letterTypeToSave[LetterType.lowerCase.rawValue]?.toggle()
                drawCheckMark(letterType: letterType[LetterType.lowerCase.rawValue]!)
            case 2:
                letterTypeToSave[LetterType.number.rawValue]?.toggle()
                drawCheckMark(letterType: letterType[LetterType.number.rawValue]!)
            case 3:
                letterTypeToSave[LetterType.symbol.rawValue]?.toggle()
                drawCheckMark(letterType: letterType[LetterType.symbol.rawValue]!)
            default:
                return
            }
        default:
            break
        }
        //少なくとも1つの文字が選択されているかをチェック
        if isNothingSelected(letterType: letterTypeToSave) {
            showErrorDialog()
            letterTypeTableView.reloadData()
            return
        }
        //保存
        userDefaults.set(letterTypeToSave, forKey: LetterType.letterType.rawValue)
        return

        func drawCheckMark(letterType: Bool) {
            if letterType == false {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
        }

        func isNothingSelected(letterType: [String: Bool]) -> Bool {
            if letterType[LetterType.upperCase.rawValue] == false &&
                letterType[LetterType.lowerCase.rawValue] == false &&
                letterType[LetterType.number.rawValue] == false &&
                letterType[LetterType.symbol.rawValue] == false {
                return true
            } else {
                return false
            }

        }

        func showErrorDialog() {
            let dialog = UIAlertController(
                title: NSLocalizedString("パスワードを生成できません", comment: ""),
                message: NSLocalizedString("パスワードに使用する文字を最低ひとつ\n選んでください。", comment: ""),
                preferredStyle: .alert
            )
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog, animated: true, completion: nil)
        }
    }
}
