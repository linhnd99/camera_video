//
//  CutAudio.swift
//  DarkBoard
//
//  Created by linzsc on 23/01/2021.
//

import UIKit

class TimeLineView: UIView {
    private var images: Array<UIImage>!
    private var leftView: UIView!
    private var rightView: UIView!
    private var backgroundView: UIView!
    private var currentBar: UIView!
    
    private var leftCurrentBarConstraint: NSLayoutConstraint!
    
    init(frame: CGRect, images: Array<UIImage>) {
        self.images = images
        super.init(frame: frame)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        configBackgroundImage()
        configTimeLineUI()
    }
    
    func configBackgroundImage() {
        var currentX: CGFloat = 0
        for image in images {
            let imageView = UIImageView.init(image: image)
            imageView.frame = CGRect(x: currentX, y: 0, width: min(50,self.frame.width - currentX), height: self.frame.height)
            self.backgroundView.addSubview(imageView)
            currentX += 50
        }
    }
    
    func configTimeLineUI() {
        currentBar = UIView(frame: CGRect(x: 0, y: 0, width: 2, height: self.frame.height))
        currentBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(currentBar)
        
        currentBar.widthAnchor.constraint(equalToConstant: 2).isActive = true
        currentBar.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
        leftCurrentBarConstraint = currentBar.leftAnchor.constraint(equalTo: self.leftAnchor)
        leftCurrentBarConstraint.constant = 0
        leftCurrentBarConstraint.isActive = true
        
        let panCurrentBar = UIPanGestureRecognizer(target: self, action: Selector("panGestureCurrentBar"))
        currentBar.addGestureRecognizer(panCurrentBar)
    }
    
    @objc func panGestureCurrentBar(_ sender: Any?) {
        // todo
    }
    
//    func configCropLimiUI() {
//
//        let leftPan = UIPanGestureRecognizer(target: self, action: #selector(self.leftPanGesture(_:)))
//        leftView.addGestureRecognizer(leftPan)
//        let rightPan = UIPanGestureRecognizer(target: self, action: #selector(self.rightPanGesture(_:)))
//        rightView.addGestureRecognizer(rightPan)
//    }
//
//    @objc func leftPanGesture(_ sender: Any?) {
//        let panGesture = sender as! UIPanGestureRecognizer
//        let point = panGesture.location(in: self)
//        let distance = point.x
//        leftConstraint?.constant = distance
//    }
//    @objc func rightPanGesture(_ sender: Any?) {
//        let panGesture = sender as! UIPanGestureRecognizer
//        let point = panGesture.location(in: self)
//        let distance = self.frame.width - point.x
//        rightConstraint?.constant = distance
//    }
}
