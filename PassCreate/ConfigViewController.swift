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
    
    let sectionTitle = [NSLocalizedString("一般", comment: ""), NSLocalizedString("このアプリについて", comment: "")]
    let section0Content = [NSLocalizedString("パスワードの文字数", comment: ""), NSLocalizedString("使用する文字の設定", comment: "")]
    let section1Content = [NSLocalizedString("バージョン", comment: "")]
    
    @IBOutlet var configTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    var dismissButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        configTableView.delegate = self
        configTableView.dataSource = self

        //dismissボタンを生成
        dismissButton = UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: self,
            action: #selector(backToTop)
        )
        //dismissボタンを追加
        self.navigationItem.rightBarButtonItem = dismissButton

        navigationBar.title = NSLocalizedString("設定", comment: "")
    }

    @objc func backToTop() {
        dismiss(animated: true, completion: nil)
    }
}

extension ConfigViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: configCellId, for: indexPath)
        // データのないセルを非表示
        configTableView.tableFooterView = UIView(frame: .zero)
        // セルのステータスを決定
        if cell.accessoryView == nil {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    cell.detailTextLabel?.text = ""
//                    cell.detailTextLabel!.text = userDefaults.object(forKey: "passLengthDataStore") as? String
                    // >を追加
                    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                } else if indexPath.row == 1 {
                    cell.detailTextLabel?.text = ""
                    // >を追加
                    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                }
            } else if indexPath.section == 1 && indexPath.row == 0 {
                cell.detailTextLabel?.text = appVersion
                // セルの選択を不可にする
                cell.selectionStyle = .none
            }
        }
        // セルに表示する値を設定する
        if indexPath.section == 0 {
            cell.textLabel!.text = section0Content[indexPath.row]
            return cell
        } else if indexPath.section == 1 {
            cell.textLabel!.text = section1Content[indexPath.row]
            return cell
        } else {
            return cell
        }
    }
    
    // 選択したセルの情報を取得
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップ後に灰色を消す
        tableView.deselectRow(at: indexPath, animated: true)
        // タップしたセルごとに処理を分岐
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let passLengthViewController = self.storyboard?.instantiateViewController(withIdentifier: "passLengthView") as! PassLengthViewController
                self.navigationController?.pushViewController(passLengthViewController, animated: true)
            } else if indexPath.row == 1 {
                let letterTypeViewController = self.storyboard?.instantiateViewController(withIdentifier: "letterTypeView") as! LetterTypeViewController
                self.navigationController?.pushViewController(letterTypeViewController, animated: true)
            }
        }
    }
}
