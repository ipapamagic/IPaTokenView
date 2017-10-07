//
//  TestTokenObject.swift
//  IPaTokenViewSample
//
//  Created by IPa Chen on 2016/5/31.
//  Copyright © 2016年 AMagicStudio. All rights reserved.
//

import Foundation
import UIKit
import IPaTokenView
class TestTokenObject :IPaTokenObject {
    var token: String = ""
    func tokenName() -> String
    {
        return token
    }
    func tokenBackgroundColor() -> UIColor
    {
        return UIColor.green
    }
    func tokenTextColor() -> UIColor
    {
        return UIColor.white
    }
    func tokenSelectedBackgroundColor() -> UIColor
    {
        return UIColor.darkGray
    }
    func tokenSelectedTextColor() -> UIColor
    {
        return UIColor.white
    }
}
