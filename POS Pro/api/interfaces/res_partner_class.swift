//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class res_partner_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0 // id on server
    var row_id : Int = 0 // local id

    
    var barcode : String = ""
    var city : String = ""
    var country_Id : Int = 0
    var country_name : String = ""
    
    var email : String = ""
    
    var mobile : String = ""
    var name : String = ""
    var phone : String = ""
    var search_phone : String = ""
    var property_product_pricelist_id:Int = 0
    var property_product_pricelist_name:String = ""
    
    var street : String = ""
    var vat : String = ""
    var __last_update : String?
    var zip : String = ""
    var image : String = ""
    
    
    var discount_program_id :  Int = 0

    var loyalty_points_remaining :  Double = 0.0
    var loyalty_amount_remaining :  Double = 0.0

    var blacklist :  Bool = false

    
    
    var pending_id :  Int = 0
    //    var pending_order_id :  Int = 0
    //    var pending_id_server :  Int = 0
    //    var pending_key : String = ""
    
    var website : String = ""
    var function : String = ""
    var street2 : String = ""
    var building_no : String = ""
    var district : String = ""
    var additional_no : String = ""
    var other_id : String = ""
    var active: Bool = true
    var row_parent_id: Int = 0
    var parent_id : Int = 0
    var parent_name :  String = ""
