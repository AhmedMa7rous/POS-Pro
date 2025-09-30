//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
//TODO: -
//comu_test_tomtom
//pos.users
//Fill res_users_class from pos.user API

//start_session API  pos_user_id instead of user_id
//close_session API pos_user_id instead of user_id
//create_from_ui API pos_user_id instead of user_id
//void_product API pos_user_id instead of user_id
class res_users_class: NSObject {
    
    var dbClass:database_class?
    
    
    var id : Int = 0
    var name : String?
    
    
    var login : String?
    var password : String?
    
    var image : String?
    var function : String?
    var pos_security_pin : String?
    
    var pos_user_type : String?
    var __last_update : String?
    
    
    
    var fristLogin : String? // TIMESTAMP
    var lastLogin : String?  // TIMESTAMP
    
    var active:Bool?
    
    var is_login:Bool?
    
    
    var excludeProperties:[String] = []
    var pos_config_ids:[Int] = []

    var company_id : Int?
    var brand_ids: [Int] = []
    
    var access_rules:[ios_rule] = []
    var deleted : Bool = false


    
    
    override init() {
        
    }
    
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
       
        company_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "company_id", keyOfDatabase: "company_id",Index: 0) as? Int ?? 0

        __last_update = dictionary["__last_update"] as? String ?? ""
        
        name = dictionary["name"] as? String ?? ""
        
        login = dictionary["login"] as? String ?? ""
        password = dictionary["password"] as? String ?? ""
        
        if let base64String = dictionary["image"] as? String, !base64String.isEmpty {
            let name_Image = "\(id)" + ".png"
            if base64String != name_Image{
                self.image = name_Image
                FileMangerHelper.shared.saveBase64AsImage(base64String, in :.res_users,with:name_Image)
            }else{
                image = name_Image
            }
        }else{
            image = ""
        }
        function = dictionary["function"] as? String ?? ""
        pos_security_pin = dictionary["pos_security_pin"] as? String ?? ""
        pos_user_type = dictionary["pos_user_type"] as? String ?? ""
         
        lastLogin = dictionary["lastLogin"] as? String ?? "0"
        fristLogin = dictionary["fristLogin"] as? String ?? "0"
        
         active = dictionary["active"] as? Bool ?? false
        is_login = dictionary["is_login"] as? Bool ?? false
        
        pos_config_ids = dictionary["pos_config_ids"] as? [Int] ?? []
        brand_ids = dictionary["brand_ids"] as? [Int] ?? []

        dbClass = database_class(table_name: "res_users", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        
        dictionary["__last_update"] = __last_update
        
         dictionary["fristLogin"] = fristLogin
        dictionary["lastLogin"] = lastLogin
        
        
        dictionary["name"] = name
        dictionary["login"] = login
        dictionary["password"] = password
        
        dictionary["image"] = image
        dictionary["function"] = function
        dictionary["pos_security_pin"] = pos_security_pin
        dictionary["id"] = id
        
        dictionary["pos_user_type"] = pos_user_type
        dictionary["active"] = active
        dictionary["is_login"] = is_login
        dictionary["company_id"] = company_id
        dictionary["deleted"] = deleted

        

        
        dictionary = baseClass.fillterProperties(dictionary: dictionary,excludeProperties: excludeProperties)
        
        return dictionary
    }
    
    
   
    func get_pos_config_ids() -> [Int]
    {
        return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2:  "res_users|pos_config_ids") ?? []
    }
    func get_brand_ids() -> [Int]
    {
        return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2:  "res_users|brand_ids") ?? []
    }
    
    func setLogin()
    {
        let cls = res_users_class(fromDictionary: [:])

        _ =  cls.dbClass?.runSqlStatament(sql: "update res_users set is_login = 0")
        self.is_login = true
        
        save()
    }
    
    func save(forApi:Bool = false,temp:Bool = false)
    {
        
         
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        
        if temp
        {
            dbClass!.table_name =  "temp_" + dbClass!.table_name
        }
        
        _ =  dbClass!.save()
        
        if forApi == true{
            relations_database_class(re_id1: self.id, re_id2: pos_config_ids, re_table1_table2: "res_users|pos_config_ids").save()
            relations_database_class(re_id1: self.id, re_id2: brand_ids, re_table1_table2: "res_users|brand_ids").save()

        }
        

            
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = res_users_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")
         relations_database_class.reset(  re_table1_table2: "res_users|pos_config_ids")
        relations_database_class.reset(  re_table1_table2: "res_users|brand_ids")


//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='res_users|pos_config_ids' ")
 
        
    }
    
    static func saveAll(arr:[[String:Any]] ,excludeProperties:[String],temp:Bool = false )
    {
        for item in arr
        {
            let pos = res_users_class(fromDictionary: item)
            pos.deleted = false
            pos.excludeProperties.append(contentsOf: excludeProperties)
            pos.dbClass?.insertId = true
            pos.save(forApi: true,temp: temp)
        }
    }
    
    static func getCashier(ID:Int) -> res_users_class
    {
        var cls = res_users_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where id =" + String(ID))
        
        if row != nil
        {
            cls = res_users_class(fromDictionary: row!)
            
        }
        
        return cls
    }
    
    static func getDefault() -> res_users_class {
        
        var cashier = res_users_class(fromDictionary: [:])
        
        let row:[String:Any]!  = cashier.dbClass!.get_row(whereSql: "where is_login = 1")
        if row != nil
        {
            cashier = res_users_class(fromDictionary: row!)
        }
        
        cashier.access_rules = rules.get_rules_for_user(user_id: cashier.id)
        
        return cashier
    }
    
    
    static func deleteDefault()   {
        //        let className:String = "cashier"
        //       myuserdefaults.deleteitems("cashier", prefix:className)
        let local = getDefault()
        local.is_login = false
        local.save()
        
    }
    static func get(id:Int?)-> res_users_class?
       {
           if id != nil
           {
               
               
               let cls = res_users_class(fromDictionary: [:])
               let row  = cls.dbClass!.get_row(whereSql: " where id = " + String(id!))
               if row !=  nil
               {
                   let temp:res_users_class = res_users_class(fromDictionary: row!  )
                   return temp
               }
           }
           return nil
       }
    
    static func getAll() ->  [[String:Any]] {
          
          let cls = res_users_class(fromDictionary: [:])
          let arr  = cls.dbClass!.get_rows(whereSql: "")
          return arr
          
      }
    
    static func getAllHavePin() ->  [[String:Any]] {
          
          let cls = res_users_class(fromDictionary: [:])
          let arr  = cls.dbClass!.get_rows(whereSql: " where pos_security_pin !='' and deleted = 0")
          return arr
          
      }
      
    static func getAll_available() ->  [[String:Any]] {
            
        let pos = SharedManager.shared.posConfig()
        let sql = " SELECT ru.* from res_users ru where ru.deleted = 0 ORDER by lastLogin DESC , pos_user_type"
 /*
 """
 SELECT
     ru.*
 from res_users ru ,relations r
 WHERE
     r.re_table1_table2 = "res_users|pos_config_ids"
     and  re_id2 = \(pos.id)
     and ru.id = r.re_id1
     and ru.pos_security_pin != ''
     and ru.active = 1
    and ru.deleted = 0
 UNION SELECT
     ru.*
 from
     res_users ru
 WHERE
     ru.id not in (
     SELECT
         r.re_id1
     from
         relations r
     WHERE
         r.re_table1_table2 = "res_users|pos_config_ids"
      )
 ORDER by
     lastLogin DESC ,
     pos_user_type
 """
  */
        //     and ru.company_id = \(pos.company_id ?? 0)

//        let sql = """
//             SELECT res_users.* FROM (select * from res_users  where active = 1  and company_id= \(pos.company_id ?? 0) and pos_security_pin !='') res_users
//                left join (select * from relations where relations.re_table1_table2 IN ('res_users|pos_config_ids') ) relations
//                on re_id1 = res_users.id
//                where      ifnull(relations.re_id2,0) = 0
//
//        UNION
//
//        SELECT res_users.* FROM res_users
//        inner join relations
//        on re_id1 = res_users.id
//        where active = 1 and pos_security_pin !='' and relations.re_id2 = \(pos.id) and company_id=\(pos.company_id ?? 0) ORDER by lastLogin  DESC , pos_user_type
//
//        """
            let cls = res_users_class(fromDictionary: [:])
//            let arr  = cls.dbClass!.get_rows(whereSql: " where active = 1 and pos_security_pin !=''  ORDER by lastLogin  DESC , pos_user_type ")
        let arr  = cls.dbClass!.get_rows(sql: sql)
        if let brand_id = pos.brand_id {
            if arr.count > 0 {
               let new_arr = arr.filter { userDic in
                    let res_user = res_users_class(fromDictionary: userDic)
                    if  res_user.get_brand_ids().count > 0 {
                        return res_user.get_brand_ids().contains(brand_id)
                    }
                    return true
                }
                return new_arr
            }
        }

            return arr
            
        }
    
    
    static func set_frist_login()
    {
        let chasher = SharedManager.shared.activeUser()
                  let timenow =  Date.currentDateTimeMillis() //  ClassDate.getTimeINMS()
                  if chasher.fristLogin! == ""
                  {
                      chasher.fristLogin = String( timenow)
                  }
                  
                   chasher.lastLogin = String(  timenow)
                   chasher.save()
    }
    
    func canAccess(for key:rule_key) -> Bool{
        return self.access_rules.first(where: {$0.key == key})?.access ?? false
    }
    func canAccessForAny(keies:[rule_key]) -> Bool{
        var isAccess = false
        keies.forEach {keyRule  in
            if canAccess(for:keyRule ){
                isAccess = true
            }
        }
        return isAccess

    }
    
}
