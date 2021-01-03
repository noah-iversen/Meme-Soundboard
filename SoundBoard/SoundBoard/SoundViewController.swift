//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Erik Iversen on 7/17/19.
//  Copyright © 2019 Noah Iversen. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class SoundViewController: UIViewController, UINavigationControllerDelegate, GADBannerViewDelegate {
    
    var category: Category! {
        didSet {
            navigationItem.title = category.name
        }
    }
    
    var categoryStore: CategoryStore!
    
    
    @IBOutlet var bannerView: GADBannerView!
    
    @IBOutlet var soundButtons: [UIButton]!
    
    @IBOutlet var previousPageButton: UIButton!
    @IBOutlet var nextPageButton: UIButton!
    
    @IBOutlet var recordButton: UIButton!
    
    var soundRecorder: SoundRecorder!
    
    var soundPageIndex = 0
    
    @IBAction func choosePreviousPage(_ sender: UIButton) {
        soundPageIndex -= 1
        if soundPageIndex > 0 {
            loadNextPage()
        } else {
            loadFirstPage()
            sender.isHidden = true
        }
        nextPageButton.isHidden = false
    }
    
    @IBAction func chooseNextPage(_ sender: UIButton) {
        soundPageIndex += 1
        loadNextPage()
        previousPageButton.isHidden = false
    }
    
    @IBAction func playSound(_ sender: UIButton) {
        for index in category.sounds.indices {
            let resourceName = category.sounds[index].resourceName
            let buttonName = sender.titleLabel?.text ?? ""
            let soundName = getSoundName(withResource: resourceName)
            if soundName.capitalizingFirstLetter() == buttonName {
                category.name != "My Sounds" ? SoundPlayer.sharedInstance.playSoundEffect(withResourceName: resourceName) : SoundPlayer.sharedInstance.playUserSound(withResourceName: resourceName)
            }
        }
    }

    @IBAction func pressRecordButton(_ sender: UIButton) {
        soundRecorder.startRecording()
    }
    
    
    @IBAction func releaseRecordButton(_ sender: UIButton) {
        soundRecorder.finishRecording()
        category = categoryStore.allCategories[0]
        loadNextPage()
        loadButtonGestures()
    }
    
    
    @IBAction func releaseRecordButtonOutside(_ sender: UIButton) {
        soundRecorder.finishRecording()
        category = categoryStore.allCategories[0]
        loadNextPage()
        loadButtonGestures()
    }
    
    @IBAction func playRandomSound(_ sender: UIButton) {
        if category.sounds.count > 0 {
            let randomSound = category.sounds[(category.sounds.count - 1).arc4random]
            category.name != "My Sounds" ? SoundPlayer.sharedInstance.playSoundEffect(withResourceName: randomSound.resourceName) : SoundPlayer.sharedInstance.playUserSound(withResourceName: randomSound.resourceName)
        }
    }
    
    @IBAction func cancelSound(_ sender: UIButton) {
        for sound in SoundPlayer.sharedInstance.players {
            sound.stop()
        }
        SoundPlayer.sharedInstance.players.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFirstPage()
        loadButtonGestures()
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        bannerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFirstPage()
        self.title = category.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }
    
    @objc func loadAlertController(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
    
            let title = "Sound Options"
            
            let ac = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let button = sender.view as! UIButton
            
            var soundIndex = 0
            
            for index in category.sounds.indices {
                let resourceName = category.sounds[index].resourceName
                let buttonName = button.titleLabel?.text ?? ""
                let soundName = getSoundName(withResource: resourceName)
                if soundName.capitalizingFirstLetter() == buttonName {
                    soundIndex = index
                }
            }
            
            let sound = self.category.sounds[soundIndex]
            
            if category.name == "My Sounds" {
                
                
                let renameAction = UIAlertAction(title: "Rename", style: .default, handler: { (action) -> Void in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let soundDetailViewController = storyboard.instantiateViewController(withIdentifier: "SoundDetailViewController") as! SoundDetailViewController
                    soundDetailViewController.sound = sound
                    self.navigationController?.pushViewController(soundDetailViewController, animated: true)
                })
                
                ac.addAction(renameAction)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                    do {
                        try FileManager.default.removeItem(at: self.soundRecorder.getDocumentsDirectory().appendingPathComponent(sound.resourceName))
                    } catch {
                        print("Could not remove file \(sound.resourceName)")
                    }
                    self.category.sounds.remove(at: soundIndex)
                    button.gestureRecognizers = nil
                    self.loadNextPage()
                    self.loadButtonGestures()
                })
                
                ac.addAction(deleteAction)
                
            } else {
                
                // Handles favoriting sound
                
                let favCategory = self.categoryStore.allCategories[1]
                if sound.isFavorite {
                    let deleteFavorite = UIAlertAction(title: "Remove From Favorites", style: .destructive, handler: { (action) -> Void in
                        sound.isFavorite = false
                        let favSoundIndex = favCategory.sounds.firstIndex(where: { $0.resourceName == sound.resourceName })!
                        favCategory.sounds.remove(at: favSoundIndex)
                        self.loadNextPage()
                        self.loadButtonGestures()
                        do {
                            try FileManager.default.removeItem(at: self.soundRecorder.getDocumentsDirectory().appendingPathComponent("Favorites").appendingPathComponent(sound.resourceName))
                        } catch {
                            print("Could not remove file \(sound.resourceName)")
                        }
                    })
                    
                    ac.addAction(deleteFavorite)
                } else {
                    let addFavorite = UIAlertAction(title: "Add To Favorites", style: .default, handler: { (action) -> Void in
                        sound.isFavorite = true
                        favCategory.sounds.append(sound)
                        do {
                    
                            if !FileManager.default.fileExists(atPath: self.soundRecorder.getDocumentsDirectory().appendingPathComponent("Favorites").path) {
                                try FileManager.default.createDirectory(atPath: self.soundRecorder.getDocumentsDirectory().appendingPathComponent("Favorites").path, withIntermediateDirectories: true, attributes: nil)
                            }
                            let soundFile = Bundle.main.path(forResource: sound.resourceName, ofType: nil)!
                            let favSoundFile = self.soundRecorder.getDocumentsDirectory().appendingPathComponent("Favorites").appendingPathComponent(sound.resourceName).path
                        
                        
                            try FileManager.default.copyItem(atPath: soundFile, toPath: favSoundFile)
                        } catch {
                            print("Could not add file \(sound.resourceName)")
                        }
                    })
                    ac.addAction(addFavorite)
                }
                
                // Handles switching sound effect
                
                if sound.soundEffects != [""] {
                    for effect in sound.soundEffects {
                        if effect != sound.soundEffect && effect != "" {
                            let chooseEffect = UIAlertAction(title: "Choose " + effect.capitalizingFirstLetter() + " Sound Effect", style: .default, handler: { (action) -> Void in
                                sound.soundEffect = effect
                                sound.resourceName = sound.originalResource.components(separatedBy: ".")[0] + "-" + effect + ".mp3"
                            })
                            ac.addAction(chooseEffect)
                        }
                    }
                    
                    if sound.soundEffect != "" {
                        let removeEffect = UIAlertAction(title: "Remove Sound Effect", style: .destructive, handler: { (action) -> Void in
                            sound.soundEffect = ""
                            sound.resourceName = sound.originalResource
                        })
                        ac.addAction(removeEffect)
                    }
                }
                
            }

            present(ac, animated: true, completion: nil)
        }
    }
    
    func getSoundName(withResource resource: String) -> String {
        var components = [""]
        var soundName = [""]
        if resource.contains("-") {
            components = resource.components(separatedBy: "-")
            soundName = components[1].components(separatedBy: ".")
            return soundName[0]
        } else {
            soundName = resource.components(separatedBy: ".")
            return soundName[0]
        }
    }
    
    func loadFirstPage() {
        for index in category.sounds.indices {
            if index < soundButtons.count {
                soundButtons[index].titleLabel?.minimumScaleFactor = 0.5
                soundButtons[index].titleLabel?.numberOfLines = 0
                soundButtons[index].titleLabel?.adjustsFontSizeToFitWidth = true
                soundButtons[index].setTitle("", for: .normal)
                soundButtons[index].setTitle(getSoundName(withResource: category.sounds[index].resourceName).capitalizingFirstLetter(), for: .normal)
                soundButtons[index].isEnabled = true
                soundButtons[index].setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            } else {
                nextPageButton.isHidden = false
                break
            }
        }
    }
    
    func loadNextPage() {
        nextPageButton.isHidden = false
        for index in soundButtons.indices {
            soundButtons[index].setTitle("", for: .normal)
            soundButtons[index].isEnabled = false
            let soundIndex = index + ((soundButtons.count) * soundPageIndex)
            if soundIndex < category.sounds.count {
                soundButtons[index].setTitle(getSoundName(withResource: category.sounds[soundIndex].resourceName).capitalizingFirstLetter(), for: .normal)
                soundButtons[index].isEnabled = true
                soundButtons[index].setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            } else {
                nextPageButton.isHidden = true
            }
        }
    }
    
    func loadButtonGestures() {
        for index in soundButtons.indices {
            if index < category.sounds.count {
                if soundButtons[index].gestureRecognizers == nil {
                    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(loadAlertController(_:)))
                    soundButtons[index].addGestureRecognizer(longGesture)
                }
            }
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
