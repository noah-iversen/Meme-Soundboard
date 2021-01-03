//
//  SoundDetailViewController.swift
//  SoundBoard
//
//  Created by Erik Iversen on 7/31/19.
//  Copyright © 2019 Noah Iversen. All rights reserved.
//

import UIKit

class SoundDetailViewController: UIViewController, UITextFieldDelegate {
    
    var sound: Sound!
    
    @IBOutlet var nameField: UITextField!
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nameFieldText = nameField.text ?? ""
        if nameFieldText != "" {
            let soundName = nameFieldText + ".m4a"
            let fileManager = FileManager.default
            let oldAudioFile = getDocumentsDirectory().appendingPathComponent(sound.resourceName).path
            let newAudioFile = getDocumentsDirectory().appendingPathComponent(soundName).path
            
            do {
                try fileManager.moveItem(atPath: oldAudioFile, toPath: newAudioFile)
                sound.resourceName = soundName
            } catch {
                print("Could not rename sound file \(oldAudioFile)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameField.text = getSoundName(withResource: sound.resourceName)
        nameField.becomeFirstResponder()
    }
    
    func getSoundName(withResource resource: String) -> String {
        let components = resource.components(separatedBy: ".")
        return components[0]
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
