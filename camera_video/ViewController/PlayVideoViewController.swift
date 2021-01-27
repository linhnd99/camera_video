//
//  PlayVideoViewController.swift
//  camera_video
//
//  Created by linzsc on 25/01/2021.
//

import UIKit
import AVFoundation

class PlayVideoViewController: UIViewController {
    
    var videoString: String!
    var url: URL!
    var asset: AVAsset!
    var item: AVPlayerItem!
    var player: AVPlayer!
    var playLayer: AVPlayerLayer!

    @IBOutlet weak var previewView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        configVideo()
    }

    @IBAction func cutVideoButtonDidTap(_ sender: Any) {
        self.cutVideo(from: 0, to: 60)
    }
    @IBAction func decreaseRateButtonDidTap(_ sender: Any) {
        player.playImmediately(atRate: 0.5)
    }
    @IBAction func increaseRateButtonDidTap(_ sender: Any) {
        player.playImmediately(atRate: 30.0)
    }
    @IBAction func playButtonDidTap(_ sender: Any) {
        player.play()
    }
    
    func configVideo() {
        videoString = Bundle.main.path(forResource: "mtp", ofType: "mp4")!
        url = URL(fileURLWithPath: videoString)
        asset = AVAsset(url: url)
        
        item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        playLayer = AVPlayerLayer(player: player)
        playLayer.frame = self.previewView.bounds
        playLayer.videoGravity = .resizeAspect
        self.previewView.layer.addSublayer(playLayer)
        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try! AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(doingWhenPlayingDone),
             name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
             object: item)
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { time in
            print(Int64(time.value)/Int64(time.timescale))
        }
    }
    
    @objc func doingWhenPlayingDone() {
        print("loop")
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        player.playImmediately(atRate: player.rate)
    }
    
    func cutVideo(from: Double, to: Double) {
        // cut video with exporting
        // config URL output
        let documentDir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        var outputURL = documentDir?.appendingPathComponent("video")
        do {
            try FileManager.default.createDirectory(at: outputURL!, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
        outputURL = outputURL?.appendingPathComponent("videotest.mp4")
        try? FileManager.default.removeItem(at: outputURL!)
        
        // cut video
        let start = CMTime(seconds: Double(from), preferredTimescale: 1000)
        let end = CMTime(seconds: Double(to), preferredTimescale: 1000)
        let range = CMTimeRange(start: start, end: end)
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        if exportSession == nil {
            print("Can't cut video")
            return
        }
        exportSession?.timeRange = range
        exportSession?.outputURL = outputURL
        exportSession?.outputFileType = .mp4
        
        exportSession?.exportAsynchronously {
            switch exportSession?.status {
                case .completed:
                    print("Cut video successfully: ",outputURL!.path)
                case .failed:
                    print(exportSession!.error as Any)
                case .cancelled:
                    print("Cut video cancel: ",exportSession?.error as Any)
                default:
                    print(":)")
            }
        }
    }
    
    func cutVideoWithoutExport() {
        // cut video without exporting
//        let mutableComposition = AVMutableComposition(url: url)
//        for track in asset.tracks {
//            mutableComposition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
//        }
//        let range = CMTimeRange(start: CMTime(seconds: from, preferredTimescale: 1), end: CMTime(seconds: to, preferredTimescale: 1))
//        for track in mutableComposition.tracks {
//            track.removeTimeRange(range)
//        }
//        mutableComposition.removeTimeRange(range)
        
        
    }
}
