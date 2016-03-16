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
            let sss = "https://www.youtubeinmp3.com/fetch/?format=JSON&video=\(link)"
            print("real line:\(sss)")

            dcm.alamoFireManager.request(.GET, sss)
                .responseJSON { response in switch response.result {
                case .Success(_):
                    print("Success with JSON")
                    print(response.result.value!)
                    var data=SwiftyJSON.JSON(response.result.value!)
                    data["success"]="true"

                    resultJSON(data)

                case .Failure(let error):
                    print("Request failed with error: \(error)")
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
    
    
}
