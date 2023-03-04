//
//  configPageViewController.swift
//  Dobermann
//
//  Created by 丹羽雄一朗
//  Copyright © 2020 Niwa Yuichirou. All rights reserved.
//

import UIKit

class ConfigPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let userDefaults = UserDefaults.standard
    
    let configTitle = [NSLocalizedString("一般", comment: ""),NSLocalizedString("このアプリについて", comment: "")]
    let configContent0 = [NSLocalizedString("パスワードの文字数", comment: ""),NSLocalizedString("使用する文字の設定", comment: "")]
    let configContent1 = [NSLocalizedString("バージョン", comment: "")]
    
    @IBOutlet weak var configTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var navigationBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title = NSLocalizedString("設定", comment: "")
        navigationBarButton.title = NSLocalizedString("完了", comment: "")
        
        configTableView.delegate = self
        configTableView.dataSource = self

    }
    
    // セクション数を指定
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
    }
    
    // セクションタイトルを指定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return configTitle[section] as String
        
    }
    
    // セル数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return configContent0.count
        } else if section == 1 {
            return configContent1.count
        } else {
            return 0
        }
        
    }
    
    // セルを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルを指定する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "config", for: indexPath)
        // データのないセルを非表示
        configTableView.tableFooterView = UIView(frame: .zero)
        // セルのステータスを決定
        if cell.accessoryView == nil {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    cell.detailTextLabel!.text = ""
                    //cell.detailTextLabel!.text = userDefaults.object(forKey: "passLengthDataStore") as? String
                    // >を追加
                    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                } else if indexPath.row == 1 {
                    cell.detailTextLabel!.text = ""
                    // >を追加
                    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                }
            } else if indexPath.section == 1 && indexPath.row == 0 {
                cell.detailTextLabel!.text = globalVersion
                // セルの選択を不可にする
                cell.selectionStyle = .none
            }
        }
        // セルに表示する値を設定する
        if indexPath.section == 0 {
            cell.textLabel!.text = configContent0[indexPath.row]
            return cell
        } else if indexPath.section == 1 {
            cell.textLabel!.text = configContent1[indexPath.row]
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
                let passLengthVC = self.storyboard?.instantiateViewController(identifier: "passLengthConfig")
                passLengthVC?.modalTransitionStyle = .coverVertical
                present(passLengthVC!, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                let letterTypeVC = self.storyboard?.instantiateViewController(identifier: "letterTypeConfig")
                letterTypeVC?.modalTransitionStyle = .coverVertical
                present(letterTypeVC!, animated: true, completion: nil)
            }
        }
        
    }
    
    // 画面遷移から戻ってきたときに実行する関数
    func updateTableView() {
        
    }
    
    // パスワード生成画面に戻る
    @IBAction func gotoCreatePage(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

protocol configPageViewControllerDelegate {
    
    func updateTableView()
    
}
