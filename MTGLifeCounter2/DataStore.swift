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
        
        if let data = fileManager.contentsAtPath(path) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
            } catch let error {
                print("json read error \(error)")
                return nil
            }
        }
        return nil
    }

    class func setWithKey(key:String, value:NSDictionary) {
        let path = filePathForKey(key)
        
        let data: NSData?
        do {
            data = try NSJSONSerialization.dataWithJSONObject(value, options: NSJSONWritingOptions(rawValue: 0))
        } catch let error {
            print("json write error \(error)")
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(path) {
            do {
                try fileManager.removeItemAtPath(path)
            } catch let error {
                print("cannot delete existing file at path \(path); error \(error)")
                return
            }
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
