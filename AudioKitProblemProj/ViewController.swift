//
//  ViewController.swift
//  AudioKitProblemProj
//
//  Created by Ufos on 20.06.2018.
//  Copyright © 2018 Panowie Programisci. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let fileUrl = Bundle.main.path(forResource: "Taylor_Swift_Delicate", ofType: "mp3") {
            SongPlayer.instance.setup(tempURL: fileUrl)
        }
        
        self.addListener()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SongPlayer.instance.start(restart: false)
    }
    
    
    
    //


    fileprivate func addListener() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.audioRouteChangeListener(notification:)),
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil)
    }
    
    fileprivate func removeListener() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    @objc func audioRouteChangeListener(notification:NSNotification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
            DispatchQueue.global().async {
                SongPlayer.instance.stop()
                SongPlayer.instance.start(restart: true)
            }
            
            break
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
            DispatchQueue.global().async {
                SongPlayer.instance.stop()
                SongPlayer.instance.start(restart: true)
            }
            
            break
        default:
            break
        }
    }
    
}

