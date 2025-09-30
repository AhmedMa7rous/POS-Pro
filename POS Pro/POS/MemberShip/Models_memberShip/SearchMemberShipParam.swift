//
//  SearchMemberShipParam.swift
//  pos
//
//  Created by M-Wageh on 26/02/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
struct SearchMemberShipParam{
    var date:String?
    var search:String?
    init() {
        date = Date().toString(dateFormat: baseClass.date_fromate_satnder_date, UTC: false)
        search = ""
    }
    func getSearchParams() ->  [String:Any] {
        let dictionaryParam:[String:Any] = [
            "date": self.date ?? "",
                "search": self.search ?? ""
        ]
        return dictionaryParam
    }
    func validation()-> (isValid:Bool,message:String) {
       /* if search?.isEmpty ?? false {
          return (false, "You must enter search word")
        }
        if date?.isEmpty ?? false {
          return (false, "You must enter search date")
        }*/
        return (true, search ?? "")
    }
}
