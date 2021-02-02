//
//  AppDelegate.swift
//  camera_video
//
//  Created by linzsc on 25/01/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let firstVC = MergeVideoAudioViewController()
        // let firstVC = CutVideo2ViewController()
        // let firstVC = PlayVideoViewController()
        window.rootViewController = firstVC
        window.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {

        // Disconnect the AVPlayer from the presentation when entering background

        // If presenting video with AVPlayerViewController
        SharedData.sharedData.player?.play()

        // If presenting video with AVPlayerLayer
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Reconnect the AVPlayer to the presentation when returning to foreground

        // If presenting video with AVPlayerViewController
        SharedData.sharedData.player?.play()

        // If presenting video with AVPlayerLayer
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

