//
//  CategoryViewController.swift
//  SoundBoard
//
//  Created by Erik Iversen on 7/16/19.
//  Copyright © 2019 Noah Iversen. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class CategoryViewController: UIViewController, GADBannerViewDelegate {
    
    var categoryStore: CategoryStore!
    
    var soundRecorder: SoundRecorder!
    
    @IBOutlet var categoryButtons: [UIButton]!
    
    @IBOutlet var previousPageButton: UIButton!
    @IBOutlet var nextPageButton: UIButton!
    
    var categoryPageIndex = 0
    
    @IBOutlet var bannerView: GADBannerView!
    
    @IBAction func choosePreviousPage(_ sender: UIButton) {
        categoryPageIndex -= 1
        if categoryPageIndex > 0 {
            loadNextPage()
        } else {
            loadFirstPage()
            sender.isHidden = true
        }
        nextPageButton.isHidden = false
    }
    
    @IBAction func chooseNextPage(_ sender: UIButton) {
        categoryPageIndex += 1
        loadNextPage()
        previousPageButton.isHidden = false
    }
    
    @IBAction func chooseCategory(_ sender: UIButton) {
        for categories in categoryStore.allCategories.indices {
            if sender.titleLabel?.text! == categoryStore.allCategories[categories].name {
                loadSoundViewController(categoryIndex: categories)
            }
        }
    }
    
    
    @IBAction func playRandomSound(_ sender: UIButton) {
        if categoryStore.allCategories.count > 0 {
            let randomCategory = categoryStore.allCategories[(categoryStore.allCategories.count - 1).arc4random]
            let randomSound = randomCategory.sounds[(randomCategory.sounds.count - 1).arc4random]
            randomCategory.name != "My Sounds" ? SoundPlayer.sharedInstance.playSoundEffect(withResourceName: randomSound.resourceName) : SoundPlayer.sharedInstance.playUserSound(withResourceName: randomSound.resourceName)
        }
    }
    
    @IBAction func cancelSound(_ sender: UIButton) {
        for sound in SoundPlayer.sharedInstance.players {
            sound.stop()
        }
        SoundPlayer.sharedInstance.players.removeAll()
    }
    
    @IBAction func pressRecordButton(_ sender: UIButton) {
        soundRecorder.startRecording()
    }
    
    @IBAction func releaseRecordButton(_ sender: UIButton) {
        soundRecorder.finishRecording()
        loadSoundViewController(categoryIndex: 0)
    }
    
    @IBAction func releaseRecordButtonOutside(_ sender: Any) {
        soundRecorder.finishRecording()
        loadSoundViewController(categoryIndex: 0)
    }
    
    
    func loadFirstPage() {
        for index in categoryStore.allCategories.indices {
            if index < categoryButtons.count {
                categoryButtons[index].titleLabel?.minimumScaleFactor = 0.5
                categoryButtons[index].titleLabel?.numberOfLines = 0
                categoryButtons[index].titleLabel?.adjustsFontSizeToFitWidth = true
                categoryButtons[index].setTitle("", for: .normal)
                categoryButtons[index].setTitle(categoryStore.allCategories[index].name, for: .normal)
                categoryButtons[index].isEnabled = true
                categoryButtons[index].setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            } else {
                nextPageButton.isHidden = false
                break
            }
        }
    }
    
    func loadNextPage() {
        for index in categoryButtons.indices {
            categoryButtons[index].setTitle("", for: .normal)
            categoryButtons[index].isEnabled = false
            let categoryIndex = index + ((categoryButtons.count) * categoryPageIndex)
            if categoryIndex < categoryStore.allCategories.count {
                categoryButtons[index].setTitle(categoryStore.allCategories[categoryIndex].name, for: .normal)
                categoryButtons[index].isEnabled = true
            } else {
                nextPageButton.isHidden = true
            }
        }
    }
    
    func loadSoundViewController(categoryIndex index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let soundViewController = storyboard.instantiateViewController(withIdentifier: "SoundViewController") as! SoundViewController
        soundViewController.categoryStore = categoryStore
        soundViewController.category = categoryStore.allCategories[index]
        soundViewController.soundRecorder = soundRecorder
        self.navigationController?.pushViewController(soundViewController, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFirstPage()
        soundRecorder.requestPermission()
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())

        bannerView.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Category"
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

