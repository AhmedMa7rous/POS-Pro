//
//  alter_database_enum.swift
//  pos
//
//  Created by M-Wageh on 16/12/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
enum alter_database_enum:String{
    case loadingApp = "loadingAlterDataBase"
    case changingDataBase  = "changingAlterDataBase"
    case selectedDataBase  = "selectedAlterDataBase"
    
    func getIsDoneBefore()->Bool{
       if SharedManager.shared.isDiffVersion() {
        let currentVersion = Bundle.main.fullVersion
        UserDefaults.standard.setValue(currentVersion, forKey: "version_user_default")
            return false
        }
        return UserDefaults.standard.bool(forKey: self.rawValue)
    }
    func setIsDone(with value:Bool){
        for item in [alter_database_enum.loadingApp,.changingDataBase,.selectedDataBase]{
            if item == self {
                UserDefaults.standard.setValue(value, forKey: self.rawValue)
            }else{
                UserDefaults.standard.setValue(false, forKey: item.rawValue)
            }
        }
    }
}
