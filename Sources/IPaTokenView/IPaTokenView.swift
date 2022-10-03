//
//  IPaTokenView.swift
//  IPaTokenView
//
//  Created by IPa Chen on 2016/5/29.
//  Copyright © 2016年 AMagicStudio. All rights reserved.
//

import UIKit
protocol IPaCatchDeleteTextFieldDelegate: UITextFieldDelegate
{
    func onDeleteKeyInput(_ textField:IPaCatchDeleteTextField)
}
open class IPaCatchDeleteTextField: UITextField {
    var catchDeleteDelegate:IPaCatchDeleteTextFieldDelegate?
    override open var delegate: UITextFieldDelegate? {
        get {
            return super.delegate
        }
        set {
            super.delegate = newValue
            catchDeleteDelegate = newValue as? IPaCatchDeleteTextFieldDelegate
        }
    }
    func keyboardInputShouldDelete(_ textField:UITextField) -> Bool {
        
        catchDeleteDelegate?.onDeleteKeyInput(self)
        return true
    }
}

@objc public protocol IPaTokenObject {
    func tokenName() -> String
    func tokenBackgroundColor() -> UIColor
    func tokenTextColor() -> UIColor
    func tokenSelectedBackgroundColor() -> UIColor
    func tokenSelectedTextColor() -> UIColor
    
}
@objc public protocol IPaTokenViewDelegate {
    func tokenViewObjectForName(_ tokenView:IPaTokenView,token:String) -> IPaTokenObject?
    @objc optional func tokenViewDidBeginEditing(_ tokenView:IPaTokenView)
    @objc optional func tokenViewDidEndEditing(_ tokenView:IPaTokenView)
    @objc optional func tokenViewDidEditing(_ tokenView:IPaTokenView,inputToken:String)
    @objc optional func tokenViewOnTokenRefreshed(_ tokenView:IPaTokenView)
    @objc optional func tokenViewOnSelectToken(_ tokenView:IPaTokenView)
    @objc optional func tokenViewOnShowTokenList(_ tokenView:IPaTokenView)
    @objc optional func tokenViewOnTokenDeleted(_ tokenView:IPaTokenView,token:String)
    @objc optional func tokenViewOnTokenAdded(_ tokenView:IPaTokenView,token:String)
}
@objc open class IPaTokenView: UIView ,IPaCatchDeleteTextFieldDelegate {
    @objc open var delegate:IPaTokenViewDelegate!
    open var font:UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            for cell in tokenCells.values {
                cell.tokenLabel.font = self.font
                cell.reloadSize()
            }
        }
    }
    open var isEditable = true {
        didSet {
            tokenInputField.isHidden = !isEditable
            addTokenButton.isHidden = !isEditable || self._hideAddTokenButton
            repositionUI()
        }
    }
    open var contentInsect:UIEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    open var cellInset:UIEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    open var cellHeight:CGFloat = 30
    open var cellCornerRadius:CGFloat = 4
    lazy var contentScrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        let viewsDict:[String:UIView] = ["view": scrollView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",options:NSLayoutConstraint.FormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",options:NSLayoutConstraint.FormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        scrollView.scrollsToTop = false
        return scrollView
    
    }()
    
    lazy var titleLabel:UILabel = {
    
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = true
        self.contentScrollView.addSubview(label)
        label.autoresizingMask = [.flexibleRightMargin,.flexibleBottomMargin]
        
        return label
        
    }()
    open lazy var tokenInputField:IPaCatchDeleteTextField = {
        
        let inputField = IPaCatchDeleteTextField()
        inputField.translatesAutoresizingMaskIntoConstraints = true
        inputField.delegate = self
        inputField.addTarget(self, action: #selector(IPaTokenView.onInputFieldChanged(_:)), for: .editingChanged)
        inputField.returnKeyType = .done
        self.contentScrollView.addSubview(inputField)
        return inputField
    
    }()
    
    lazy var addTokenButton:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.contactAdd)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.addTarget(self, action: #selector(IPaTokenView.onShowTokenList(_:)), for: .touchUpInside)
        self.contentScrollView.addSubview(button)
        
        return button
    
    }()
    var _hideAddTokenButton = false
    open var hideAddTokenButton:Bool {
        get {
            return self.isEditable || _hideAddTokenButton
        }
        set {
            _hideAddTokenButton = newValue
            addTokenButton.isHidden = newValue
            repositionUI()
        }
    }
    var tokenCells = [String:IPaTokenCell]()
    open var tokens = [String]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        repositionUI()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        repositionUI()
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        repositionUI()
    }
    fileprivate func repositionUI() {
        //title label
        var rect = titleLabel.frame
        rect.origin.x = contentInsect.left
        rect.origin.y = contentInsect.top
        rect.size.height = cellHeight
        titleLabel.frame = rect
        
        //token
        var currentX = titleLabel.frame.maxX + cellInset.left
        var currentY = titleLabel.frame.origin.y
        for token in tokens {
            guard let cell = tokenCells[token] else {
                continue
            }
            var cellRect = cell.frame
            cellRect.size.height = cellHeight
            cellRect.origin.x = currentX
            cellRect.origin.y = currentY + cellInset.top
            if cellRect.maxX + cellInset.right > bounds.width - contentInsect.right {
                cellRect.origin.x = titleLabel.frame.maxX + cellInset.left
                currentY = currentY + cellHeight + cellInset.bottom
                cellRect.origin.y = currentY + cellInset.top
            }
            currentX = cellRect.maxX + cellInset.left + cellInset.right
            cell.frame = cellRect
        }
        //textField , addButton
        var endPositionX = contentInsect.right
        if hideAddTokenButton {
            endPositionX = contentInsect.right
        }
        else {
            var buttonRect = addTokenButton.frame
            buttonRect.origin.x = bounds.width - contentInsect.right - buttonRect.width
            buttonRect.origin.y = tokenInputField.center.y - (buttonRect.height * 0.5)
            addTokenButton.frame = buttonRect
            endPositionX = contentInsect.right + 3 + addTokenButton.bounds.width
            
        }
        if bounds.width - currentX < bounds.width * 0.5 {
            currentY = currentY + cellHeight + cellInset.bottom
            currentX = titleLabel.frame.maxX
        }
        rect = tokenInputField.frame
        rect.origin.x = currentX
        rect.origin.y = currentY + cellInset.top
        rect.size.height = cellHeight
        rect.size.width = bounds.width - endPositionX - currentX
        tokenInputField.frame = rect
      
        
        let originalHeight = contentScrollView.contentSize.height
        contentScrollView.contentSize = CGSize(width: bounds.width, height: tokenInputField.frame.maxY + cellInset.bottom + contentInsect.bottom)
        if let superview = superview , originalHeight != contentScrollView.contentSize.height {
            delegate.tokenViewOnTokenRefreshed?(self)
            UIView.animate(withDuration: 0.3, animations: {
                self.invalidateIntrinsicContentSize()
                superview.layoutIfNeeded()
            })
            
        }
    }
    override open var intrinsicContentSize : CGSize {
        return contentScrollView.contentSize
    }
    @objc fileprivate func onShowTokenList(_ sender:AnyObject) {
        delegate.tokenViewOnShowTokenList?(self)
    }
    open func replaceTokens(_ addTokens:[String]) {
        tokens.removeAll()
        for (_,cell) in tokenCells {
            cell.removeFromSuperview()
        }
        tokenCells.removeAll()
        tokenInputField.text = ""
        for token in addTokens {
            guard let tokenObject = delegate.tokenViewObjectForName(self,token:token) else {
                continue
            }
            tokens.append(token)
            let cell = IPaTokenCell()
            cell.translatesAutoresizingMaskIntoConstraints = true
            cell.tokenLabel.font = self.font
            cell.tokenObject = tokenObject
            cell.layer.cornerRadius = self.cellCornerRadius
            cell.delegate = self
            
            tokenCells[token] = cell
            contentScrollView.addSubview(cell)
        }
        repositionUI()
    }
    open func removeAllTokens() {
        tokens.removeAll()
        for (_,cell) in tokenCells {
            cell.removeFromSuperview()
        }
        tokenCells.removeAll()
        repositionUI()
    }
    open func addToken(_ token:String) {
        tokenInputField.text = ""
        delegate.tokenViewDidEditing?(self, inputToken: "")
        if let _ = tokenCells[token] ,let _ = tokens.firstIndex(of: token) {
            return
        }
        guard let tokenObject = delegate.tokenViewObjectForName(self,token:token) else {
            return
        }
        tokens.append(token)
        let cell = IPaTokenCell()
        cell.translatesAutoresizingMaskIntoConstraints = true
        cell.tokenLabel.font = self.font
        cell.tokenObject = tokenObject
        cell.layer.cornerRadius = self.cellCornerRadius
        cell.delegate = self
        
        tokenCells[token] = cell
        contentScrollView.addSubview(cell)
        repositionUI()
        
        delegate.tokenViewOnTokenAdded?(self, token: token)
    }
    func deleteToken(_ tokenObject:IPaTokenObject) {
        let token = tokenObject.tokenName()
        guard let cell = tokenCells[token] ,let index = tokens.firstIndex(of: token) else {
            return
        }
        cell.removeFromSuperview()
        tokens.remove(at: index)
        tokenCells.removeValue(forKey: token)
        repositionUI()
    }
    func onDeleteSelectedToken(_ sender:AnyObject) {
        
    }
    func selectedTokenCell() -> IPaTokenCell? {
        for cell in tokenCells.values {
            if cell.isFirstResponder {
                return cell
            }
        }
        return nil
    }
    @objc func onInputFieldChanged(_ sender:AnyObject) {
        guard let text = tokenInputField.text else {
            delegate.tokenViewDidEditing?(self, inputToken: "")
            return
        }
        delegate.tokenViewDidEditing?(self, inputToken: text)
    }
    //MARK: UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate.tokenViewDidBeginEditing?(self)
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate.tokenViewDidEndEditing?(self)
    }
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 0 && string.count == 0 {
            onDeleteKeyInput(textField as! IPaCatchDeleteTextField)
        }
      
        
        return true
    }
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text , text.count > 0 {
            
            addToken(text)
            
        }
        else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    //MARK: IPaCatchDeleteTextFieldDelegate
    
    func onDeleteKeyInput(_ textField:IPaCatchDeleteTextField) {
        if textField.text?.count == 0 {
            //select last token
            if let selectedCell = selectedTokenCell() {
                deleteToken(selectedCell.tokenObject)
            }
            else {
                guard let lastToken = tokens.last ,let cell = tokenCells[lastToken] else {
                    return
                }
                _ = cell.becomeFirstResponder()
                
            }
        }
    }
    
    
}
extension IPaTokenView:IPaTokenCellDelegate
{
    func onDeleteToken(_ tokenObject:IPaTokenObject)
    {
        deleteToken(tokenObject)
        delegate.tokenViewOnTokenDeleted?(self, token: tokenObject.tokenName())
    }
    func shouldBecomeFirstResponder() -> Bool {
        return isEditable
    }
}
