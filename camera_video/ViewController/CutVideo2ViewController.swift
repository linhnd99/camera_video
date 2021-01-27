//
//  CutVideo2ViewController.swift
//  camera_video
//
//  Created by linzsc on 26/01/2021.
//

import UIKit
import AVFoundation

class CutVideo2ViewController: UIViewController {

    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    
    var player: AVPlayer!
    var mutableComposition: AVMutableComposition!
    var item: AVPlayerItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configPreview()
    }
    
    deinit {
        print("deinit view controller")
    }

    func configPreview() {
        let videoString = Bundle.main.path(forResource: "zzz", ofType: "mp4")
        if videoString == nil {
            print("video not found")
            return
        }
        print(videoString!)
        let url = URL(fileURLWithPath: videoString!)
        mutableComposition = AVMutableComposition()
        let asset = AVAsset.init(url: url)
        mutableComposition = AVMutableComposition()
        for track in asset.tracks {
//            mutableComposition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
//            let trackz = mutableComposition.tracks.last
            let compositionTrack = mutableComposition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
            try? compositionTrack!.insertTimeRange(CMTimeRange(start: .zero, end: asset.duration), of: track, at: .zero)
        }
        item = AVPlayerItem(asset: mutableComposition)
        player = AVPlayer(playerItem: item)
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main, using: { time in
            print(time)
        })
        SharedData.sharedData.player = player
        let playlayer = AVPlayerLayer(player: SharedData.sharedData.player!)
        playlayer.videoGravity = .resizeAspect
        playlayer.frame = self.previewView.bounds
        self.previewView.layer.addSublayer(playlayer)
        try! AVAudioSession.sharedInstance().setCategory(.playback)
        try! AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    @IBAction func playButtonDidTap(_ sender: Any) {
        if (playButton.title(for: .normal) == "Play") {
            playButton.setTitle("Pause", for: .normal)
            SharedData.sharedData.player?.play()
        }
        else {
            playButton.setTitle("Play", for: .normal)
            SharedData.sharedData.player?.pause()
        }
    }
    
    @IBAction func showCutVideoButtonDidTap(_ sender: Any) {
        // let from = Double(fromTextField.text ?? "0")
        // let to = Double(toTextField.text ?? "0")
        let from = Double(0)
        let to = Double(30)
        for track in mutableComposition.tracks {
            track.removeTimeRange(CMTimeRange(start: CMTime(seconds: from, preferredTimescale: 1), end: CMTime(seconds: to, preferredTimescale: 1)))
        }
        mutableComposition.removeTimeRange(CMTimeRange(start: CMTime(seconds: from, preferredTimescale: 1), end: CMTime(seconds: to, preferredTimescale: 1)))
        // cutvideo2()
        item = AVPlayerItem(asset: mutableComposition)
        player.replaceCurrentItem(with: item)
        print("cut ok")
    }
    
    func cutvideo2() {
        let from = Double(30)
        let to = Double(80)
        let newMutaCom = AVMutableComposition()
        for track in mutableComposition.tracks {
            if track.mediaType != .audio {
                continue
            }
            let trackComposition = newMutaCom.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
            try? trackComposition?.insertTimeRange(CMTimeRange(
                                                start: CMTime(seconds: to, preferredTimescale: 1),
                                                duration: mutableComposition.duration - CMTime(seconds: to, preferredTimescale: 1)),
                                              of: track, at: .zero)
            try? trackComposition?.insertTimeRange(CMTimeRange(
                                                start: CMTime(seconds: 0, preferredTimescale: 1),
                                                duration: CMTime(seconds: from, preferredTimescale: 1)),
                                              of: track, at: .zero)
        }
        mutableComposition = newMutaCom
    }
    
}
