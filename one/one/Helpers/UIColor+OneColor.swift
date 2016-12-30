//
//  UIColor+OneColor.swift
//  one
//
//  Created by Kai Chen on 12/29/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit

extension UIColor {
    class var followButtonLightBlue: UIColor {
        return UIColor.rgb(fromHex: 0x0693E3)
    }

    class func rgb(fromHex: Int) -> UIColor {
        let red =   CGFloat((fromHex & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((fromHex & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(fromHex & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
