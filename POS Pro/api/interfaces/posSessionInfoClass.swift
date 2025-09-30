//
//  posSessionInfoClass.swift
//  pos
//
//  Created by Khaled on 4/19/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

protocol  posSessionInfoClass_delegate {
    func posSessionStus(session:posSessionClass)
    func posSessionStusFailed()

}


class posSessionInfoClass: NSObject {
    
    let con:api = api()
    var delegate:posSessionInfoClass_delegate?
    
    
    func posSessionInfo(userid:Int)   {
         
         con.userCash = .stopCash
         con.get_pos_session_info { (result) in
             if (result.success)
             {
                 let response = result.response
                 let result_arr =  response?["result"] as? [[String:Any]] ?? []
                 
                 if result_arr.count > 0
                 {
                     
                     let cashier = cashierClass.getDefault()
                     //                    var sessionOpend:Bool = false
                     
                     for row:[String:Any]  in result_arr
                     {
                         let pos = posSessionClass(fromDictionary:row)
                         //                        let userid = pos.user_id[0]  as? Int ?? 0
                         if cashier.id == userid
                         {
                             pos.isOpen = true
                             //                            sessionOpend = true
                             //                            AppDelegate.shared().loadHome()
                             self.delegate?.posSessionStus(session: pos)
                             
                             return
                         }
                         
                         
                     }
                     
                     //                    self.delegate?.posSessionStus(open: sessionOpend)
                     
                     
                     
                     
                 }
                 
                 self.delegate?.posSessionStus(session: posSessionClass())
                 
                 
             }
             else
             {
                 self.delegate?.posSessionStusFailed()
                 
             }
             
             
         }
     }
     

}
