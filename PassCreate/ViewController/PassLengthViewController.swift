//
//  passLengthViewController.swift
//  Dobermann
//
//  Created by 丹羽雄一朗
//  Copyright © 2020 Niwa Yuichirou. All rights reserved.
//

import UIKit

class PassLengthViewController: UIViewController {
    
    private let userDefaults = UserDefaults.standard
    private let passLengthCellId = "passLengthTableViewCell"

    private let passLengthKey: String = PassLength.passLength.rawValue

    private let sectionTitle = [NSLocalizedString("簡易設定", comment: ""), NSLocalizedString("詳細設定", comment: "")]
    private let section0Content = [4, 6, 8, 10, 12, 15, 20, 30, 40]
    private let section1Content = [""]
    
    @IBOutlet weak var passLengthTableView: UITableView!
    let lengthStepper = UIStepper()
    @IBOutlet weak var navigationBar: UINavigationItem!
    var dismissButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        passLengthTableView.delegate = self
        passLengthTableView.dataSource = self

        setupView()
    }

    private func setupView() {
        navigationBar.title = NSLocalizedString("パスワードの文字数", comment: "")

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
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: passLengthCellId, for: indexPath)
        let storedPassLength = userDefaults.integer(forKey: passLengthKey)
        // データのないセルを非表示
        passLengthTableView.tableFooterView = UIView(frame: .zero)
        // セルのステータスを決定
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = String(section0Content[indexPath.row])
            cell.accessoryType = getAccessoryType(shouldDraw: section0Content[indexPath.row] == storedPassLength)
        case 1:
            cell.textLabel!.text = String(storedPassLength)
            cell.selectionStyle = .none // セルの選択を不可に
            setupLengthStepper(initialStepperValue: storedPassLength)
            cell.accessoryView = lengthStepper // stepperを設置
        default:
            break
        }
        return cell

        func setupLengthStepper(initialStepperValue: Int) {
            lengthStepper.maximumValue = 40
            lengthStepper.minimumValue = 4
            lengthStepper.value = Double(initialStepperValue)
            // stepperタップで反応するメソッドを指定
            lengthStepper.addTarget(
                self,
                action: #selector(stepperDetector(_:)),
                for: UIControl.Event.touchUpInside
            )
        }
    }

    // stepperの操作で実行
    @objc func stepperDetector(_ sender: UIStepper) {
        let newPassLength = Int(lengthStepper.value)
        userDefaults.set(newPassLength, forKey: passLengthKey)
        updateView()
    }

    // 選択したセルの情報を取得
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルを取得する
        let cell = tableView.cellForRow(at: indexPath)
        // タップ後に灰色を消す
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let newPassLength = section0Content[indexPath.row]
            lengthStepper.value = Double(newPassLength)
            // 選択を保存
            userDefaults.set(newPassLength, forKey: passLengthKey)
            updateView()
        default:
            break
        }
    }

    private func updateView() {
        let newPassLength = userDefaults.integer(forKey: passLengthKey)
        updateCheckmark()
        updateStepperCellText()
        return

        func updateCheckmark() {
            for i in 0..<section0Content.endIndex {
                let indexPath = IndexPath(row: i, section: 0)
                if let cell = passLengthTableView.cellForRow(at: indexPath) {
                    cell.accessoryType = getAccessoryType(shouldDraw: section0Content[indexPath.row] == newPassLength)
                }
            }
        }

        func updateStepperCellText() {
            let indexPath = IndexPath(row: 0, section: 1)
            if let cell = passLengthTableView.cellForRow(at: indexPath) {
                cell.textLabel?.text = String(newPassLength)
            }
        }
    }

    private func getAccessoryType(shouldDraw: Bool) -> UITableViewCell.AccessoryType {
        if shouldDraw {
            return .checkmark
        } else {
            return .none
        }
    }
}
