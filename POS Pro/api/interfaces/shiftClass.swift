//
//  shiftClass.swift
//  pos
//
//  Created by khaled on 11/12/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation

 

class shiftClass: NSObject {
    
    var id : Int = 0 // TimeStamp for start shift
    var session_id : Int!

    var start_shift: String?
    var end_shift: String?

    
    
    var shift_sequence: Int = 0
    
    var start_Balance : Double  = 0
    var end_Balance : Double  = 0
    var casher : cashierClass!
    
    var cashbox_list : [Any] = []
 
    var user_id :Int = 0
    var isOpen : Bool = false
    
    var show_as:showAs = showAs.start

    
    override init() {
        super.init()
        
    }
    
    init(fromDictionary dictionary: [String:Any]){
        
        id = dictionary["id"] as? Int ?? 0
        session_id = dictionary["session_id"] as? Int ?? 0

        
        start_shift = dictionary["start_shift"] as? String
        end_shift = dictionary["end_shift"] as? String

        
        shift_sequence = dictionary["shift_sequence"] as? Int ?? 0
        
        cashbox_list = dictionary["cashbox_list"] as? [Any] ?? []
    
    
        user_id = dictionary["user_id"] as? Int ?? 0
       
        let casher_obj = dictionary["casher"] as? [String:Any] ?? [:]
        casher = cashierClass(fromDictionary: casher_obj)
        
        start_Balance = dictionary["start_Balance"] as? Double ?? 0
        end_Balance = dictionary["end_Balance"] as? Double ?? 0
        isOpen = dictionary["isOpen"] as? Bool ?? false

        
    }
    
    func toDictionary() -> [String:Any]
    {
        
        var dictionary = [String:Any]()
        dictionary["session_id"] = session_id

        dictionary["shift_sequence"] = shift_sequence
        dictionary["end_shift"] = end_shift
        dictionary["start_shift"] = start_shift

        dictionary["id"] = id
        dictionary["user_id"] = user_id
        dictionary["cashbox_list"] = cashbox_list
        dictionary["start_Balance"] = start_Balance
        dictionary["end_Balance"] = end_Balance
        dictionary["isOpen"] = isOpen

        
        if casher != nil
        {
            dictionary["casher"] = casher.toDictionary()
            
        }
        
        
        return dictionary
        
    }
    
    static   func get_last_current_shift(session_id:Int) ->shiftClass?
       {
           let sql = "select * from shifts where session_id =? and isOpen = ?"
                     
        var shift:shiftClass?
        
        let semaphore = DispatchSemaphore(value: 0)

        SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
          
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [session_id , false])
            shift = readRowFromDataBase(rows: resutl)
            
