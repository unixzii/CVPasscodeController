//
//  CVKeypadCell.swift
//  CVPasscodeController
//
//  Created by 杨弘宇 on 16/7/6.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit
import AudioToolbox

class CVKeypadCell: UIControl {

    var text: String?
    var color: UIColor!
    var interfaceVisualEffect: UIVisualEffect!
    
    private var vibrancyView: UIVisualEffectView!
    private var outlineView: UIView!
    private var label: UILabel!
    
    private var outlineLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        vibrancyView = UIVisualEffectView(effect: nil)
        outlineView = UIView()
        label = UILabel()
        
        outlineLayer = CAShapeLayer()
        outlineLayer.lineWidth = 2
        outlineLayer.strokeColor = UIColor.whiteColor().CGColor
        outlineLayer.fillColor = nil
        
        outlineView.layer.addSublayer(outlineLayer)
        
        vibrancyView.contentView.addSubview(outlineView)
        
        label.font = UIFont.systemFontOfSize(32, weight: UIFontWeightThin)
        label.textAlignment = .Center
        
        addSubview(vibrancyView)
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        vibrancyView.frame = bounds
        outlineView.frame = vibrancyView.bounds
        outlineLayer.frame = outlineView.bounds.insetBy(dx: 5, dy: 5).offsetBy(dx: -2.5, dy: -2.5)
        outlineLayer.path = CGPathCreateWithEllipseInRect(outlineLayer.frame, nil)
        
        label.frame = bounds
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        vibrancyView.effect = UIVibrancyEffect(forBlurEffect: interfaceVisualEffect as! UIBlurEffect)
        label.textColor = color
        label.text = text
    }
    
    // MARK: - Touch event handlers
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let distance = sqrt(pow(point.x - CGRectGetMidX(bounds), 2) + pow(point.y - CGRectGetMidY(bounds), 2))
        
        return distance <= bounds.width / 2.0 ? self : nil
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        AudioServicesPlaySystemSound(1104)
        
        setFillColor(UIColor.whiteColor(), labelColor: UIColor.whiteColor(), animated: false)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        setFillColor(UIColor.clearColor(), labelColor: color, animated: true)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        
        setFillColor(UIColor.clearColor(), labelColor: color, animated: true)
    }
    
    // MARK: - Private methods
    
    func setFillColor(color: UIColor, labelColor: UIColor, animated: Bool) {
        CATransaction.begin()
        if animated {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.6)
            CATransaction.setAnimationDuration(0.6)
            
            defer {
                UIView.commitAnimations()
            }
        } else {
            CATransaction.setDisableActions(true)
        }
        outlineLayer.fillColor = color.CGColor
        label.textColor = labelColor
        CATransaction.commit()
    }

}
