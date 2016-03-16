//
//  FirstViewController.swift
//  tedMusic
//
//  Created by ted on 10/3/16.
//  Copyright © 2016 ted. All rights reserved.
//

import UIKit
import Alamofire
class FirstViewController: UIViewController  {
    
    let dataStore=DataStore.sharedInstance
    
    @IBOutlet var w: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        w.backgroundColor=UIColor.whiteColor()
        do {
            try dataStore.createTables()
            
        } catch _ {}
        let url = NSURL (string: "http://youtube.com");
        let requestObj = NSURLRequest(URL: url!);
        w.loadRequest(requestObj);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

