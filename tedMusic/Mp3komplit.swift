//
//  Mp3komplit.swift
//  m
//
//  Created by ted on 23/4/16.
//  Copyright © 2016 ted. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct data {
    var name:String?
    var link:String?
}

class Mp3komplit:UITableViewController{
    
    var datas=[data]()
    
    override func viewDidLoad() {
        Alamofire.request(.GET, "http://mp3komplit.net/site_search.xhtml?get-q=1&get-type=mp3")
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
                let matches = FirstViewController.matchesForRegexInText("<strong><a  title=\"(.*?)</a></strong>", text: response.result.value)
                print(matches)
                print(matches.count)
                for(var i=0;i<matches.count;i++){
                    let m=FirstViewController.matchesForRegexInText("\".*?\"", text: matches[i])
                    self.datas.append(data(name: m[0].stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("Download ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil), link: m[1].stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)))
                    
                    
                }
                self.tableView.reloadData()
                
        }
        
        
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("mp3Cell")! as UITableViewCell
        cell.textLabel?.text = datas[indexPath.row].name
        
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        download(datas[indexPath.row].link!)
    }
    
    func download(link:String){
        print(link)
        let link2 = link.stringByReplacingOccurrencesOfString("/site_view_detile.xhtml?", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let escapedString = link2.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        print("escapedString: \(escapedString)")
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "http://mp3komplit.net/site_view_detile.xhtml?"+escapedString!)!)
        mutableURLRequest.HTTPMethod = "POST"
        mutableURLRequest.setValue("text/html; charset=utf-8", forHTTPHeaderField: "Content-Type")
        Alamofire.request(mutableURLRequest)
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                //print("Response String: \(response.result.value)")
                let matches = FirstViewController.matchesForRegexInText("<form.*?[POST].*?form>", text: response.result.value)
                print(matches)
                let m=FirstViewController.matchesForRegexInText("\".*?\"", text: matches[0])
                print(m)
                self.downloadWithAlert(m[0].stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil))
        }
        
    }
    
    func downloadWithAlert(link:String){
        
        Alamofire.download(.GET, "http://mp3komplit.net"+link, destination: DataStore.sharedInstance.destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                dispatch_async(dispatch_get_main_queue()) {
                    print(bytesRead)
                }
            }
            .response { request, response, _, error in
                
                if let error = error {
                    print("Failed with error: \(error)")
                } else {
                    //self.showStatus(UIColor.blueColor())
                    print("Downloaded file successfully")
                    dispatch_async(dispatch_get_main_queue()) {
                        NSNotificationCenter.defaultCenter().postNotificationName("loadMp3", object: nil)
                    }
                }
                
        }
        
    }
}
