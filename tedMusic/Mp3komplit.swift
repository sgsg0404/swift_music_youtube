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
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
class Mp3komplit:UITableViewController, UISearchBarDelegate{
    
    let recognizer = UITapGestureRecognizer()
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchKey = ""
    var pageNum  = 1
    var datas=[data]()
    var uiv:UIView!
    var uiv2:UIView!
    var a=0,d=0,s=0
    override func viewDidLoad() {
        uiv = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 50))
        //uiv.backgroundColor = UIColor(netHex: 0x98DBC6)
        uiv.hidden = true
        uiv2 = UIView(frame: CGRectMake(0, searchBar.frame.maxY, tableView.frame.size.width, 50))
        uiv2.backgroundColor = UIColor(netHex: 0x375E97)
        uiv2.hidden = true
        let loadingIndicator2: UILabel = UILabel(frame: CGRectMake(uiv2.frame.height/2, 10, tableView.frame.size.width, 37))
        loadingIndicator2.textColor = UIColor.whiteColor()
        loadingIndicator2.text = "NotFound".localized()
        //loadingIndicator2.center = uiv2.center
        uiv2.addSubview(loadingIndicator2)
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(50, 10, 37, 37))
        loadingIndicator.center = uiv.center
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        loadingIndicator.color = UIColor(netHex: 0x375E97)
        loadingIndicator.hidesWhenStopped = true
        uiv.addSubview(loadingIndicator)
        loadingIndicator.startAnimating();
        tableView.tableFooterView = uiv
        tableView.addSubview(uiv2)
        searchBar.delegate = self
        searchBar.barTintColor = UIColor(netHex: 0x375E97)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(netHex: 0x375E97)]
    }
    
    func getStatus()->String{
        return "\("Added".localized()):\(a)   \("Downloading".localized()):\(d)   \("Succeed".localized()):\(s)"
    }
    
    //search bar
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar){
        recognizer.addTarget(self, action: "handleTap:")
        view.addGestureRecognizer(recognizer)
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        view .removeGestureRecognizer(recognizer)
        
        guard searchKey != "" else {
            return
        }
        datas.removeAll()
        self.tableView.reloadData()
        pageNum = 1
        loadPage()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchKey = searchText.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
    }
    //end search bar
    
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("mp3Cell")! as UITableViewCell
        cell.textLabel?.text = datas[indexPath.row].name
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor(netHex: 0x375E97)
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        download(datas[indexPath.row].link!)
    }
    
    func download(link:String){
        a += 1;
        self.navigationItem.title = getStatus();
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
                
                let m=FirstViewController.matchesForRegexInText("\".*?\"", text: matches[0])
                
                self.downloadWithAlert(m[0].stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil))
        }
        
    }
    
    func loadPage(){
        print("loading page:\(pageNum)")
        guard pageNum >= 0 else {
            return
        }
        self.uiv.hidden = false
        self.uiv2.hidden = true
        Alamofire.request(.GET, "http://mp3komplit.net/site_search.xhtml?get-q=\(searchKey)&get-type=mp3&get-page=\(pageNum)")
            .responseString { response in
                let matches = FirstViewController.matchesForRegexInText("<strong><a  title=\"(.*?)</a></strong>", text: response.result.value)
                print(matches.count)
                self.uiv.hidden = true
                
                guard matches.count > 0 else{
                    if(self.pageNum==1){
                        self.uiv2.hidden = false
                    }
                    self.pageNum = -1
                    self.uiv.hidden = true
                    
                    return
                }
                for(var i=0;i<matches.count;i++){
                    let m=FirstViewController.matchesForRegexInText("\".*?\"", text: matches[i])
                    self.datas.append(data(name: m[0].stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("Download ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("Lagu ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil), link: m[1].stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)))
                    
                    
                }
                self.tableView.reloadData()
                
        }
    }
    
    func downloadWithAlert(link:String){
        var localPath: NSURL?
        a -= 1;
        d += 1;
        self.navigationItem.title = getStatus();
        Alamofire.download(.GET, "http://mp3komplit.net"+link, destination: { (temporaryURL, response) in
            let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let pathComponent = response.suggestedFilename!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            print(pathComponent)
            localPath = directoryURL.URLByAppendingPathComponent(pathComponent)
            return localPath!
            
        })            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
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
                        self.d -= 1;
                        self.s += 1;
                        self.navigationItem.title = self.getStatus();
                    }
                }
                
        }
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard pageNum > 0 else {
            
            return
        }
        if(datas.count-1 == indexPath.row){
            pageNum = pageNum + 1
            loadPage()
        }
    }
}
