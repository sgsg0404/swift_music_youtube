//
//  FirstViewController.swift
//  tedMusic
//
//  Created by ted on 10/3/16.
//  Copyright © 2016 ted. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class FirstViewController: UIViewController  {
    
    let dataStore=DataStore.sharedInstance
    var uiv:UIView?
    @IBOutlet var w: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController!.navigationBar.tintColor=UIColor.redColor()
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reload")
        self.navigationItem.leftBarButtonItem=UIBarButtonItem(barButtonSystemItem: .Reply, target: self, action: "back")
        w.backgroundColor=UIColor.whiteColor()
        do {
            try dataStore.createTables()
            
        } catch _ {}
        let url = NSURL (string: "http://youtube.com");
        let requestObj = NSURLRequest(URL: url!);
        w.loadRequest(requestObj);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pastechanged:"), name: UIPasteboardChangedNotification, object: nil)
        self.title = "!23"
        
    }
    
    func showStatus(color : UIColor){
        uiv?.removeFromSuperview()
        uiv = UIView(frame: CGRect(origin: CGPoint(x: (navigationController!.view.frame.size.width-(tabBarController!.tabBar.frame.width*0.6))/2, y:navigationController!.view.frame.minY), size: CGSize(width: tabBarController!.tabBar.frame.width*0.6, height: self.navigationController!.navigationBar.frame.maxY)))
        uiv!.backgroundColor = color
        navigationController!.view.addSubview(uiv!)
        
    }
    
    func pastechanged(sender : NSNotification){
        print("copy")
        if let theString = UIPasteboard.generalPasteboard().string {
            print("String is \(theString)")
            sendRequest(theString)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reload(){
        w.reload()
    }
    func back(){
        w.goBack()
    }
    
    func sendRequest(youtubeLink:String){
        var newlink:String?
        if youtubeLink.rangeOfString("http://youtu.be/") != nil{
            newlink = youtubeLink.stringByReplacingOccurrencesOfString("http://youtu.be/", withString: "https://www.youtube.com/watch?v=", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }else if youtubeLink.rangeOfString("https://m.youtube.com/watch?v=") != nil{
            newlink = youtubeLink.stringByReplacingOccurrencesOfString("https://m.youtube.com/watch?v=", withString: "https://www.youtube.com/watch?v=", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        guard let _ = newlink else{
            return;
        }
        DataConnectionManager.getJSON("loadData",link:newlink!,nc: self.navigationController!, resultJSON: { (result: JSON) -> Void in
            print(result)
            guard result["success"] == "true" else{
                
                return
            }
            self.showStatus(UIColor.redColor())
            print("success")
            self.downloadWithAlert(result["link"].stringValue)
        })
        
    }
    
    
    private func downloadWithAlert(link:String){
        let newString = link.stringByReplacingOccurrencesOfString("http", withString: "https", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        Alamofire.download(.GET, newString, destination: DataStore.sharedInstance.destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                dispatch_async(dispatch_get_main_queue()) {
                }
            }
            .response { request, response, _, error in
                
                if let error = error {
                    print("Failed with error: \(error)")
                } else {
                    self.showStatus(UIColor.blueColor())
                    print("Downloaded file successfully")
                    
                }
                
        }
        
    }
    
    
}

