//
//  PrinterModelsEnum.swift
//  pos
//
//  Created by M-Wageh on 04/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

enum ConnectionTypes: String, CaseIterable {
    case WIFI, BLUETOOTH, USB
    
    func getConnectionType()->String{
        return "\(self)"
    }
    func getConnectionTypeForAPI()->String{
        return "\(self)".lowercased()
    }
    
    static func getAllConnectiontypesString()->[String]{
       return ConnectionTypes.allCases.map({$0.getConnectionType()})
    }
    
    
    
}



enum PRINTER_BRAND_TYPES:String,CaseIterable {
    case EPSON,HPRT,SUNMI,X_Printer,TA_POS, STAR
    func getBrandName()->String{
        return "\(self)"
    }
    static func getAllBrandString()->[String]{
       return PRINTER_BRAND_TYPES.allCases.map({$0.getBrandName()})
    }

    func getAllModels()->[String]{
        switch self {
        case .EPSON:
            return EPSON_MODELS_TYPES.getAllModelString()
        case .HPRT:
            return HPRT_MODELS_TYPES.getAllModelString()
        case .SUNMI:
            return SUNMI_MODELS_TYPES.getAllModelString()
        case .X_Printer:
            return X_PRINTER_MODELS_TYPES.getAllModelString()
        case .TA_POS:
            return X_PRINTER_MODELS_TYPES.getAllModelString()
        case .STAR:
            return STAR_MODELS_TYPES.getAllModelString()
        }
    }
    
}

enum TA_POS_MODELS_TYPES:Int,CaseIterable {
    case TA_POS = 0
    func getModelName()->String{
        return "Ta POS"
    }
    static func getAllModelString()->[String]{
       return TA_POS_MODELS_TYPES.allCases.map({$0.getModelName()})
    }

}

enum STAR_MODELS_TYPES:Int,CaseIterable {
    case STAR = 0
    func getModelName()->String{
        return "STAR"
    }
    static func getAllModelString()->[String]{
       return STAR_MODELS_TYPES.allCases.map({$0.getModelName()})
    }

}
enum X_PRINTER_MODELS_TYPES:Int,CaseIterable {
    case Xprinter = 0
    func getModelName()->String{
        return "\(self)"
    }
    static func getAllModelString()->[String]{
       return X_PRINTER_MODELS_TYPES.allCases.map({$0.getModelName()})
    }

}
enum SUNMI_MODELS_TYPES:Int,CaseIterable {
    case SUNMI = 0
    func getModelName()->String{
        return "\(self)"
    }
    static func getAllModelString()->[String]{
       return SUNMI_MODELS_TYPES.allCases.map({$0.getModelName()})
    }

}
enum HPRT_MODELS_TYPES:Int,CaseIterable {
    case TP80BE = 0
    func getModelName()->String{
        return "\(self)"
    }
    static func getAllModelString()->[String]{
       return HPRT_MODELS_TYPES.allCases.map({$0.getModelName()})
    }

}
enum EPSON_MODELS_TYPES:Int,CaseIterable {
    case  EPOS2_TM_M10 = 0,
          EPOS2_TM_M30,
          EPOS2_TM_P20,
          EPOS2_TM_P60,
          EPOS2_TM_P60II,
          EPOS2_TM_P80,
          EPOS2_TM_T20,
          EPOS2_TM_T60,
          EPOS2_TM_T70,
          EPOS2_TM_T81,
          EPOS2_TM_T82,
          EPOS2_TM_T83,
          EPOS2_TM_T88,
          EPOS2_TM_T90,
          EPOS2_TM_T90KP,
          EPOS2_TM_U220,
          EPOS2_TM_U330,
          EPOS2_TM_L90,
          EPOS2_TM_H6000,
          EPOS2_TM_T83III,
          EPOS2_TM_T100,
          EPOS2_TM_M30II,
          EPOS2_TS_100,
          EPOS2_TM_M50
    func getModelName()->String{
        return "\(self)".replacingOccurrences(of: "EPOS2_", with: "")
    }
    static func getAllModelString()->[String]{
       return EPSON_MODELS_TYPES.allCases.map({$0.getModelName()})
    }
   
}
