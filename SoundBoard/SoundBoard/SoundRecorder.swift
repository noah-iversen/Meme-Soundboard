//
//  SoundRecorder.swift
//  SoundBoard
//
//  Created by Erik Iversen on 7/27/19.
//  Copyright © 2019 Noah Iversen. All rights reserved.
//

import UIKit
import AVFoundation

class SoundRecorder: NSObject, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var categoryStore: CategoryStore!
    var soundIndex = 0
    
    var soundCount: Int {
        var soundCounter = 1
        do {
            let soundDirectory = try FileManager.default.contentsOfDirectory(atPath: getDocumentsDirectory().path)
            for sound in soundDirectory {
                if sound.contains("Sound") {
                    soundCounter += 1
                }
            }
        } catch {
            print("Could not retrieve sound directory")
        }
        return soundCounter
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording()
        }
    }
    
    func startRecording() {
        let audioFileName = getDocumentsDirectory().appendingPathComponent("Sound\(soundCount).m4a")
        
        categoryStore.allCategories[0].sounds.append(Sound(resourceName: "Sound\(soundCount).m4a"))
                
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording() {
        audioRecorder.stop()
        audioRecorder = nil
    }
    
    func requestPermission() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission({ allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Permission granted to record sound")
                    } else {
                        print("Unable to record sound")
                    }
                }
            })
        } catch {
            print("Unable to record sound")
        }
    }
}
