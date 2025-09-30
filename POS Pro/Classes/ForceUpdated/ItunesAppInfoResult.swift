//
//  ItunesAppInfoResult.swift
//  pos
//
//  Created by M-Wageh on 14/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation


class ItunesAppInfoResult : NSObject{

    var trackViewUrl : String!
    var version : String!
    var currentVersionReleaseDate:String!
    
    init(fromDictionary dictionary: [String:Any]){
        trackViewUrl = dictionary["trackViewUrl"] as? String
        version = dictionary["version"] as? String
        currentVersionReleaseDate = dictionary["currentVersionReleaseDate"] as? String
    }
    func isPassedMoreThan3Day(days: Int = 3,  toDate date2 : Date = Date()) -> Bool {
        let date =  Date(strDate: currentVersionReleaseDate, formate: baseClass.date_fromate_app_store , UTC: false)
        let unitFlags: Set<Calendar.Component> = [.day]
        let deltaD = Calendar.current.dateComponents( unitFlags, from: date, to: date2).day
        return (deltaD ?? 0 >= days)
    }

}
