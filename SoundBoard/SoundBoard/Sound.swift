//
//  Sound.swift
//  SoundBoard
//
//  Created by Erik Iversen on 7/16/19.
//  Copyright © 2019 Noah Iversen. All rights reserved.
//

import AVFoundation

class Sound {

    var originalResource: String
    var resourceName: String
    var isFavorite: Bool
    
    var soundEffect: String
    
    var soundEffects = [""]

    init(resourceName: String, isFavorite: Bool = false, soundEffect: String = "") {
        self.resourceName = resourceName
        self.isFavorite = isFavorite
        self.soundEffect = soundEffect
        
        self.originalResource = resourceName
        
        if resourceName.contains("-") {
            let components = resourceName.components(separatedBy: "-")
            let fileManager = FileManager.default
            let path = Bundle.main.resourcePath!
            let soundItems = try! fileManager.contentsOfDirectory(atPath: path)
            
            for sound in soundItems {
                if sound.contains("-") {
                    let soundComponents = sound.components(separatedBy: "-")
                    if soundComponents.count > 2 {
                        if sound.hasPrefix(components[0] + "-" + components[1].components(separatedBy: ".")[0]) {
                            let soundEffectName = soundComponents[2].components(separatedBy: ".")[0]
                            soundEffects.append(soundEffectName)
                        }
                    }
                }
            }
        }
    }
}

