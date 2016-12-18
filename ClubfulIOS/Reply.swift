//
//  Reply.swift
//  ClubfulIOS
//
//  Created by guanho on 2016. 11. 26..
//  Copyright © 2016년 guanho. All rights reserved.
//

import Foundation

class Reply {
    var data: [String: AnyObject]!
    
    var context: String!
    var nickName: String!
    var date: String!
    
    init(_ data: [String: AnyObject]) {
        self.data = data
        self.context = getString(data["context"])
        self.nickName = getString(data["nickName"])
        self.date = getString(data["date"])
    }
    init() {
    }
    
    func getInt(_ key: AnyObject?) -> Int{
        if let value = key as? String{
            return Int(value)!
        }else if let value = key as? Int{
            return value
        }else{
            return 0
        }
    }
    func getString(_ key: AnyObject?) -> String{
        if let value = key as? String{
            return value
        }else{
            return ""
        }
    }
    func getDouble(_ key: AnyObject?) -> Double{
        if let value = key as? String{
            return Double(value)!
        }else if let value = key as? Double{
            return value
        }else{
            return 0
        }
    }
}