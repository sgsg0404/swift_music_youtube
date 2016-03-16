//
//  DataHelper.swift
//  CVI
//
//  Created by ted on 5/3/16.
//  Copyright © 2016 CItyUAppsLab. All rights reserved.
//

import Foundation
import SQLite
import Alamofire

protocol DataHelperProtocol {
    typealias T
    static func createTable() throws -> Void
    static func insert(item: T) throws -> Int64
    static func delete(item: T) throws -> Void
    static func findAll() throws -> [T]?
}


class BookmarkDataHelper: DataHelperProtocol {
    static let TABLE_NAME = "Bookmarks"
    
    static let bookmarkId = Expression<Int64>("bookmarkId")
    static let additiveId = Expression<Int64>("additiveId")
    
    static let table = Table(TABLE_NAME)
    
    typealias T = Bookmark
    
    static func createTable() throws {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            _ = try DB.run( table.create(ifNotExists: true) {t in
                
                t.column(bookmarkId, primaryKey: true)
                t.column(additiveId, unique: true)
                })
        } catch _ {
            // Error thrown when table exists
        }
    }
    
    static func clearTable() throws {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
            let query = table.filter(bookmarkId > 0)
            do {
                try DB.run(query.delete())
            } catch _ {
                throw DataAccessError.Delete_Error
            }
        
    }
    
    static func insert(item: T) throws -> Int64 {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if (item.additiveId != nil) {
            let insert = table.insert(additiveId <- item.additiveId!)
            do {
                let rowId = try DB.run(insert)
                guard rowId >= 0 else {
                    throw DataAccessError.Insert_Error
                }
                return rowId
            } catch _ {
                throw DataAccessError.Insert_Error
            }
        }
        throw DataAccessError.Nil_In_Data
    }
    
    static func delete (item: T) throws -> Void {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if let id = item.additiveId {
            let query = table.filter(additiveId == id)
            do {
                let tmp = try DB.run(query.delete())
                guard tmp == 1 else {
                    throw DataAccessError.Delete_Error
                }
            } catch _ {
                throw DataAccessError.Delete_Error
            }
        }
        
    }
    
    static func find(id: Int64) throws -> T? {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(additiveId == id)
        let items = try DB.prepare(query)
        for item in  items {
            return Bookmark(bookmarkId: item[bookmarkId], additiveId: item[additiveId])
        }
        
        return nil
        
    }
    
    
    static func findAllId() throws -> [Int64]? {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray:[Int64] = []
        let items = try DB.prepare(table)
        for item in items {
            retArray.append(item[additiveId])
        }
        
        return retArray
    }
    
    static func findAll() throws -> [T]? {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        let items = try DB.prepare(table)
        for item in items {
            retArray.append(Bookmark(bookmarkId: item[bookmarkId], additiveId: item[additiveId]))
        }
        
        return retArray
    }
    
    static func count() throws -> Int{
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        return DB.scalar(table.count)
    }
    
}

class IndustryDataHelper: DataHelperProtocol {
    static let TABLE_NAME = "Industries"
    
    static let type_id = Expression<Int64>("type_id")
    static let type_name_cn = Expression<String?>("type_name_cn")
    static let type_name_eng = Expression<String?>("type_name_eng")
    static let parent_type_id = Expression<Int64>("parent_type_id")
    static let super_type_id = Expression<Int64>("super_type_id")
    
    static let table = Table(TABLE_NAME)
    
    typealias T = Industry
    
    static func createTable() throws {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            _ = try DB.run( table.create(ifNotExists: true) {t in
                
                t.column(type_id, primaryKey: true)
                t.column(type_name_cn)
                t.column(type_name_eng)
                t.column(parent_type_id)
                t.column(super_type_id)
                })
            
        } catch _ {
            // Error thrown when table exists
        }
    }
    
    static func clearTable() throws {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(type_id > 0)
        do {
             try DB.run(query.delete())
        } catch _ {
            throw DataAccessError.Delete_Error
        }
    }
    
    static func insert(item: T) throws -> Int64 {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if (item.type_id != nil) {
            let insert = table.insert(type_id <- item.type_id!,type_name_cn <- item.type_name_cn!,type_name_eng <- item.type_name_eng!,parent_type_id <- item.parent_type_id!,super_type_id <- item.super_type_id!)
            do {
                let rowId = try DB.run(insert)
                guard rowId >= 0 else {
                    throw DataAccessError.Insert_Error
                }
                return rowId
            } catch _ {
                throw DataAccessError.Insert_Error
            }
        }
        throw DataAccessError.Nil_In_Data
    }
    
    static func delete (item: T) throws -> Void {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if let id = item.type_id {
            let query = table.filter(type_id == id)
            do {
                let tmp = try DB.run(query.delete())
                guard tmp == 1 else {
                    throw DataAccessError.Delete_Error
                }
            } catch _ {
                throw DataAccessError.Delete_Error
            }
        }
        
    }
    
    static func find(id: Int64) throws -> T? {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(type_id == id)
        let items = try DB.prepare(query)
        for item in  items {
            return Industry(type_id: item[type_id], type_name_cn: item[type_name_cn], type_name_eng: item[type_name_eng], parent_type_id: item[parent_type_id], super_type_id: item[super_type_id])
        }
        
        return nil
        
    }
    
    static func findAll() throws -> [T]? {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        let items = try DB.prepare(table)
        for item in items {
            retArray.append(Industry(type_id: item[type_id], type_name_cn: item[type_name_cn], type_name_eng: item[type_name_eng], parent_type_id: item[parent_type_id], super_type_id: item[super_type_id]))
        }
        
        return retArray
    }
    
}

