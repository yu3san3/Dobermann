//
//  Password.swift
//  PassCreate
//
//  Created by 丹羽雄一朗 on 2023/06/22.
//  Copyright © 2023 Niwa Yuichirou. All rights reserved.
//

import Foundation

class Password {

    let userDefaults = UserDefaults.standard
    // パスワード生成関数
    func generate(length: Int) -> String {
        var result = ""
        let usedData = getUsedData()

        for _ in 0..<length {
            //20文字を超えたら改行する
            if result.count == 20 {
                result += "\n"
            }
            let randomStr = getRandomStr(usedData: usedData)
            result += randomStr
        }

        return result
    }

    private func getRandomStr(usedData: [String]) -> String {
        var randomStr: String
        //文字を除外するかどうかの設定
        let shouldExclude: Bool = userDefaults.bool(forKey: ExcludeCharacters.excludeCharacters.rawValue)

        repeat {
            let randomInt = Int.random(in: 0..<usedData.endIndex)
            randomStr = usedData[randomInt]
        } while excluded.contains(randomStr) && shouldExclude

        return randomStr
    }

    private func getUsedData() -> [String] {
        var usedData: [String] = []
        let letterType = userDefaults.dictionary(forKey: "letterType") as! [String: Bool]

        let upperCases = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        let lowerCases = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
        let numbers = ["1","2","3","4","5","6","7","8","9","0"]
        let symbols = ["`","~","!","@","#","$","%","^","&","*","(",")","-","_","=","+","[","{","]","}","|",";",":","'",",","<",".",">","/","?"]

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

        return usedData
    }
}