              semaphore.signal()
        }
        
        
        semaphore.wait()

                return shift
      }
    
    static   func getCurrentShift(session_id:Int) ->shiftClass?
       {
           let sql = "select * from shifts where session_id =? and isOpen = ?"
                     
        var shift:shiftClass?
        
        let semaphore = DispatchSemaphore(value: 0)

        SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
          
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [session_id , true])
            shift = readRowFromDataBase(rows: resutl)
            
              semaphore.signal()
        }
        
        
        semaphore.wait()

                return shift
      }
    
    static   func getShift(shift_id:Int) ->shiftClass?
    {
        let sql = "select * from shifts where shift_id =?  "
         var shift:shiftClass?
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
            
              let resutl:FMResultSet = try! db.executeQuery(sql, values: [shift_id ])
            
              shift = readRowFromDataBase(rows: resutl)
            
            
             semaphore.signal()
            }
        
              semaphore.wait()
        
             return shift
   }
    
    static   func getAllShift(orderAsc :String = "asc") ->[[String : Any]]
         {
          
             let sql = "select * from shifts  order by shift_id \(orderAsc)"
              var arr:[[String : Any]] = []
          
          let semaphore = DispatchSemaphore(value: 0)
          SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
              
            let rows:FMResultSet = try! db.executeQuery(sql, values: [ ])
          

          while (rows.next()) {
                //retrieve values for each record
              let data = rows.string(forColumn: "data")
             
              var dic =  data?.toDictionary() ?? [:]
               dic["id"] = Int(rows.int(forColumn: "shift_id"))
              
              arr.append(dic)
          }
           rows.close()
              
               semaphore.signal()
              }
              
              
              semaphore.wait()
          
             return arr
             
         }
    
    static   func getAllShift(session_id:Int) ->[[String : Any]]
       {
        
           let sql = "select * from shifts where session_id =? "
            var arr:[[String : Any]] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
            
          let rows:FMResultSet = try! db.executeQuery(sql, values: [session_id ])
        

        while (rows.next()) {
              //retrieve values for each record
            let data = rows.string(forColumn: "data")
           
            var dic =  data?.toDictionary() ?? [:]
             dic["id"] = Int(rows.int(forColumn: "shift_id"))
            
            arr.append(dic)
        }
         rows.close()
            
             semaphore.signal()
            }
            
            
            semaphore.wait()
        
           return arr
           
       }
    
    
    static func getAllShift(start_date:String, end_date:String) ->[[String : Any]]
    {
        let sql = "select * from shifts where start_shift  between '\(start_date  )'  and  '\(end_date  )' order by shift_id"
                  var arr:[[String : Any]] = []
              
              let semaphore = DispatchSemaphore(value: 0)
              SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
                  
                let rows:FMResultSet = try! db.executeQuery(sql , values:[])
              

              while (rows.next()) {
                    //retrieve values for each record
                  let data = rows.string(forColumn: "data")
                 
                  var dic =  data?.toDictionary() ?? [:]
                   dic["id"] = Int(rows.int(forColumn: "shift_id"))
                  
                  arr.append(dic)
              }
               rows.close()
                  
                   semaphore.signal()
                  }
                  
                  
                  semaphore.wait()
              
                 return arr
    }
    
      static func getAllShift(start_date:String) ->[[String : Any]]
       {
        
           let sql = "select * from shifts where start_shift like '\(start_date)%' order by shift_id"
            var arr:[[String : Any]] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
            
          let rows:FMResultSet = try! db.executeQuery(sql , values:[])
        

        while (rows.next()) {
              //retrieve values for each record
            let data = rows.string(forColumn: "data")
           
            var dic =  data?.toDictionary() ?? [:]
             dic["id"] = Int(rows.int(forColumn: "shift_id"))
            
            arr.append(dic)
        }
         rows.close()
            
             semaphore.signal()
            }
            
            
            semaphore.wait()
        
           return arr
           
       }
    
    static func getAllShift(filed:String,search:String,oprator:String = "like",limit:[Int] = [0,1000],orderType:String = "asc") ->[[String : Any]]
       {
        
           let sql = "select * from shifts where \(filed) \(oprator) \(search) order by shift_id \(orderType) limit \(limit[0]),\(limit[1])"
            var arr:[[String : Any]] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
            
          let rows:FMResultSet = try! db.executeQuery(sql , values:[])
        

        while (rows.next()) {
              //retrieve values for each record
            let data = rows.string(forColumn: "data")
           
            var dic =  data?.toDictionary() ?? [:]
             dic["id"] = Int(rows.int(forColumn: "shift_id"))
            
            arr.append(dic)
        }
         rows.close()
            
             semaphore.signal()
            }
            
            
            semaphore.wait()
        
           return arr
           
       }
    
    
    
    static  func getAllShift_count(session_id:Int) -> Int
    {
               let sql = "select count(*) from shifts where session_id =?"
                var count = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
              let resutl:FMResultSet = try! db.executeQuery(sql, values: [session_id])
              
              if resutl.next()
              {
                count = Int(resutl.int(forColumnIndex: 0))
                  
 
              }
               resutl.close()
              semaphore.signal()
        }
        
        
        semaphore.wait()
        
              return count
              
      }
    
    
    func save()
    {
          let data =   JsonToDictionary.jsonString(with: self.toDictionary(), prettyPrinted: true)  ?? ""
  let semaphore = DispatchSemaphore(value: 0)
        
              SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
                if checkShiftExit() == false
                {
        
                    let success = db.executeUpdate(
                        "insert into shifts (session_id,start_shift,isOpen,user_id,shift_sequence,start_Balance,data) VALUES (?,?,?,?,?,?,?) "
                        , withArgumentsIn: [self.session_id!, self.start_shift!, self.isOpen,self.user_id,self.shift_sequence,self.start_Balance,data ])
                    
                    if !success
                    {
                        let error = db.lastErrorMessage()
                        print("database Error : %@" , error)
                    }
                }
                else
                {
         
               let success = db.executeUpdate(
                        "update shifts set end_shift =? ,end_Balance=?  ,isOpen=?,data=? where shift_id=?"
                , withArgumentsIn: [self.end_shift ?? NSNull(), self.end_Balance ,   self.isOpen, data  ,self.id ])

                    if !success
                               {
                                let error = db.lastErrorMessage()
                                   print("database Error : %@" , error)
                               }
                    
                }
         semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    static func readRowFromDataBase(rows:FMResultSet) -> shiftClass?
    {
        
        if rows.next()
                {
                   let data = rows.string(forColumn: "data")
                
                   let dic =  data?.toDictionary() // JsonToDictionary.diccionary(fromJsonString: data)
                   
                   let shift = shiftClass(fromDictionary: dic!)
                    
                   shift.id = Int(rows.int(forColumn: "shift_id"))
                   shift.session_id = Int(rows.int(forColumn: "session_id"))
               

                   shift.start_shift = rows.string(forColumn: "start_shift")
                    shift.end_shift =  rows.string(forColumn: "end_shift")
                    
                    shift.shift_sequence = Int(rows.int(forColumn: "shift_sequence"))
                    
                   shift.start_Balance =  rows.double(forColumn: "start_Balance")
                    shift.end_Balance = rows.double(forColumn: "end_Balance")
                    
                    shift.user_id =  Int(rows.int(forColumn: "user_id"))
                    
                    
                   shift.isOpen =  rows.bool(forColumn: "isOpen")

                    
                    rows.close()
                   return shift
        
                }
        else
                {
                    rows.close()
                   return nil
                }
    }
    
    func checkShiftExit() -> Bool
    {
        if self.id == 0   {
            return false
        }
        
        let sql = "select count(*) from shifts where shift_id =?"
        var Exist:Bool = false
        
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
            
        let resutl:FMResultSet = try! db.executeQuery(sql, values: [self.id])
        
        if resutl.next()
        {
            let count = resutl.int(forColumnIndex: 0)
             resutl.close()
            if count > 0
            {
                Exist = true
            }
        }
         resutl.close()
       
             semaphore.signal()
            }
            
            
            semaphore.wait()
            
        return Exist
    }
    
    
}
