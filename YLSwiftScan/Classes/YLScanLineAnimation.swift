//
//  YLScanLineAnimation.swift
//  YLScan
//
//  Created by 王留根 on 17/1/11.
//  Copyright © 2017年 ios-mac. All rights reserved.
//

import UIKit

class YLScanLineAnimation: UIImageView {

    var isAnimationing = false
    var animationRect: CGRect = CGRect.zero
    private var ifNetGrid = false
    
    deinit {
        print("deinit lineAnimation")
        stopStepAnimation()
    }
    public class func instance() -> YLScanLineAnimation {
        return YLScanLineAnimation()
    }
    
    public class func nerGridInstance() -> YLScanLineAnimation{
        let lineAnimation = YLScanLineAnimation()
        lineAnimation.ifNetGrid = true
        return lineAnimation
    }
    
    func startAnimationingWithRect(animationRect: CGRect, parentView: UIView, image: UIImage?) {
        self.image = image
        self.animationRect = animationRect
        parentView.addSubview(self)
        self.isHidden = false
        isAnimationing = true
        if let _ = image {
            stepAnimation()
        }
    }
    
    func stepAnimation()  {
        guard isAnimationing else {
            return
        }
        
        var frame: CGRect = animationRect
        let hImage = self.image!.size.height * animationRect.size.width / self.image!.size.width
        frame.origin.y = frame.origin.y - hImage
        frame.size.height = hImage
        self.frame = frame
        self.alpha = 0.0
        var timeInterval: TimeInterval = 1.4
        if ifNetGrid {
            timeInterval = 1.2
        }
        
        UIView.animate(withDuration: timeInterval, animations: {[weak self] () -> Void in
            self?.alpha = 1.0
            var frame = self?.animationRect
            let hImage = (self?.image!.size.height)! * (self?.animationRect.size.width)! / (self?.image!.size.width)!
            frame?.origin.y = (frame?.origin.y)! + (frame?.size.height)! - hImage
            frame?.size.height = hImage
            self?.frame = frame!
            
        }, completion:{[weak self]  (value: Bool) -> Void in
                self?.perform(#selector(self?.stepAnimation), with: nil, afterDelay: 0.3)
        })
    }
    
    public func stopStepAnimation() {
        self.isHidden = true
        isAnimationing = false
    }
    

}






