//parent_id
    var pos_delivery_area_id : Int = 0
    var pos_delivery_area_name :  String = ""
    var deliveryContacts:[res_partner_class] = []
    var parent_partner_id : Int?
    var res_partner_id : Int?
    
    var l10n_sa_edi_building_number: String = ""
    var l10n_sa_edi_plot_identification: String = ""
    var state_id_name:String?

    override init() {
        
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        row_id = dictionary["row_id"] as? Int ?? 0

        
        
        barcode = dictionary["barcode"] as? String ?? ""
        city = dictionary["city"] as? String ?? ""
        email = dictionary["email"] as? String ?? ""
        mobile = dictionary["mobile"] as?  String ?? ""
        name = dictionary["name"] as? String ?? ""
        phone = remove_phone_formate(for:dictionary["phone"] as? String ?? "")
        street = dictionary["street"] as? String ?? ""
        vat = dictionary["vat"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        zip = dictionary["zip"] as? String ?? ""
        image = dictionary["image"] as? String ?? ""
        country_Id = dictionary["country_Id"] as? Int ?? 0
        country_name = dictionary["country_name"] as? String ?? ""
        
        loyalty_amount_remaining = dictionary["loyalty_amount_remaining"] as? Double ?? 0
        loyalty_points_remaining = dictionary["loyalty_points_remaining"] as? Double ?? 0

        blacklist = dictionary["blacklist"] as? Bool ?? false

        website = dictionary["website"] as? String ?? ""
        function = dictionary["function"] as? String ?? ""
        street2 = dictionary["street2"] as? String ?? ""
        building_no = dictionary["building_no"] as? String ?? ""
        district = dictionary["district"] as? String ?? ""
        additional_no = dictionary["additional_no"] as? String ?? ""
        other_id = dictionary["other_id"] as? String ?? ""
        active = dictionary["active"] as? Bool ?? true
        row_parent_id = dictionary["row_parent_id"] as? Int ?? 0
        parent_partner_id = dictionary["parent_partner_id"] as? Int
        res_partner_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "res_partner_id", keyOfDatabase: "res_partner_id",Index: 0) as? Int ?? 0

        l10n_sa_edi_building_number = dictionary["l10n_sa_edi_building_number"] as? String ?? ""
        l10n_sa_edi_plot_identification = dictionary["l10n_sa_edi_plot_identification"] as? String ?? ""
        state_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "state_id", keyOfDatabase: "state_id",Index: 1)as? String  ?? ""

        parent_id =   baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "parent_id", keyOfDatabase: "parent_id",Index: 0) as? Int ?? 0
        parent_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "parent_id", keyOfDatabase: "parent_name",Index: 1)as? String  ?? ""

        pos_delivery_area_id =   baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_delivery_area_id", keyOfDatabase: "pos_delivery_area_id",Index: 0) as? Int ?? 0
        pos_delivery_area_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_delivery_area_id", keyOfDatabase: "pos_delivery_area_name",Index: 1)as? String  ?? ""

        
        
        discount_program_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "discount_program_id", keyOfDatabase: "discount_program_id",Index: 0) as? Int ?? 0

        property_product_pricelist_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "property_product_pricelist", keyOfDatabase: "property_product_pricelist_id",Index: 0) as? Int ?? 0
        property_product_pricelist_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "property_product_pricelist", keyOfDatabase: "property_product_pricelist_name",Index: 1)as? String  ?? ""
        
        dbClass = database_class(table_name: "res_partner", dictionary: self.toDictionary(),id: row_id,id_key:"row_id")

    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["row_id"] = row_id

        dictionary["barcode"] = barcode
        dictionary["city"] = city
        dictionary["email"] = email
   
        dictionary["mobile"] = mobile
        dictionary["name"] = name
        dictionary["phone"] = remove_phone_formate(for:phone)
        //        dictionary["property_account_position_id"] = propertyAccountPositionId
        dictionary["street"] = street
        dictionary["__last_update"] = __last_update
        dictionary["zip"] = zip
        dictionary["vat"] = vat
        dictionary["image"] = image
        dictionary["country_Id"] = country_Id
        dictionary["country_name"] = country_name
        dictionary["l10n_sa_edi_building_number"] = l10n_sa_edi_building_number
        dictionary["l10n_sa_edi_plot_identification"] = l10n_sa_edi_plot_identification
        dictionary["state_id_name"] = state_id_name

        //      dictionary["pending_id"] = pending_id
        //        dictionary["pending_order_id"] = pending_order_id
        //        dictionary["pending_id_server"] = pending_id_server
        //        dictionary["pending_key"] = pending_key
        
        dictionary["property_product_pricelist_id"] = property_product_pricelist_id
        dictionary["property_product_pricelist_name"] = property_product_pricelist_name
        
        dictionary["discount_program_id"] = discount_program_id
        
        dictionary["loyalty_points_remaining"] = loyalty_points_remaining
        dictionary["loyalty_amount_remaining"] = loyalty_amount_remaining

        dictionary["blacklist"] = blacklist

        dictionary["website"] = website
        dictionary["function"] = function
        dictionary["street2"] = street2
        dictionary["building_no"] = building_no
        dictionary["district"] = district
        dictionary["additional_no"] = additional_no
        dictionary["other_id"] = other_id
        dictionary["active"] = active
        dictionary["pos_delivery_area_id"] = pos_delivery_area_id
        dictionary["pos_delivery_area_name"] = pos_delivery_area_name
        dictionary["row_parent_id"] = row_parent_id
        dictionary["parent_id"] = parent_id
        dictionary["parent_name"] = parent_name
        dictionary["parent_partner_id"] = parent_partner_id
        dictionary["res_partner_id"] = res_partner_id

        return dictionary
    }
    
    
    func save(temp:Bool = false)
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.row_id
        
        
  if temp
  {
      dbClass!.table_name =  "temp_" + dbClass!.table_name
  }
        
        self.row_id =  dbClass!.save()
        
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = res_partner_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
     _ =   cls.dbClass!.runSqlStatament(sql: "delete from \(table) where id != 0")
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = res_partner_class(fromDictionary: item)
            pos.dbClass?.insertId = false
            pos.save(temp: temp)
        }
    }
    static func mainPartnerSql()->String{
        return " (row_parent_id = 0 or  row_parent_id is null) and (parent_id = 0 or parent_id is null) "
    }
    static func getAll(active:Bool? = true) ->  [[String:Any]] {
        var queryActive = ""
        if let active =  active , active{
            queryActive = "where (active in (1) OR active IS NULL) and \(res_partner_class.mainPartnerSql())"
        }
        let cls = res_partner_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: queryActive)
        return arr
        
    }
    static func get(page:Int,limit:Int = 30) ->  [[String:Any]] {
        var queryActive = "where (active in (1) OR active IS NULL) and \(res_partner_class.mainPartnerSql())"
        let start = page * limit
        queryActive = String(format: "%@ LIMIT %d,%d", queryActive ,start, limit)
        
       
        let cls = res_partner_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: queryActive)
        return arr
        
    }
    static func search(by word:String, page:Int,limit:Int = 30) ->  [[String:Any]] {
        let start = page * limit

        var sql = """
SELECT * FROM (
SELECT * FROM res_partner WHERE phone like '%\(word)%' and \(res_partner_class.mainPartnerSql())
          UNION
SELECT * FROM res_partner WHERE email like '%\(word)%' and \(res_partner_class.mainPartnerSql())
          UNION
SELECT * FROM res_partner WHERE name like '%\(word)%') where (active in (1) OR active IS NULL) and \(res_partner_class.mainPartnerSql())

"""
        sql = String(format: "%@ LIMIT %d,%d ;", sql ,start, limit)
        
       
        let cls = res_partner_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(sql: sql)
        return arr
        
    }
    static func getResPartner(partner_id:Int?)-> res_partner_class?
    {
        if partner_id != nil
        {
            
            
            let cls = res_partner_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   res_partner_id = " + String(partner_id!))
            if row !=  nil
            {
                let temp:res_partner_class = res_partner_class(fromDictionary: row!  )
                return temp
            }else{
                return res_partner_class.get(res_partner_id:partner_id)
            }
        }
        return nil
    }
    
    static func get(partner_id:Int?)-> res_partner_class?
    {
        if partner_id != nil
        {
            
            
            let cls = res_partner_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where id = \(partner_id!)"  )
            if row !=  nil
            {
                let temp:res_partner_class = res_partner_class(fromDictionary: row!  )
                return temp
            }else{
                return res_partner_class.get(res_partner_id:partner_id!)
            }
        }
        return nil
    }
    static func get(res_partner_id:Int?)-> res_partner_class?
    {
        if res_partner_id != nil
        {
            
            
            let cls = res_partner_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   res_partner_id = \(res_partner_id!)" )
            if row !=  nil
            {
                let temp:res_partner_class = res_partner_class(fromDictionary: row!  )
                return temp
            }
        }
        return nil
    }
    
   
    
    static func get(phone:String)-> res_partner_class?
    {
        
            
            
            let cls = res_partner_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   phone = '" + phone  + "'")
            if row !=  nil
            {
                let temp:res_partner_class = res_partner_class(fromDictionary: row!  )
                return temp
            }
        
        return nil
    }
    
    
    static func get(row_id:Int?)-> res_partner_class?
    {
        if row_id != nil
        {
            
            
            let cls = res_partner_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   row_id = " + String(row_id!))
            if row !=  nil
            {
                let temp:res_partner_class = res_partner_class(fromDictionary: row!  )
                return temp
            }
        }
        return nil
    }
    
    
    static func get_pendding()-> [res_partner_class]
    {
        var rows:[res_partner_class] = []
        
          let cls = res_partner_class(fromDictionary: [:])
           var arr  = cls.dbClass!.get_rows(whereSql: " where id = 0 and (row_parent_id = 0 or  row_parent_id is null) ")
        let arr2  = cls.dbClass!.get_rows(whereSql: " where id = 0 and parent_id != 0 and row_parent_id != 0")
        arr.append(contentsOf:arr2 )
        for item in arr
        {
            rows.append(res_partner_class(fromDictionary: item))
        }
        
        return rows
    }
    
    func remove_phone_formate(for phone:String)->String{
        var phoneString = phone.trimmingCharacters(in: .whitespaces)
        phoneString = phoneString.replacingOccurrences(of: "(", with: "")
        phoneString = phoneString.replacingOccurrences(of: ")", with: "")
        phoneString = phoneString.replacingOccurrences(of: "-", with: "")
        phoneString = phoneString.replacingOccurrences(of: "-", with: "")
        phoneString = phoneString.replacingOccurrences(of: " ", with: "")
        return phoneString
        
    }
    
    
    
}
