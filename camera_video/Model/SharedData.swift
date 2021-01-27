//
//  SharedData.swift
//  camera_video
//
//  Created by linzsc on 27/01/2021.
//

import UIKit
import AVFoundation

class SharedData: NSObject {
    private static var data: SharedData?
    
    static var sharedData: SharedData {
        get{
            if data == nil {
                data = SharedData()
                print("init SharedData")
            }
            return data!
        }
    }
    
    var player: AVPlayer?
    var mutableComposition: AVMutableComposition?
    var item: AVPlayerItem?
    
}
