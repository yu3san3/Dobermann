//
//  ConfigStrings.swift
//  PassCreate
//
//  Created by 丹羽雄一朗 on 2023/06/19.
//  Copyright © 2023 Niwa Yuichirou. All rights reserved.
//

import Foundation

enum PassLength: String {
    case passLength = "passLength"
}

enum LetterType: String {
    case letterType = "letterType"

    case upperCase = "upperCase"
    case lowerCase = "lowerCase"
    case number = "number"
    case symbol = "symbol"
}

enum ExcludeCharacters: String {
    case excludeCharacters = "excludeCharacters"
}
