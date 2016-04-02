//
//  SQLiteDataStore.swift
//  CVI
//
//  Created by ted on 5/3/16.
//  Copyright © 2016 CItyUAppsLab. All rights reserved.
//

import Foundation
import SQLite
import UIKit
import Alamofire
import AVFoundation
enum DataAccessError: ErrorType {
    case Datastore_Connection_Error
    case Insert_Error
    case Delete_Error
    case Search_Error
    case Nil_In_Data
}



class DataStore {
    let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
    static let sharedInstance = DataStore()
    var sqlCreated:Bool=false
    let BBDB: Connection?
    var dir:NSString?
    let fileManager = NSFileManager.defaultManager()
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    
    private init() {
        configuration.timeoutIntervalForRequest = 5 // seconds
        configuration.timeoutIntervalForResource = 5
        var path = "cvi.sqlite"
        
        if let dirs: [NSString] =
            NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
                NSSearchPathDomainMask.AllDomainsMask, true) as [NSString] {
                    
                    dir = dirs[0]
                    path = dir!.stringByAppendingPathComponent("cvi.sqlite");
                    print(path)
        }
        
        do {
            if(fileManager.fileExistsAtPath(path)){
                sqlCreated=true
            }
            
            BBDB = try Connection(path)
        } catch _ {
            BBDB = nil
        }
    }
    
    
    func createTables() throws{
        guard sqlCreated==false else{
            return;
        }
        print("create tables")
        do {
            try BookmarkDataHelper.createTable()
            try IndustryDataHelper.createTable()
            try AdditiveDataHelper.createTable()
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
        
    }
    
    func clear() throws{
        do {
            try BookmarkDataHelper.clearTable()
            try IndustryDataHelper.clearTable()
            try AdditiveDataHelper.clearTable()
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
        
    }
    
    func checkTime(pathString:String)->Float64{
        let asset = AVURLAsset(URL: NSURL(fileURLWithPath: pathString), options: nil)
        let audioDuration = asset.duration
        let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        return audioDurationSeconds
    }
    
    func checkFileExist(fileName:String)->Bool{
        let path=dir!.stringByAppendingPathComponent(fileName)
        if fileManager.fileExistsAtPath(path){
            return true
        }
        return false
    }
    
    func getPathByFileName(fileName:String)->String{
        let path=dir!.stringByAppendingPathComponent(fileName)
        return path
    }
    
    func removeFile(fileName:String){
        let path=dir!.stringByAppendingPathComponent(fileName)
        do{
            try fileManager.removeItemAtPath(path)
            print("removed a file")
        }catch _{
            print("can't remove file")
        }
    }
    
    func handleBookmarkNumber(tbc:UITabBarController){
        let tabArray = tbc.tabBar.items as NSArray!
        let tabItem = tabArray.objectAtIndex(2) as! UITabBarItem
        do{
            let num = try BookmarkDataHelper.count()
            guard num > 0 else{
                tabItem.badgeValue = nil
                return
            }
            tabItem.badgeValue = "\(num)"
        }catch _{}
    }
    
    
    
    func removeAllFiles(){
        let files=NSFileManager().enumeratorAtPath(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.AllDomainsMask, true)[0])
        while let file = files?.nextObject(){
            let fileName = "\(file)"
            if fileName.rangeOfString(".pdf") != nil {
                removeFile(fileName)
            }
        }
    }
    
}


