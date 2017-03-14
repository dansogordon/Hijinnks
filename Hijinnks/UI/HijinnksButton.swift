//
//  HijinnksButton.swift
//  Hijinnks
//
//  Created by adeiji on 3/4/17.
//  Copyright © 2017 adeiji. All rights reserved.
//

import Foundation
import UIKit

class HijinnksButton : UIButton {
    
    var customButtonType:HijinnksViewTypes
    
    init(customButtonType: HijinnksViewTypes) {
        self.customButtonType = customButtonType
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {        
        if customButtonType == .MapButton {
            HijinnksStyleKit.drawMapButton(frame: rect)
        }
        else if customButtonType == .LikeEmptyButton {
            HijinnksStyleKit.drawLikeButton(frame: rect)
        }
        else if customButtonType == .LikeFilledButton {
            HijinnksStyleKit.drawLikeButtonFilled(frame: rect)
        }
        else if customButtonType == .HomeButton {
            HijinnksStyleKit.drawHomeButton(frame: rect, resizing: .stretch)
        }
    }
}