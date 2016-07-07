//
//  CVPasscodeController.swift
//  CVPasscodeController
//
//  Created by 杨弘宇 on 16/7/6.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit
import AudioToolbox

public enum CVPasscodeInterfaceStyle {
    case Dark
    case Light
}


public enum CVPasscodeInterfaceStringType {
    case InitialHint
    case WrongHint
    case Cancel
    case Backspace
}


public protocol CVPasscodeInterfaceStringProviding {
    func interfaceStringOfType(type: CVPasscodeInterfaceStringType, forPasscodeController controller: CVPasscodeController) -> String
}


public protocol CVPasscodeEvaluating {
    // Return the number of digits in this method to initialize the digit indicator and help the controller judge the end of user inputting.
    func numberOfDigitsInPasscodeForPasscodeController(controller: CVPasscodeController) -> Int
    
    // This will be called after the designated digits finished being inputted, if true was returned then the controller will dismiss, otherwise, the device will vibrate and there will be some visual feedback to tell user the passcode was wrong.
    func evaluatePasscode(passcode: String, forPasscodeController controller: CVPasscodeController) -> Bool
    
    // This will be called after user tapped the cancel button and controller has dismissed.
    func passcodeControllerDidCancel(controller: CVPasscodeController)
}


public class CVPasscodeController: UIViewController {

    private var hintLabel: UILabel!
    private var backspaceButton: UIButton!
    private var keypad: CVKeypad!
    private var indicator: CVPasscodeIndicator!
    
    private var currentInput = ""
    private var numberOfDigits: Int!
    private var evaluating = false
    
    public var interfaceStringProvider: CVPasscodeInterfaceStringProviding? // Set this to provide custom localized interface strings.
    public var passcodeEvaluator: CVPasscodeEvaluating! // This property must be set to tell the controller whether the passcode user input is valid.
    
    public let interfaceStyle: CVPasscodeInterfaceStyle // The getter of current interface style.
    
    public init(interfaceStyle: CVPasscodeInterfaceStyle) {
        self.interfaceStyle = interfaceStyle
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.interfaceStyle = .Dark
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.interfaceStyle = .Dark
        super.init(coder: aDecoder)
    }
    
    convenience init() {
        self.init(interfaceStyle: .Dark)
    }
    
