//
//  SoundPlayer.swift
//  SoundBoard
//
//  Created by Erik Iversen on 8/9/19.
//  Copyright © 2019 Noah Iversen. All rights reserved.
//

import UIKit
import AVFoundation

class SoundPlayer: NSObject, AVAudioPlayerDelegate {
    
    static let sharedInstance = SoundPlayer()
    
    private override init() { }
    
    var players = [AVAudioPlayer]()
    
    func playSoundEffect(withResourceName resourceName: String) {
        let path = Bundle.main.path(forResource: resourceName, ofType: nil)!
        let url = URL(fileURLWithPath: path)
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            players.append(player)
            player.prepareToPlay()
            player.play()
        } catch {
            print("Could not play sound \(resourceName)")
        }
    }
    
    func playUserSound(withResourceName resourceName: String) {
        do {
            let player = try AVAudioPlayer(contentsOf: getDocumentsDirectory().appendingPathComponent(resourceName))
            player.delegate = self
            players.append(player)
            player.prepareToPlay()
            player.play()
        } catch {
            print("Could not retrieve sound directory")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        players.remove(at: players.firstIndex(of: player)!)
    }
}
