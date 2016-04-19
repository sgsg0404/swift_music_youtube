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
import Localize_Swift
class FirstViewController: UIViewController ,UIWebViewDelegate {
    
    let dataStore=DataStore.sharedInstance
    var uiv:UIView?
    var a=0,d=0,s=0
    var queue:[String] = [String]()
    
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var statuslbl: UILabel!
    
    @IBOutlet var w: UIWebView!
    var web:UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        statusView.backgroundColor = UIColor.redColor()
        statusView.hidden = true
        self.title = "Youtube"
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
        
        web = UIWebView()

        web.delegate = self;
        
    }
    
    func getStatus()->String{
        if statusView.hidden == true {
            statusView.hidden = false
        }
        return "\("Added".localized()):\(a)   \("Downloading".localized()):\(d)   \("Succeed".localized()):\(s)"
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
            newlink = youtubeLink.stringByReplacingOccurrencesOfString("http://youtu.be/", withString: "http://www.convert2mp3.cc/v/", options: NSStringCompareOptions.LiteralSearch, range: nil)
            print(newlink)
        }else if youtubeLink.rangeOfString("https://m.youtube.com/watch?v=") != nil{
            newlink = youtubeLink.stringByReplacingOccurrencesOfString("https://m.youtube.com/watch?v=", withString: "http://www.convert2mp3.cc/v/", options: NSStringCompareOptions.LiteralSearch, range: nil)
            print(newlink)
        }
        guard let _ = newlink else{
            return;
        }
        a += 1
        self.statuslbl.text = getStatus()

        queue.append(newlink!)

        
        if queue.count == 1{
            let urll = NSURL (string: queue[0]);
            let requestObj2 = NSURLRequest(URL: urll!);
            web.loadRequest(requestObj2);

        }
    }
    
    func downloadWithAlert(link:String){
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
                    //self.showStatus(UIColor.blueColor())
                    print("Downloaded file successfully")
                    self.d -= 1
                    self.s += 1
                    self.statuslbl.text = self.getStatus()
                    dispatch_async(dispatch_get_main_queue()) {
                        NSNotificationCenter.defaultCenter().postNotificationName("loadMp3", object: nil)
                    }
                }
                
        }
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("Webview did finish load")
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "checkDownload:", userInfo: nil, repeats: true)
    }
    
    func checkDownload(s:NSTimer?){
        print("check")
        if let result = web.stringByEvaluatingJavaScriptFromString("document.documentElement.outerHTML") {
            //print(result)
            let matches = matchesForRegexInText("<a class=\"videohref\" href=\".*\"><", text: result)
            if matches.count > 0 {
                var newlink = matches[0].stringByReplacingOccurrencesOfString("<a class=\"videohref\" href=\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                newlink = newlink.stringByReplacingOccurrencesOfString("\"><", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                print(newlink)
                a -= 1
                d += 1
                self.statuslbl.text = getStatus()
                downloadWithAlert(newlink)
                queue.removeAtIndex(0)
                if queue.count > 0{
                    let urll = NSURL (string: queue[0]);
                    let requestObj2 = NSURLRequest(URL: urll!);
                    web.loadRequest(requestObj2); 
                }
                s?.invalidate()
            }
        }

    }
    
    func matchesForRegexInText(regex: String!, text: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matchesInString(text,
                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

}

