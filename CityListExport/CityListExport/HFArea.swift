//
//  HFArea.swift
//  CityListExport
//
//  Created by ruixingchen on 21/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation

class HFArea {

    /*
     城市/地区编码    英文    中文    国家代码    国家英文    国家中文    省英文    省中文    所属上级市英文    所属上级市中文    纬度    经度
     CN101010100    beijing    北京    CN    China    中国    beijing    北京    beijing    北京    39.904989    116.405285
     */

    var code:String! //0
    var name_EN:String!//1
    var name_CN:String!//2
    var countryCode:String!//3
    var countryName_EN:String!
    var countryName_CN:String!
    var provinceName_EN:String!
    var provinceName_CN:String!
    var superCityName_EN:String!
    var superCityName_CN:String!
    var latitude:String!
    var longitude:String!

    var subArea:[HFArea] = []

    var isProvince:Bool = false

    var isCity:Bool {
        return self.name_CN == superCityName_CN
    }

    var checked:Bool = false

    var allChecked:Bool {
        for i in subArea {
            if !i.checked {
                return false
            }
        }
        return true
    }

    var dictObject:NSDictionary {
        let dict = NSMutableDictionary()
        dict["name_CN"] = name_CN
        dict["name_EN"] = name_EN
        dict["hfCode"] = code
        dict["latitude"] = latitude
        dict["longitude"] = longitude
        if subArea.isEmpty {
            return dict
        }
        var subAreaDictObjectArray:[NSDictionary] = []
        for i in subArea {
            subAreaDictObjectArray.append(i.dictObject)
        }
        if isProvince {
            dict["city"] = subAreaDictObjectArray
        }else if isCity {
            dict["district"] = subAreaDictObjectArray
        }
        return dict
    }

}
