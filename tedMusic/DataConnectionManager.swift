//
//  DataConnectionManager.swift
//  CVI
//
//  Created by Apps Lab Admin on 9/3/2016.
//  Copyright © 2016 CItyUAppsLab. All rights reserved.
//
import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import ReachabilitySwift
public class DataConnectionManager{
    
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
