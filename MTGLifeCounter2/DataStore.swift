//
//  DataStore.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 11/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

enum DataStoreError : Error {
    case fileNotFound(String)
    case fileInvalidContents
    case cannotSerializeDictiory
}

class DataStore {
    
    // throws DataStoreError or a JSON parsing error2
    class func getWithKey(_ key:String) throws -> NSDictionary {
        let path = filePathForKey(key)
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            throw DataStoreError.fileNotFound(path)
        }
        
        guard let data = fileManager.contents(atPath: path) else {
            throw DataStoreError.fileInvalidContents
        }
        
        guard let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary else {
            throw DataStoreError.fileInvalidContents
        }
        
        return dict
    }

    class func setWithKey(_ key:String, value:NSDictionary) throws {
        let data = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions(rawValue: 0))
        
        let fileManager = FileManager.default
        let path = filePathForKey(key)
        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(atPath: path)
        }
        
        fileManager.createFile(atPath: path, contents: data, attributes: nil)
    }
    
private
    class func filePathForKey(_ key:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if paths.count == 1 {
            if let url = URL(string: paths[0]) {
                return url.appendingPathComponent(key).absoluteString
            }
        }
        return ""
    }
}
