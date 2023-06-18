//
//  configPageViewController.swift
//  Dobermann
//
//  Created by 丹羽雄一朗
//  Copyright © 2020 Niwa Yuichirou. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    let configCellId = "configTableViewCell"
    
    let sectionTitle = [
        NSLocalizedString("一般", comment: ""),
        NSLocalizedString("このアプリについて", comment: "")
    ]
    let section0Content = [
        NSLocalizedString("パスワードの文字数", comment: ""),
        NSLocalizedString("使用する文字の設定", comment: ""),
        NSLocalizedString("読みにくい文字を除外する", comment: "")
    ]
    let section1Content = [NSLocalizedString("バージョン", comment: "")]
    
    @IBOutlet var configTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    let excludeConfusingCharactersSwitch = UISwitch(frame: .zero)
    var dismissButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        configTableView.delegate = self
        configTableView.dataSource = self

        setupView()
    }

    private func setupView() {
        navigationBar.title = NSLocalizedString("設定", comment: "")

        excludeConfusingCharactersSwitch.setOn(
            userDefaults.bool(forKey: ExcludeCharacters.excludeCharacters.rawValue),
            animated: true
        )
        excludeConfusingCharactersSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)

        //dismissボタンを生成
        dismissButton = UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: self,
            action: #selector(backToTop)
        )
        //dismissボタンを追加
        self.navigationItem.rightBarButtonItem = dismissButton
    }

    //スイッチのコールバックメソッド
    @objc func switchChanged(_ sender : UISwitch!) {
        if sender.isOn {
            userDefaults.set(true, forKey: ExcludeCharacters.excludeCharacters.rawValue)
        } else {
            userDefaults.set(false, forKey: ExcludeCharacters.excludeCharacters.rawValue)
        }
    }

    @objc func backToTop() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ConfigViewController: UITableViewDelegate, UITableViewDataSource {
    
    // セクション数を指定
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // セクションタイトルを指定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section] as String
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var footerTitle: String = ""
        if section == 0 {
            footerTitle = "読みにくい記号(0,o,O,1,l,I,|,g,q,9など)を除外します。"
        }
        return footerTitle
    }
    
    // セル数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return section0Content.count
        case 1:
            return section1Content.count
        default:
            return 0
        }
    }
    
    // セルを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを指定する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: configCellId, for: indexPath)
        let passLength = userDefaults.integer(forKey: PassLength.passLength.rawValue)
        // データのないセルを非表示
        configTableView.tableFooterView = UIView(frame: .zero)
        // セルのステータスを決定
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = section0Content[indexPath.row]
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = String(passLength)
                // >を追加
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            case 1:
                cell.detailTextLabel?.text = ""
                // >を追加
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            case 2:
                cell.detailTextLabel?.text = ""
                excludeConfusingCharactersSwitch.tag = indexPath.row //どの行のスイッチが変更されたかを検出する
                cell.accessoryView = excludeConfusingCharactersSwitch
            default:
                break
            }
        case 1:
            cell.textLabel!.text = section1Content[indexPath.row]
            cell.detailTextLabel?.text = appVersion
            // セルの選択を不可にする
            cell.selectionStyle = .none
        default:
            break
        }
        return cell
    }
    
    // 選択したセルの情報を取得
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップ後に灰色を消す
        tableView.deselectRow(at: indexPath, animated: true)
        // タップしたセルごとに処理を分岐
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let passLengthViewController = self.storyboard?.instantiateViewController(withIdentifier: "passLengthView") as! PassLengthViewController
                self.navigationController?.pushViewController(passLengthViewController, animated: true)
            case 1:
                let letterTypeViewController = self.storyboard?.instantiateViewController(withIdentifier: "letterTypeView") as! LetterTypeViewController
                self.navigationController?.pushViewController(letterTypeViewController, animated: true)
            default:
                return
            }
        }
    }
}
