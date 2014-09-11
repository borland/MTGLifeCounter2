//
//  DataStore.swift
//  MTGLifeCounter2
//
//  Created by Orion Edwards on 11/09/14.
//  Copyright (c) 2014 Orion Edwards. All rights reserved.
//

import Foundation
import UIKit

class DataStore {
    
    class func getWithKey(key:String) -> NSDictionary? {
        let path = filePathForKey(key)
        
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(path) {
            return nil
        }
        
        let data = fileManager.contentsAtPath(path)
        if let x = data {
            var error: NSErrorPointer = nil
            let jsonObject = NSJSONSerialization.JSONObjectWithData(x, options: NSJSONReadingOptions.AllowFragments, error: error) as? NSDictionary
            
            if error != nil {
                println("json read error \(error)")
                return nil
            }
            return jsonObject
        }
        return nil
    }

    class func setWithKey(key:String, value:NSDictionary) {
        let path = filePathForKey(key)
        
        var error: NSErrorPointer = nil
        let data = NSJSONSerialization.dataWithJSONObject(value, options: NSJSONWritingOptions(0), error: error)
        
        if error != nil {
            println("json write error \(error)")
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(path) {
            fileManager.removeItemAtPath(path, error: error)
            if error != nil {
                println("cannot delete existing file at path \(path); error \(error)")
                return
            }
        }
        
        fileManager.createFileAtPath(path, contents: data, attributes: nil)
    }
    
private
    class func filePathForKey(key:String) -> String {
        let rootPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        return rootPath.stringByAppendingPathComponent(key)
    }
}