    public override func loadView() {
        super.loadView()
        
        assert(passcodeEvaluator != nil, "Evaluator must be set before controller presented.")
        numberOfDigits = passcodeEvaluator.numberOfDigitsInPasscodeForPasscodeController(self)
        
        let blackColor = UIColor.blackColor()
        let whiteColor = UIColor.whiteColor()
        
        hintLabel = UILabel()
        backspaceButton = UIButton(type: .System)
        keypad = CVKeypad()
        indicator = CVPasscodeIndicator(countOfDigits: numberOfDigits)
        
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.font = UIFont.systemFontOfSize(19)
        hintLabel.textColor = interfaceStyle == .Dark ? whiteColor : blackColor
        hintLabel.text = interfaceStringProvider?.interfaceStringOfType(.InitialHint, forPasscodeController: self) ?? "Enter Passcode"
        
        backspaceButton.tintColor = interfaceStyle == .Dark ? whiteColor : blackColor
        backspaceButton.translatesAutoresizingMaskIntoConstraints = false
        backspaceButton.addTarget(self, action: #selector(cancel), forControlEvents: .TouchUpInside)
        updateBackspaceButtonTitle()
        
        let interfaceVisualEffect = UIBlurEffect(style: self.interfaceStyle == .Dark ? .Dark : .ExtraLight)
        
        keypad.translatesAutoresizingMaskIntoConstraints = false
        keypad.keypadCells.forEach { cell in
            cell.color = self.interfaceStyle == .Dark ? whiteColor : blackColor
            cell.interfaceVisualEffect = interfaceVisualEffect
            cell.addTarget(self, action: #selector(cellDidTap(_:)), forControlEvents: .TouchDown)
        }
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.interfaceVisualEffect = interfaceVisualEffect
        
        view.addSubview(hintLabel)
        view.addSubview(backspaceButton)
        view.addSubview(keypad)
        view.addSubview(indicator)
        
        view.addConstraint(NSLayoutConstraint(
            item: hintLabel,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: -230)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: hintLabel,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: backspaceButton,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: -35)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: backspaceButton,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: keypad,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 50)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: keypad,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: keypad,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: 275)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: keypad,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: 375)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: indicator,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: hintLabel,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 15)
        )
        
        view.addConstraint(NSLayoutConstraint(
            item: indicator,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)
        )
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return interfaceStyle == .Dark ? .LightContent : .Default
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    // MARK: - Private methods
    
    private func updateBackspaceButtonTitle() {
        let title: String
        if currentInput.characters.count == 0 {
            title = interfaceStringProvider?.interfaceStringOfType(.Cancel, forPasscodeController: self) ?? "Cancel"
        } else {
            title = interfaceStringProvider?.interfaceStringOfType(.Backspace, forPasscodeController: self) ?? "Delete"
        }
        
        backspaceButton.setTitle(title, forState: .Normal)
    }
    
    @objc private func cellDidTap(sender: AnyObject?) {
        if evaluating {
            return
        }
        
        if let cell = sender as? CVKeypadCell {
            let digitString = cell.text!
            currentInput += digitString
            indicator.setNumberOfFilledDot(currentInput.characters.count)
            updateBackspaceButtonTitle()
            if currentInput.characters.count == numberOfDigits {
                evaluating = true
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC * 200)), dispatch_get_main_queue()) {
                    self.evaluatePasscode()
                    self.evaluating = false
                }
            }
        }
    }
    
    @objc private func cancel() {
        if currentInput.characters.count == 0 {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            currentInput = currentInput.substringToIndex(currentInput.endIndex.predecessor())
            indicator.setNumberOfFilledDot(currentInput.characters.count)
            updateBackspaceButtonTitle()
        }
    }

    private func evaluatePasscode() {
        if passcodeEvaluator.evaluatePasscode(currentInput, forPasscodeController: self) {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            currentInput = ""
            indicator.setNumberOfFilledDot(0)
            updateBackspaceButtonTitle()
            performRetryFeedback()
        }
    }
    
    private func performRetryFeedback() {
        // First, shake the indicator view.
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.values = [-20, 19, -18, 17, -15, 12, -6, 2, 0].map({ return NSNumber(int: $0) })
        shakeAnimation.duration = 0.6
        indicator.layer.addAnimation(shakeAnimation, forKey: "shake")
        
        // Second, set the hint label.
        UIView.transitionWithView(hintLabel, duration: 0.3, options: .TransitionCrossDissolve, animations: {
            self.hintLabel.text = self.interfaceStringProvider?.interfaceStringOfType(.WrongHint, forPasscodeController: self) ?? "Wrong passcode, try again"
        }, completion: nil)
        
        // Third, vibrate the device.
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
}


extension CVPasscodeController: UIViewControllerTransitioningDelegate {
    
    class CVPasscodePresentationController: UIPresentationController {
        
        private var blurBackgroundView: UIVisualEffectView!
        
        override func presentationTransitionWillBegin() {
            super.presentationTransitionWillBegin()
            
            guard containerView != nil else {
                return
            }
            
            blurBackgroundView = UIVisualEffectView(effect: nil)
            blurBackgroundView.frame = containerView!.bounds
            
            containerView!.addSubview(blurBackgroundView)
            
            presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ _ in
                let interfaceStyle = (self.presentedViewController as! CVPasscodeController).interfaceStyle
                self.blurBackgroundView.effect = UIBlurEffect(style: interfaceStyle == .Dark ? .Dark : .ExtraLight)
            }, completion: nil)
        }
        
        override func presentationTransitionDidEnd(completed: Bool) {
            super.presentationTransitionDidEnd(completed)
            
            if !completed && blurBackgroundView != nil {
                blurBackgroundView.removeFromSuperview()
            }
        }
        
        override func dismissalTransitionWillBegin() {
            super.dismissalTransitionWillBegin()
            
            guard blurBackgroundView != nil else {
                return
            }
            
            presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ _ in
                self.blurBackgroundView.effect = nil
            }, completion: nil)
        }
        
        override func dismissalTransitionDidEnd(completed: Bool) {
            super.dismissalTransitionDidEnd(completed)
            
            if completed && blurBackgroundView != nil {
                blurBackgroundView.removeFromSuperview()
            }
        }
        
    }
    
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return CVPasscodePresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
}
