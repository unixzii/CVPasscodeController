//
//  CVKeypad.swift
//  CVPasscodeController
//
//  Created by 杨弘宇 on 16/7/6.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

import UIKit

class CVKeypad: UIView {

    private(set) var keypadCells = [CVKeypadCell]()
    
    init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        for i in 1...10 {
            let cell = CVKeypadCell(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
            cell.text = "\(i == 10 ? 0 : i)"
            
            addSubview(cell)
            keypadCells.append(cell)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var col = 0
        var row = 0
        
        for cell in keypadCells {
            cell.frame.origin = CGPoint(x: col * 100, y: row * 100)
            
            col += 1
            if col > 2 {
                row += 1
                col = row == 3 ? 1 : 0
            }
        }
    }

}
