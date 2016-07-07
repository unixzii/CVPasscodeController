//
//  ViewController.swift
//  CVPasscodeControllerExample
//
//  Created by 杨弘宇 on 16/7/6.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit
import CVPasscodeController

class ViewController: UIViewController {

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func viewDidSwipe(sender: AnyObject) {
        let passcodeController = CVPasscodeController(interfaceStyle: .Dark)
        passcodeController.passcodeEvaluator = self
        
        presentViewController(passcodeController, animated: true, completion: nil)
    }

    @IBAction func viewDidTap(sender: AnyObject) {
        let passcodeController = CVPasscodeController(interfaceStyle: .Light)
        passcodeController.interfaceStringProvider = self
        passcodeController.passcodeEvaluator = self
        
        presentViewController(passcodeController, animated: true, completion: nil)
    }
    
}


extension ViewController: CVPasscodeEvaluating {
    
    func numberOfDigitsInPasscodeForPasscodeController(controller: CVPasscodeController) -> Int {
        return 6
    }
    
    func evaluatePasscode(passcode: String, forPasscodeController controller: CVPasscodeController) -> Bool {
        if passcode == "123456" {
            let alert = UIAlertController(title: "Content Unlocked", message: "This is some secret.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            // Delay 300ms to prevent presenting another VC while passcode controller is still on presentation. You may replace this with your own solution.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC * 300)), dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            return true
        }
        return false
    }
    
    func passcodeControllerDidCancel(controller: CVPasscodeController) {
        print("user cancelled")
    }
    
}


extension ViewController: CVPasscodeInterfaceStringProviding {
    
    func interfaceStringOfType(type: CVPasscodeInterfaceStringType, forPasscodeController controller: CVPasscodeController) -> String {
        switch type {
        case .Backspace:
            return "删除"
        case .Cancel:
            return "取消"
        case .InitialHint:
            return "输入密码以查看加密内容"
        case .WrongHint:
            return "密码错误，请重试"
        }
    }
    
}

