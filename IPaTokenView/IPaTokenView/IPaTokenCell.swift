//
//  IPaTokenCell.swift
//  IPaTokenView
//
//  Created by IPa Chen on 2016/5/31.
//  Copyright © 2016年 AMagicStudio. All rights reserved.
//

import UIKit
protocol IPaTokenCellDelegate {
    func onDeleteToken(_ tokenObject:IPaTokenObject)
}
class IPaTokenCell: UIView {
    var delegate:IPaTokenCellDelegate!
    var _tokenLabel:UILabel?
    var tokenLabel:UILabel {
        get {
            if let _tokenLabel = _tokenLabel {
                return _tokenLabel
            }
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = true
            label.autoresizingMask = [.flexibleTopMargin,.flexibleLeftMargin,.flexibleRightMargin,.flexibleBottomMargin]
            self.addSubview(label)
            label.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            _tokenLabel = label
            return label
        }
    }
    
    var _tokenObject:IPaTokenObject!
    var tokenObject:IPaTokenObject! {
        get {
            return _tokenObject
        }
        set {
            _tokenObject = newValue
            refreshColor()
            tokenLabel.text = _tokenObject.tokenName()
            tokenLabel.sizeToFit()
            var rect = frame
            rect.size.width = tokenLabel.frame.maxX + 8
            frame = rect
            tokenLabel.sizeToFit()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialUI()
    }
    
    fileprivate func initialUI() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(IPaTokenCell.onTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    override var canBecomeFirstResponder : Bool {
        return true
    }
    override func becomeFirstResponder() -> Bool {
        
        let ret = super.becomeFirstResponder()
        refreshColor()
        let menuController = UIMenuController.shared
        let deleteItem = UIMenuItem(title: "刪除", action: #selector(IPaTokenCell.onDeleteToken(_:)))
        menuController.menuItems = [deleteItem]
        menuController.setTargetRect(frame, in: self.superview!)
        menuController.setMenuVisible(true, animated: true)

        return ret
    }
    override func resignFirstResponder() -> Bool {
        
        let ret = super.resignFirstResponder()
        refreshColor()
        return ret
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        return action == #selector(IPaTokenCell.onDeleteToken(_:))
    }
    fileprivate func refreshColor() {
        backgroundColor = isFirstResponder ? _tokenObject.tokenSelectedBackgroundColor() : _tokenObject.tokenBackgroundColor()
        tokenLabel.textColor = isFirstResponder ? _tokenObject.tokenSelectedTextColor() : _tokenObject.tokenTextColor()
    }
    func onTap(_ sender:AnyObject) {

        _ = becomeFirstResponder()
    }
    func onDeleteToken(_ sender:AnyObject) {
        delegate.onDeleteToken(tokenObject)
    }
}
