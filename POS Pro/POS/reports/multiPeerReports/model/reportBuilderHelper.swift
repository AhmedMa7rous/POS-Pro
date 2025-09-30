//
//  reportBuilderHelper.swift
//  pos
//
//  Created by khaled on 03/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class reportBuilderHelper: NSObject {

    

    
   static func getSessionForDay(_ startDate:String?) -> [pos_session_class]
    {
        var lst_sessions:[pos_session_class] = []
        
        let start_date = get_start_date(startDate)
        let end_date = get_end_date(startDate)
 
        
        let options = posSessionOptions()
        options.between_start_session = [start_date,end_date]
        
        lst_sessions = pos_session_class.get_pos_sessions(options: options)
  
        
      
        return lst_sessions
        
    }
    
    
    static func get_start_date(_ start_date:String?) -> String
    {
       
        let checkDay = baseClass.get_date_local_to_search(DateOnly: start_date!, format: "yyyy-MM-dd" ,returnFormate:  baseClass.date_formate_database)
        
        return checkDay
    }
    
    static func get_end_date(_ start_date:String?) -> String
      {
          
        let endDaty_str = baseClass.get_date_local_to_search(DateOnly: start_date!, format: "yyyy-MM-dd" ,returnFormate:  baseClass.date_formate_database,addHours: 24)

          return endDaty_str
      }
    
    
}
