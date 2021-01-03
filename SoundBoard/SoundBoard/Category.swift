//
//  Category.swift
//  SoundBoard
//
//  Created by Erik Iversen on 7/16/19.
//  Copyright © 2019 Noah Iversen. All rights reserved.
//

import UIKit

class Category {
    
    var name: String
    var sounds = [Sound]()
    
    init(name: String) {
        self.name = name
        
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!
        let soundItems = try! fileManager.contentsOfDirectory(atPath: path)
        
        switch(name) {
        case "My Sounds":
            do {
                let soundDirectory = try fileManager.contentsOfDirectory(atPath: getDocumentsDirectory().path)
                for sound in soundDirectory {
                    if sound.hasSuffix("m4a") {
                        sounds.append(Sound(resourceName: sound))
                    }
                }
            } catch {
                print("Error loading user sounds")
            }
        case "Favorites":
            do {
                let soundDirectory = try fileManager.contentsOfDirectory(atPath: getDocumentsDirectory().appendingPathComponent("Favorites").path)
                for sound in soundDirectory {
                    let sound = Sound(resourceName: sound)
                    sound.isFavorite = true
                    sounds.append(sound)
                }
            } catch {
                print("Error loading user sounds")
            }
        default:
            for sound in soundItems {
                if sound.hasPrefix(name.lowercased()) {
                    if sound.components(separatedBy: "-").count < 3 {
                        sounds.append(Sound(resourceName: sound))
                    }
                }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
