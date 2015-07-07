//
//  DataStore.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 11/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

enum DataStoreError : ErrorType {
    case FileNotFound(String)
    case FileInvalidContents
    case CannotSerializeDictiory
}

class DataStore {
    
    // throws DataStoreError or a JSON parsing error2
    class func getWithKey(key:String) throws -> NSDictionary {
        let path = filePathForKey(key)
        
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(path) {
            throw DataStoreError.FileNotFound(path)
        }
        
        guard let data = fileManager.contentsAtPath(path) else {
            throw DataStoreError.FileInvalidContents
        }
        
        guard let dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary else {
            throw DataStoreError.FileInvalidContents
        }
        
        return dict
    }

    class func setWithKey(key:String, value:NSDictionary) throws {
        let data = try NSJSONSerialization.dataWithJSONObject(value, options: NSJSONWritingOptions(rawValue: 0))
        
        let fileManager = NSFileManager.defaultManager()
        let path = filePathForKey(key)
        if fileManager.fileExistsAtPath(path) {
            try fileManager.removeItemAtPath(path)
        }
        
        fileManager.createFileAtPath(path, contents: data, attributes: nil)
    }
    
private
    class func filePathForKey(key:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if paths.count == 1 {
            return paths[0].stringByAppendingPathComponent(key)
        }
        return ""
    }
}
