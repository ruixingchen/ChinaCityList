//
//  GOVArea.swift
//  CityListExport
//
//  Created by ruixingchen on 21/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation

class GOVArea {
    var code:Int
    var name:String

    var level:Int = 1

    var subArea:[GOVArea] = []

    var checked:Bool = false
    var allChecked:Bool {
        for i in subArea {
            if !i.checked {
                return false
            }
        }
        return true
    }

    init(name:String, code:Int) {
        self.name = name
        self.code = code
    }

    var dictionaryObject:NSDictionary {
        let dict = NSMutableDictionary(capacity: 2)
        dict["name"] = name
        dict["code"] = code
        if subArea.isEmpty {
            return dict
        }
        var subAreaDictObjectArray:[NSDictionary] = []
        for i in subArea {
            subAreaDictObjectArray.append(i.dictionaryObject)
        }
        if level == 1 {
            dict["city"] = subAreaDictObjectArray
        }else if level == 2 {
            dict["district"] = subAreaDictObjectArray
        }
        return dict
    }
}
