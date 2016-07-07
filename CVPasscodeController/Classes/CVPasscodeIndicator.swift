//
//  CVPasscodeIndicator.swift
//  CVPasscodeController
//
//  Created by 杨弘宇 on 16/7/6.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit

class CVPasscodeIndicator: UIView {

    var interfaceVisualEffect: UIVisualEffect!
    
    private var vibrancyView: UIVisualEffectView!
    private var dotLayers = [CAShapeLayer]()
    
    init(countOfDigits: Int) {
        super.init(frame: CGRect.zero)
        
        vibrancyView = UIVisualEffectView(effect: nil)
        
        for _ in 0..<countOfDigits {
            let dotLayer = CAShapeLayer()
            dotLayer.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
            dotLayer.path = CGPathCreateWithEllipseInRect(dotLayer.frame, nil)
            dotLayer.lineWidth = 1.5
            dotLayer.strokeColor = UIColor.whiteColor().CGColor
            dotLayer.fillColor = nil
            
            vibrancyView.contentView.layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
        }
        
        addSubview(vibrancyView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        vibrancyView.frame = bounds
        
        for (i, dotLayer) in dotLayers.enumerate() {
            dotLayer.frame.origin = CGPoint(x: i * 40 + 2, y: 3)
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 40 * dotLayers.count - 14, height: 16)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        vibrancyView.effect = UIVibrancyEffect(forBlurEffect: interfaceVisualEffect as! UIBlurEffect)
    }

    func setNumberOfFilledDot(number: Int) {
        for (i, dotLayer) in dotLayers.enumerate() {
            if i < number {
                dotLayer.fillColor = UIColor.whiteColor().CGColor
            } else {
                dotLayer.fillColor = nil
            }
        }
    }
    
}