class AdditiveDataHelper: DataHelperProtocol {
    static let TABLE_NAME = "Additives"
    
    static let additive_id = Expression<Int64>("additive_id")
    static let additive_name = Expression<String?>("additive_name")
    static let additive_cn_desc = Expression<String?>("additive_cn_desc")
    static let additive_eng_desc = Expression<String?>("additive_eng_desc")
    
    static let table = Table(TABLE_NAME)
    
    typealias T = Additive
    
    static func createTable() throws {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            _ = try DB.run( table.create(ifNotExists: true) {t in
                
                t.column(additive_id, primaryKey: true)
                t.column(additive_name)
                t.column(additive_cn_desc)
                t.column(additive_eng_desc)
                })
            
        } catch _ {
            // Error thrown when table exists
        }
    }
    
    static func clearTable() throws {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(additive_id > 0)
        do {
            try DB.run(query.delete())
        } catch _ {
            throw DataAccessError.Delete_Error
        }
    }
    
    static func insert(item: T) throws -> Int64 {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if (item.additive_id != nil) {
            let insert = table.insert(additive_id <- item.additive_id!,additive_name <- item.additive_name!,additive_cn_desc <- item.additive_cn_desc!,additive_eng_desc <- item.additive_eng_desc!)
            do {
                let rowId = try DB.run(insert)
                guard rowId >= 0 else {
                    throw DataAccessError.Insert_Error
                }
                return rowId
            } catch _ {
                throw DataAccessError.Insert_Error
            }
        }
        throw DataAccessError.Nil_In_Data
    }
    
    static func delete (item: T) throws -> Void {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if let id = item.additive_id {
            let query = table.filter(additive_id == id)
            do {
                let tmp = try DB.run(query.delete())
                guard tmp == 1 else {
                    throw DataAccessError.Delete_Error
                }
            } catch _ {
                throw DataAccessError.Delete_Error
            }
        }
        
    }
    
    static func find(id: Int64) throws -> T? {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(additive_id == id)
        let items = try DB.prepare(query)
        for item in  items {
            return Additive(additive_id: item[additive_id], additive_name: item[additive_name], additive_cn_desc: item[additive_cn_desc], additive_eng_desc: item[additive_eng_desc])
        }
        
        return nil
        
    }
    
    static func findFav(bk:[Int64]) throws -> [T]? {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query=table.filter(bk.contains(additive_id))
        var retArray = [T]()
        let items = try DB.prepare(query)
        for item in items {
            retArray.append(Additive(additive_id: item[additive_id], additive_name: item[additive_name], additive_cn_desc: item[additive_cn_desc], additive_eng_desc: item[additive_eng_desc]))
        }
        
        return retArray
        
    }
    
    static func findAll() throws -> [T]? {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        let items = try DB.prepare(table)
        for item in items {
            retArray.append(Additive(additive_id: item[additive_id], additive_name: item[additive_name], additive_cn_desc: item[additive_cn_desc], additive_eng_desc: item[additive_eng_desc]))
        }
        
        return retArray
    }
    
    static func findAllForDictionary() throws -> [Dictionary<String,Any>]? {
        guard let DB = DataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        var retArrayDict = [Dictionary<String,Any>]()
        let items = try DB.prepare(table)
        for item in items {
            var retDict = Dictionary<String,Any>()
            retDict[AdditiveDict.additive_id.rawValue]=item[additive_id]
            retDict[AdditiveDict.additive_name.rawValue]=item[additive_name]
            retDict[AdditiveDict.additive_cn_desc.rawValue]=item[additive_cn_desc]
            retDict[AdditiveDict.additive_eng_desc.rawValue]=item[additive_eng_desc]
            retArrayDict.append(retDict)
        }
        
        return retArrayDict
    }


    
}


