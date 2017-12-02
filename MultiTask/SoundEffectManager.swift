//
//  SoundEffectManager.swift
//  MultiTask
//
//  Created by rightmeow on 11/29/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import AVFoundation

protocol SoundEffectDelegate: NSObjectProtocol {
    func soundEffect(_ manager: SoundEffectManager, didErr error: Error)
    func soundEffect(_ manager: SoundEffectManager, didPlaySoundEffect soundEffect: SoundEffect, player: AVAudioPlayer)
}

enum SoundEffect: String {
    case Bing
    case Tap
    case Click
    case Coin
    case Notification
}

/**
 SoundEffectManager handles and play custom sound assets in protocol orientated way.
 - remark: To use this class, make sure to set its delegate and conform to the SoundEffectDelegate methods.
 */
class SoundEffectManager: NSObject {

    weak var delegate: SoundEffectDelegate?
    var player: AVAudioPlayer?

    func play(soundEffect: SoundEffect) {
        if let url = Bundle.main.url(forResource: soundEffect.rawValue, withExtension: "wav") {
            do {
                let sound = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                self.player = sound
                sound.numberOfLoops = 0 // play once
                sound.prepareToPlay()
                sound.volume = 0.93
                sound.play()
                self.delegate?.soundEffect(self, didPlaySoundEffect: soundEffect, player: player!)
            } catch let err {
                self.delegate?.soundEffect(self, didErr: err)
            }
        } else {
            print("When modifying asset files in the project directory, please match their name by the SoundEffect enum to avoid crash.")
            fatalError("Incorrect name to .wav asset.")
        }
    }

}