//
//  CategoryStore.swift
//  SoundBoard
//
//  Created by Erik Iversen on 7/16/19.
//  Copyright © 2019 Noah Iversen. All rights reserved.
//

import UIKit

class CategoryStore {
    
    var allCategories = [Category]()
    
    init() {
        allCategories.append(Category(name: "My Sounds"))
        allCategories.append(Category(name: "Favorites"))
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!
        let soundItems = try! fileManager.contentsOfDirectory(atPath: path)

        for sound in soundItems {
            if sound.hasSuffix(".mp3") {
                let categoryName = sound.components(separatedBy: "-")
                if categoryName.count < 3 {
                    if !isCategory(name: categoryName[0].capitalizingFirstLetter()) {
                        allCategories.append(Category(name: categoryName[0].capitalizingFirstLetter()))
                    }
                }
            }
        }
    }
    
    func isCategory(name: String) -> Bool {
        for category in allCategories {
            if name == category.name {
                return true
            }
        }
        return false
    }
}
