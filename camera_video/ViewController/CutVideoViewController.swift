//
//  CutVideoViewController.swift
//  camera_video
//
//  Created by linzsc on 26/01/2021.
//

import UIKit
import AVFoundation

class CutVideoViewController: UIViewController {
    
    // MARK:- UI
    @IBOutlet weak var timelineView: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    var asset: AVAsset!
    var player: AVPlayer!
    var item: AVPlayerItem!
    
    // MARK:- Action
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configPreviewView()
    }

    @IBAction func playButtonDidTap(_ sender: Any) {
        if self.playButton.title(for: .normal) == "Play" {
            self.playButton.setTitle("Pause", for: .normal)
            player.play()
        }
        else {
            self.playButton.setTitle("Play", for: .normal)
            player.pause()
        }
    }
        
    func configPreviewView() {
        let videoString = Bundle.main.path(forResource: "mtp", ofType: "mp4")
        if videoString == nil {
            print("video not found")
            return
        }
        let url = URL(fileURLWithPath: videoString!)
        asset = AVAsset(url: url)
        item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        let layer = AVPlayerLayer(player: player)
        layer.frame = self.previewView.bounds
        layer.videoGravity = .resizeAspect
        self.previewView.layer.addSublayer(layer)
        try! AVAudioSession.sharedInstance().setCategory(.playback)
        try! AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    func configTimelineView() {
        let listThumb = getListThumbnail()
        
    }
    
    func getListThumbnail() -> Array<UIImage> {
        var res: Array<UIImage> = []
        let numberSegment = item.duration.seconds/Double(self.timelineView.frame.width) * 50
        let temp = numberSegment - Double(Int(numberSegment)) <= 0.00001 ? 0 : 1
        for index in 0 ..< (Int(numberSegment) + temp) {
            let generation = AVAssetImageGenerator(asset: asset)
            let atSecond = min(Double(50*(index+1)/2), item.duration.seconds)
            let thumbnail = try? generation.copyCGImage(at: CMTime(seconds: atSecond, preferredTimescale: 1), actualTime: nil)
            if thumbnail == nil {
                continue
            }
            res.append(UIImage(cgImage: thumbnail!))
        }
        return res
    }
}
