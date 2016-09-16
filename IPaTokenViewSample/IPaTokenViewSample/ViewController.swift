//
//  ViewController.swift
//  IPaTokenViewSample
//
//  Created by IPa Chen on 2016/5/31.
//  Copyright © 2016年 AMagicStudio. All rights reserved.
//

import UIKit
import IPaTokenView
class ViewController: UIViewController,IPaTokenViewDelegate {

    @IBOutlet var tokenView: IPaTokenView!
    var tokens = [String:TestTokenObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tokenView.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: IPaTokenViewDelegate
    func tokenObjectForName(token:String) -> IPaTokenObject
    {
        if let object = tokens[token] {
            return object
        }
        let newObject = TestTokenObject()
        newObject.token = token
        tokens[token] = newObject
        return newObject
    }
    func tokenViewDidBeginEditing(tokenView:IPaTokenView)
    {
        
    }
}

