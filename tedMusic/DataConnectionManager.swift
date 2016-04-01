//
//  DataConnectionManager.swift
//  CVI
//
//  Created by Apps Lab Admin on 9/3/2016.
//  Copyright © 2016 CItyUAppsLab. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import ReachabilitySwift
public class DataConnectionManager {
    
    static let sharedInstance = DataConnectionManager()
    var reachability: Reachability?
    var alamoFireManager:Manager!
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    let restfulAPI = "https://cvi.azurewebsites.net/php/"
    
    private init() {
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        alamoFireManager = Alamofire.Manager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
        }
    }
    
    public class func getJSON(AppModule:String,link:String,nc:UINavigationController, resultJSON:(SwiftyJSON.JSON) -> Void) -> Void {
        let dcm = DataConnectionManager.sharedInstance
        
        guard dcm.checkReachable()==true else{
            dcm.alertNetworkError(nc)
            resultJSON(JSON(["success":"false"]))
            return
        }
        
        switch(AppModule) {
            
        case "loadData":
            let sss = link
            print("real line:\(link)")         
            dcm.alamoFireManager.request(.GET, sss)
                .responseString { response in
                    print("Success: \(response.result.isSuccess)")
                    //print("Response String: \(response.result.value)")
                    let matches = dcm.matchesForRegexInText("(\\{\"status\":\"ok\".*\\}, \\{)", text: response.result.value)
                    let newlink = matches[0].stringByReplacingOccurrencesOfString(", {", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    if let dataFromString = newlink.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        var json = SwiftyJSON.JSON(data: dataFromString)
                        print(json["id"])
                        json["success"] = "true"
                        resultJSON(json)
                    }
                    
                    
            }
            
            break
            
        default:
            break
            
        }
    }
    
    func checkReachable()->Bool{
        if reachability!.currentReachabilityStatus.description == "No Connection" {
            return false
        }
        return true
    }
    
    func alertNetworkError(nc:UINavigationController){
        AlertViewController.sharedInstance.showAlert(nc, displayTitle: "No Network Connection")
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
