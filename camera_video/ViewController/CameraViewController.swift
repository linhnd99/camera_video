//
//  CameraViewController.swift
//  camera_video
//
//  Created by linzsc on 25/01/2021.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configCamera()
    }

    func configCamera() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        // config input
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        if device == nil {
            print("No camera")
            return
        }
        let inputDevice = try? AVCaptureDeviceInput(device: device!)
        session.addInput(inputDevice!)
        
        // config output
        // let outputDevice = AVCaptureVideoDataOutput()
        let outputDevice = AVCapturePhotoOutput()
        session.sessionPreset = .photo
        session.addOutput(outputDevice)
        
        session.commitConfiguration()
        
        let previewView = PreviewView()
        previewView.videoPreviewLayer.session = session
        self.view = previewView
        
        session.startRunning()
    }
    
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    // Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
