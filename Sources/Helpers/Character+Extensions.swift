//
//  NSCharacter+Extensions.swift
//  Pods
//
//  Created by yansong li on 2016-02-21.
//
//

import Foundation

/**
 Extension: Character
 */
public extension Character {
    /**
     Convert a Character to unicodeScalar value
     e.g turn 'a' to 97
     */
    func unicodeScalarCodePoint() -> Int {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return Int(scalars[scalars.startIndex].value)
    }
    
    /**
     Convert a Character to unicodeScalar value based on `0`
     e.g turn '0' to 0
     */
    func zeroCharacterBasedunicodeScalarCodePoint() -> Int {
        return self.unicodeScalarCodePoint() - 48
    }
}