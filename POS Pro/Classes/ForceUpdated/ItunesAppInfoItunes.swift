//
//  ItunesAppInfoItunes.swift
//  pos
//
//  Created by M-Wageh on 14/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

class ItunesAppInfoItunes : NSObject{

    var resultCount : Int!
    var results : [ItunesAppInfoResult]!


    init(fromDictionary dictionary: [String:Any]){
        resultCount = dictionary["resultCount"] as? Int
        results = [ItunesAppInfoResult]()
        if let resultsArray = dictionary["results"] as? [[String:Any]]{
            for dic in resultsArray{
                let value = ItunesAppInfoResult(fromDictionary: dic)
                results.append(value)
            }
        }
    }

  
   
}
