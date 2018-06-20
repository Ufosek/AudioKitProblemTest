//
//  SongPlayer.swift
//  PopnutyKaraoke
//
//  Created by Kacper Piątkowski on 12.09.2017.
//  Copyright © 2017 Panowie Programisci. All rights reserved.
//

import Foundation
import AudioKit

class SongPlayer {

    static var BUFFER_TYPE_: AKSettings.BufferLength = .short
    static var MIC_VOLUME = 2
    static var MIC_GAIN = 5
    
    //
    
    static let instance = SongPlayer()
    
    var INIT_MIC_ONCE = true
    
    //
    
    fileprivate var player: AKAudioPlayer!
    fileprivate var mic: AKMicrophone!
    fileprivate var tracker: AKFrequencyTracker!
    fileprivate var micBooster: AKBooster!
    fileprivate var mainMixer: AKMixer!
    
    fileprivate var tempURL: String = ""
    
    init() {
        AKSettings.defaultToSpeaker = false
        AKSettings.audioInputEnabled = true
        AKSettings.bufferLength = SongPlayer.BUFFER_TYPE_
        AKSettings.enableLogging = true
        
        if INIT_MIC_ONCE {
            mic = AKMicrophone()
        }
    }
    
    func setup(tempURL: String) {
        self.tempURL = tempURL
    }
    
    func pause() {
        self.player?.pause()
    }
    
    //play after stop
    @discardableResult
    func start(restart: Bool) -> Bool {
        self.setupPlayer()
        
        if AKSettings.headPhonesPlugged {
            if !INIT_MIC_ONCE {
                mic = AKMicrophone()
            }
            tracker = AKFrequencyTracker(mic)
            micBooster = AKBooster(tracker)
            mainMixer = AKMixer(player, micBooster)
            AudioKit.output = mainMixer
        } else {
            mainMixer = AKMixer(player)
            AudioKit.output = mainMixer
        }
        
        do {
            try AudioKit.start()
        } catch {
            print("Unexpected error: \(error).")
        }

        micBooster?.gain = AKSettings.headPhonesPlugged ? Double(SongPlayer.MIC_VOLUME) : 0
        mic?.volume = AKSettings.headPhonesPlugged ? Double(SongPlayer.MIC_GAIN) : 0
        
        self.player.volume = 1.0
        
        self.mic?.start()
        self.tracker?.start()
        
        self.player.play(from: 30, to: self.player.duration)
        
        return true
    }
    
    func stop() {
        do {
            try AudioKit.stop()
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    //
    
    fileprivate func setupPlayer() {
        do {
            if let url = URL(string: self.tempURL) {
                if let file = try? AKAudioFile(forReading: url) {
                    player = try AKAudioPlayer(file: file)
                }
            }
        } catch {
            print("PLAYER URL ERROR")
        }
    }
    
}
