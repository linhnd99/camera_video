//
//  CutVideo2ViewController.swift
//  camera_video
//
//  Created by linzsc on 26/01/2021.
//

import UIKit
import AVFoundation

class CutVideo2ViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    
    var player: AVPlayer!
    var mutableComposition: AVMutableComposition!
    var item: AVPlayerItem!
    var asset: AVAsset!
    var videoComposition: AVVideoComposition!
    var playlayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configPreview()
    }
    
    deinit {
        print("deinit view controller")
    }

    func configPreview() {
        let videoString = Bundle.main.path(forResource: "yyy", ofType: "mp4")
        if videoString == nil {
            print("video not found")
            return
        }
        print(videoString!)
        let url = URL(fileURLWithPath: videoString!)
        mutableComposition = AVMutableComposition()
        asset = AVAsset.init(url: url)
        mutableComposition = AVMutableComposition()
        for track in asset.tracks {
            let compositionTrack = mutableComposition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
            try? compositionTrack!.insertTimeRange(CMTimeRange(start: .zero, end: asset.duration), of: track, at: .zero)
        }
        item = AVPlayerItem(asset: mutableComposition)
        player = AVPlayer(playerItem: item)
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main, using: { time in
            // print(time)
        })
        SharedData.sharedData.player = player
        playlayer = AVPlayerLayer(player: SharedData.sharedData.player!)
        playlayer.videoGravity = .resizeAspect
        playlayer.frame = self.previewView.bounds
        self.previewView.layer.addSublayer(playlayer)
        try! AVAudioSession.sharedInstance().setCategory(.playback)
        try! AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playlayer.frame = self.previewView.bounds
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
    @IBAction func addSoundButtonDidTap(_ sender: Any) {
        cropVideo3()
    }
    
    // crop video with filter CICrop
    func cropVideo3() {
        let filter = CIFilter(name: "CICrop")!
        let videoComposition = AVMutableVideoComposition(asset: mutableComposition, applyingCIFiltersWithHandler:{ (request) in
            let source = request.sourceImage.clampedToExtent()
            filter.setValue(source, forKey: "inputImage")
            
            let rect = CGRect(x: 100, y: 100, width: 200, height: 200)
            let rec = CIVector(cgRect: rect)
            filter.setValue(rec, forKey: "inputRectangle")
            
            let output = filter.outputImage!.cropped(to: rect)
            
            // Provide the filter output to the composition
            request.finish(with: output, context: nil)
        })
        videoComposition.renderSize = CGSize(width: 400, height: 400)
        item.videoComposition = videoComposition
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    func cropVideo2() {
//        let videoComposition = AVMutableVideoComposition(propertiesOf: mutableComposition)
//        let compositionLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: mutableComposition.tracks(withMediaType: .video).first!)
//        //compositionLayerInstruction.setTransform(.identity, at: .zero)
//
//        let instruction = AVMutableVideoCompositionInstruction.init()
//        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: mutableComposition.duration)
//        instruction.layerInstructions = [compositionLayerInstruction]
//
//        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
//
//
//        //videoComposition.renderSize = CGSize(width: 512, height: 512)
//        videoComposition.instructions = [instruction]
//
//        item.videoComposition = videoComposition
//        player.replaceCurrentItem(with: item)
//        player.play()
//        print(item.tracks)
        
        
        mutableComposition = AVMutableComposition()
        var transform: CGAffineTransform!
        for track in asset.tracks {
            let trackComposition = mutableComposition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? trackComposition?.insertTimeRange(track.timeRange, of: track, at: .zero)
            
            trackComposition?.preferredTransform = track.preferredTransform
            transform = trackComposition?.preferredTransform
        }
        
        // composition layer instruction
        let videoComposition = AVMutableVideoComposition.init()

        let compositionLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: mutableComposition.tracks(withMediaType: .video).first!)
        compositionLayerInstruction.setCropRectangle(CGRect(x: 0.1, y: 0, width: 500, height: 500), at: .zero)
//        compositionLayerInstruction.setTransform(transform, at: .zero)
//        compositionLayerInstruction.setTransform(rotationInstruction(transform: transform, alpha: .pi*3/2), at: .zero)
        // compositionLayerInstruction.setTransform(transform.scaledBy(x: 0.5, y: 0.5), at: .zero)

        let instruction = AVMutableVideoCompositionInstruction.init()
        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: mutableComposition.duration)
        instruction.layerInstructions = [compositionLayerInstruction]

        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.renderSize = CGSize(width: 500, height: 500)
        
        videoComposition.instructions = [instruction]
        self.videoComposition = videoComposition
        item = AVPlayerItem(asset: mutableComposition)
        item.videoComposition = videoComposition
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    func cropVideo() {
        let videoComposition = AVMutableVideoComposition(propertiesOf: mutableComposition)
        

        let compositionLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: mutableComposition.tracks(withMediaType: .video).first!)
        compositionLayerInstruction.setTransform(rotationInstruction(transform: .identity, alpha: .pi*3/2), at: .zero)
        // compositionLayerInstruction.setTransform(transform.scaledBy(x: 0.5, y: 0.5), at: .zero)

        let instruction = AVMutableVideoCompositionInstruction.init()
        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: mutableComposition.duration)
        instruction.layerInstructions = [compositionLayerInstruction]

        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        videoComposition.instructions = [instruction]
        
        item.videoComposition = videoComposition
        player.replaceCurrentItem(with: item)
        player.play()
        
    }
    
    func rotatingPreview() {
        mutableComposition = AVMutableComposition()
        var transform: CGAffineTransform!
        for track in asset.tracks {
            let trackComposition = mutableComposition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? trackComposition?.insertTimeRange(track.timeRange, of: track, at: .zero)
            
            transform = trackComposition?.preferredTransform
        }
        
        // composition layer instruction
        let videoComposition = AVMutableVideoComposition.init(propertiesOf: mutableComposition)

        let compositionLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: mutableComposition.tracks(withMediaType: .video).first!)
        compositionLayerInstruction.setTransform(rotationInstruction(transform: transform, alpha: .pi*3/2), at: .zero)
        // compositionLayerInstruction.setTransform(transform.scaledBy(x: 0.5, y: 0.5), at: .zero)

        let instruction = AVMutableVideoCompositionInstruction.init()
        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: mutableComposition.duration)
        instruction.layerInstructions = [compositionLayerInstruction]

        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        videoComposition.instructions = [instruction]
        self.videoComposition = videoComposition
        item = AVPlayerItem(asset: mutableComposition)
        item.videoComposition = videoComposition
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    func rotationInstruction(transform: CGAffineTransform, alpha: CGFloat) -> CGAffineTransform {
        var alpha2 = alpha
        while alpha2 < 0 {
            alpha2 += .pi*2
        }
        while alpha2 >= .pi*2 {
            alpha2 -= .pi*2
        }
        
        var scale = CGFloat(0)
        
        if (alpha2 == .pi/2) {
            scale = mutableComposition.naturalSize.height/mutableComposition.naturalSize.width
            return transform.rotated(by: alpha2)
                .translatedBy(x: 0, y: -mutableComposition.naturalSize.width/2 - mutableComposition.naturalSize.height/2*scale)
                .scaledBy(x: scale, y: scale)
        }
        if alpha2 == .pi {
            return transform.rotated(by: alpha2)
                .translatedBy(x: -mutableComposition.naturalSize.width, y: -mutableComposition.naturalSize.height)
        }
        if (alpha2 == .pi*3/2) {
            scale = mutableComposition.naturalSize.height/mutableComposition.naturalSize.width
            return transform.rotated(by: alpha2)
                .translatedBy(x: -mutableComposition.naturalSize.width*scale, y: mutableComposition.naturalSize.width/2 - mutableComposition.naturalSize.height/2*scale)
                .scaledBy(x: scale, y: scale)
        }
        return transform
    }
    
        
    func filterLayer() {
        let filter = CIFilter(name: "CIBumpDistortion")!
        let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
            // Clamp to avoid blurring transparent pixels at the image edges
            let source = request.sourceImage.clampedToExtent()
            filter.setValue(source, forKey: kCIInputImageKey)
            
            let inputCenter = CIVector(values: [150, 150], count: 2)
            filter.setValue(inputCenter, forKey: "inputCenter")
            
            let inputRadius = NSNumber(value: 300)
            filter.setValue(inputRadius, forKey: "inputRadius")
            
            let inputScale = NSNumber(value: 0.5)
            filter.setValue(inputScale, forKey: "inputScale")

            // the blurred output to the bounds of the original image
            let output = filter.outputImage!.cropped(to: request.sourceImage.extent)

            // Provide the filter output to the composition
            request.finish(with: output, context: nil)
        })
        
        item.videoComposition = composition
        player.replaceCurrentItem(with: item)
    }
    
    func addSound() {
        let audioString = Bundle.main.path(forResource: "yyy", ofType: "mp4")
        let url = URL(fileURLWithPath: audioString!)
        let audioAsset = AVAsset(url: url)
        let assetTrack: AVAssetTrack = audioAsset.tracks(withMediaType: .audio).first!
        let trackComposition = mutableComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let segLength = Double(10) // audioAsset.duration
        
        for i in 0 ..< Int(Double(item.duration.seconds)/segLength) {
            try? trackComposition?.insertTimeRange(CMTimeRange(start: .zero,
                                                              end: CMTime(seconds: segLength,preferredTimescale: 600)),
                                                  of: assetTrack,
                                                  at: CMTime(seconds: segLength*Double(i), preferredTimescale: 600))
        }
        
        item = AVPlayerItem(asset: mutableComposition)
        item.audioTimePitchAlgorithm = .varispeed
        player.replaceCurrentItem(with: item)
        
        print(mutableComposition.tracks.count)
    }
}
