//
//  ViewController.swift
//  CityListExport
//
//  Created by ruixingchen on 21/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import Kanna
import SwiftyJSON

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        writeHF(organizedAreas: exportHF())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// export city list from gov
    func exportGov()->[GOVArea]{
        let filePath = Bundle.main.path(forResource: "govSource.txt", ofType: nil)!
        let sourceText = try! String.init(contentsOf: URL(fileURLWithPath: filePath))
        let nodes = sourceText.components(separatedBy: "\n")
        print("all area num: \(nodes.count)")

        var areas:[GOVArea] = []
        for node in nodes {
            var nodeText = node
            print(nodeText)

            var level:Int = 0
            if nodeText.hasPrefix("　　"){
                level = 3
            }else if nodeText.hasPrefix("　") {
                level = 2
            }else if nodeText.hasPrefix("") {
                level = 1
            }else {
                assertionFailure("faile to get level")
            }

            var codeNum = 0
            var name = ""

            nodeText = nodeText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            var separator = ""
            if level == 1 {
                separator = "     "
            }else if level == 2 {
                separator = "         　"
            }else if level == 3{
                separator = "     　　"
            }else{
                assertionFailure("level illegal")
            }

            let split = nodeText.components(separatedBy: separator)
            if split.count != 2 {
                assertionFailure("error node text")
            }
            codeNum = Int(split[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) ?? 0
            if codeNum == 0 {
                assertionFailure("code num failed")
            }
            name = split[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if name.isEmpty {
                assertionFailure("name failed")
            }
            let area = GOVArea(name: name, code: codeNum)
            area.level = level
            areas.append(area)
        }

        if areas.count != nodes.count {
            assertionFailure("different num")
        }

        var organizedAreas:[GOVArea] = []

        for i in areas {
            if i.level == 1 {
                organizedAreas.append(i)
            }else if i.level == 2 {
                let province = organizedAreas.last!
                province.subArea.append(i)
            }else if i.level == 3 {
                let city = organizedAreas.last!.subArea.last!
                city.subArea.append(i)
            }
        }
        return organizedAreas
    }

    func writeGOV(organizedAreas:[GOVArea]){
        var dictObjectArray:[NSDictionary] = []
        for i in organizedAreas {
            dictObjectArray.append(i.dictionaryObject)
        }

        let data = try! JSONSerialization.data(withJSONObject: dictObjectArray, options: JSONSerialization.WritingOptions.prettyPrinted)
        //            let outputStr = String.init(data: data, encoding: .utf8)!

        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).first!
        var url = URL.init(fileURLWithPath: path)
        url.appendPathComponent("GOV.json")

        try! data.write(to: url)
    }

    /// export list from hefeng weather
    func exportHF()->[HFArea]{
        let filePath = Bundle.main.path(forResource: "hfSource.txt", ofType: nil)!
        let sourceText = try! String.init(contentsOf: URL(fileURLWithPath: filePath))
        let nodes = sourceText.components(separatedBy: "\n")
        print("all area num: \(nodes.count)")

        var areas:[HFArea] = []
        for node in nodes {
            if !node.hasPrefix("CN") {
                print("comment line")
                continue
            }
            let components = node.components(separatedBy: CharacterSet.whitespaces)
            if components.count != 12 {
                assertionFailure("elements num error")
            }
            let area = HFArea()
            area.code = components[0]
            area.name_EN = components[1]
            area.name_CN = components[2]
            area.countryCode = components[3]
            area.countryName_EN = components[4]
            area.countryName_CN = components[5]
            area.provinceName_EN = components[6]
            area.provinceName_CN = components[7]
            area.superCityName_EN = components[8]
            area.superCityName_CN = components[9]
            area.latitude = components[10]
            area.longitude = components[11]

            if Double(area.latitude) == nil || Double(area.longitude) == nil {
                assertionFailure("coordinate error")
            }

            areas.append(area)
        }
        print("all areas count \(areas.count)")

        var organizedAreas:[HFArea] = []
        for i in areas {
            if i.isCity {
                //city
                var province = organizedAreas.last
                if province == nil || i.provinceName_CN != province?.name_CN {
                    province = HFArea()
                    province!.name_CN = i.provinceName_CN
                    province!.name_EN = i.provinceName_EN
                    province?.isProvince = true
                    organizedAreas.append(province!)
                }
                province!.subArea.append(i)
            }else {
                //district
                let city = organizedAreas.last!.subArea.last!
                city.subArea.append(i)
            }
        }

        return organizedAreas
    }

    func writeHF(organizedAreas:[HFArea]){
        var dictArray:[NSDictionary] = []
        for i in organizedAreas {
            dictArray.append(i.dictObject)
        }

        let data = try! JSONSerialization.data(withJSONObject: dictArray, options: JSONSerialization.WritingOptions.prettyPrinted)
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).first!
        var url = URL.init(fileURLWithPath: path)
        url.appendPathComponent("HF.json")
        try! data.write(to: url)
    }

}

