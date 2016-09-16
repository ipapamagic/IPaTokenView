//
//  TestTokenObject.swift
//  IPaTokenViewSample
//
//  Created by IPa Chen on 2016/5/31.
//  Copyright © 2016年 AMagicStudio. All rights reserved.
//

import Foundation
import UIKit
class TestTokenObject :IPaTokenObject {
    var token: String = ""
    func tokenName() -> String
    {
        return token
    }
    func tokenBackgroundColor() -> UIColor
    {
        return UIColor.greenColor()
    }
    func tokenTextColor() -> UIColor
    {
        return UIColor.whiteColor()
    }
    func tokenSelectedBackgroundColor() -> UIColor
    {
        return UIColor.darkGrayColor()
    }
    func tokenSelectedTextColor() -> UIColor
    {
        return UIColor.whiteColor()
    }
}