//
//  MergeVideoAudioViewController.swift
//  camera_video
//
//  Created by linzsc on 31/01/2021.
//

import UIKit
import AVFoundation

class MergeVideoAudioViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var player: AVPlayer!
    var item: AVPlayerItem!
    var layer: AVPlayerLayer!
    var mutableComposition: AVMutableComposition!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let videoString = Bundle.main.path(forResource: "test1", ofType: "mp4")!
        let asset = AVAsset(url: URL(fileURLWithPath: videoString))
        mutableComposition = AVMutableComposition()
        for track in asset.tracks {
            let temp = mutableComposition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? temp?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: track, at: .zero)
        }
        item = AVPlayerItem(asset: mutableComposition)
        player = AVPlayer(playerItem: item)
        layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        layer.frame = self.previewView.bounds
        previewView.layer.addSublayer(layer)
        
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 5), queue: .main, using: {_ in
            self.timeLabel.text = "\(self.player.currentTime().seconds)"
        })
        
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }

    @IBAction func playButtonDidTap(_ sender: Any) {
        if player.timeControlStatus == .playing {
            player.pause()
        }
        else {
            player.play()
        }
    }
    
    @IBAction func functionButtonDidTap(_ sender: Any) {
        mergeVideo2()
    }
    
    func mergeVideo2() {
        let asset = AVAsset(url: URL(fileURLWithPath: Bundle.main.path(forResource: "test1", ofType: "mp4")!))
        let asset2 = AVAsset(url: URL(fileURLWithPath: Bundle.main.path(forResource: "keobonggon", ofType: "mp4")!))
        let time = mutableComposition.duration
        for track in asset2.tracks {
            let temp = mutableComposition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? temp?.insertTimeRange(CMTimeRange(start: .zero, duration: asset2.duration), of: track, at: CMTime(value: time.value, timescale: time.timescale))
        }
        
        let layerInstruction1 = AVMutableVideoCompositionLayerInstruction(assetTrack: mutableComposition.tracks[0])
        let aspectX = asset2.tracks[0].naturalSize.width / asset.tracks[0].naturalSize.width
        let aspectY = asset2.tracks[0].naturalSize.height / asset.tracks[0].naturalSize.height
        layerInstruction1.setTransform(mutableComposition.tracks[0].preferredTransform.scaledBy(x: aspectX, y: aspectY).translatedBy(x: 0, y: 0.01), at: .zero)
        

        let layerInstruction2 = AVMutableVideoCompositionLayerInstruction(assetTrack: mutableComposition.tracks[2])
        layerInstruction2.setTransform(mutableComposition.tracks[2].preferredTransform.translatedBy(x: 0, y: 0.01), at: time)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: mutableComposition.duration)
        instruction.layerInstructions = [layerInstruction1, layerInstruction2]
        
        let videoComposition = AVMutableVideoComposition(propertiesOf: mutableComposition)
        videoComposition.renderSize = asset2.tracks[0].naturalSize
        videoComposition.instructions = [instruction]
                
        item = AVPlayerItem(asset: mutableComposition)
        item.videoComposition = videoComposition
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    func mergeVideo1() {
        let asset2 = AVAsset(url: URL(fileURLWithPath: Bundle.main.path(forResource: "keobonggon", ofType: "mp4")!))
        let endTime: Double = mutableComposition.duration.seconds
        for track in asset2.tracks {
            for trackComposition in mutableComposition.tracks {
                if trackComposition.mediaType == track.mediaType {
                    try? trackComposition.insertTimeRange(CMTimeRange(start: .zero, duration: asset2.duration), of: track, at: CMTime(seconds: endTime, preferredTimescale: 600))
                }
            }
        }
        item = AVPlayerItem(asset: mutableComposition)
        player.replaceCurrentItem(with: item)
        player.play()
    }
}
