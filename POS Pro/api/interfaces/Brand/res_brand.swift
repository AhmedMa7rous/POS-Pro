//
//  res_brand.swift
//  pos
//
//  Created by M-Wageh on 16/01/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
/*
 "footer": "<p>sdf g sdf gsdfg sdffg sdfgdsfg sdffgsdfg<br></p>",
 "write_date": "2022-01-04 15:21:45",
 "register_name": "asdasdwfasdfasdf",
 "product_category_ids": [
 4
 ],
 "display_name": "Test brand",
 "journal_ids": [],
 "__last_update": "2022-01-04 15:21:45",
 "user_ids": [],
 "logo": "",
 "warehouse_ids": [
 1
 ],
 "tax_id": "45345345345345345",
 "id": 1,
 "header": "<p>sdfs f gsdfg sdfg sdf<br></p>",
 "telephone": "asdasd",
 "name": "Test brand",
 "pos_ids": [
 1,
 2,
 5
 ],
 "company_id": [
 1,
 "مطاعم القنديل الذهبي"
 ],
 "pos_category_ids": [
 9,
 7
 ],
 "create_date": "2022-01-04 15:21:45",
 "address": "dfgdfgdfg"
 }
 **/
class res_brand_class: NSObject {
    var dbClass:database_class?
    var id: Int = 0
    var logo, display_name, header, tax_id, telephone,
        name , footer, write_date, register_name,__last_update,
        create_date, address,email,website,currency_name,company_name: String?
    var company_id,currency_id:Int?
    
    var product_category_ids: [Int]?
    var journal_ids: [Int]?
    var pos_ids: [Int]?
    var pos_category_ids: [Int]?
    var is_select: Bool = false
    
    override init()
    {
        
    }
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        id = dictionary["id"] as? Int ?? 0
        if let base64String = dictionary["logo"] as? String, !base64String.isEmpty {
            let name_Image = "\(id)" + ".png"
            if base64String != name_Image{
                self.logo = name_Image
                FileMangerHelper.shared.saveBase64AsImage(base64String, in :.res_brand,with:name_Image)
            }else{
                logo = name_Image
            }
        }else{
            logo = ""
        }
        display_name = dictionary["display_name"] as? String ?? ""
        header = dictionary["header"] as? String ?? ""
        tax_id = dictionary["tax_id"] as? String ?? ""
        telephone = dictionary["telephone"] as? String ?? ""
        name = dictionary["name"] as? String ?? ""
        footer = dictionary["footer"] as? String ?? ""
        write_date = dictionary["write_date"] as? String ?? ""
        register_name = dictionary["register_name"] as? String ?? ""
        email = dictionary["email"] as? String ?? ""
        website = dictionary["email"] as? String ?? ""
        
        __last_update = dictionary["__last_update"] as? String ?? ""
        create_date = dictionary["create_date"] as? String ?? ""
        address = dictionary["address"] as? String ?? ""
        product_category_ids = dictionary["product_category_ids"] as? [Int] ?? []
        journal_ids = dictionary["journal_ids"] as? [Int] ?? []
        pos_ids = dictionary["pos_ids"] as? [Int] ?? []
        pos_category_ids = dictionary["pos_category_ids"] as? [Int] ?? []
        is_select = dictionary["is_select"] as? Bool ?? is_select

        currency_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "currency_id", keyOfDatabase: "currency_id",Index: 0) as? Int ?? 0
        currency_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "currency_id", keyOfDatabase: "currency_name",Index: 1)as? String  ?? ""

        company_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "company_id", keyOfDatabase: "company_name",Index: 1)as? String
        company_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "company_id", keyOfDatabase: "company_id",Index: 0)as? Int
        dbClass = database_class(table_name: "res_brand", dictionary: self.toDictionary(),id: id,id_key:"id")
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["logo"] = logo
        dictionary["name"] = name
        dictionary["display_name"] = display_name
        dictionary["header"] = header
        dictionary["tax_id"] = tax_id
        dictionary["telephone"] = telephone
        dictionary["footer"] = footer
        dictionary["write_date"] = write_date
        dictionary["register_name"] = register_name
        dictionary["create_date"] = create_date
        dictionary["__last_update"] = __last_update
        dictionary["address"] = address
        dictionary["company_name"] = company_name
        dictionary["company_id"] = company_id
        dictionary["email"] = email
        dictionary["website"] = website
        dictionary["currency_name"] = currency_name
        dictionary["currency_name"] = currency_name

        dictionary["product_category_ids"] = product_category_ids
        dictionary["journal_ids"] = journal_ids
        dictionary["pos_ids"] = pos_ids
        dictionary["pos_category_ids"] = pos_category_ids
        dictionary["is_select"] = is_select

        return baseClass.fillterProperties(dictionary: dictionary, excludeProperties: ["product_category_ids","journal_ids","pos_ids","pos_category_ids"])
        
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = res_brand_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
        if temp
        {
            table =   "temp_" + cls.dbClass!.table_name
        }
        
        _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='res_brand|product_category_ids' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='res_brand|journal_ids' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='res_brand|pos_ids' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='res_brand|pos_category_ids' ")
        
    }
    
    
    func save(temp:Bool = false)
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        
        if temp
        {
            dbClass!.table_name =  "temp_" + dbClass!.table_name
        }
        
        _ =  dbClass!.save()
        
        relations_database_class(re_id1: self.id, re_id2: product_category_ids ?? [], re_table1_table2: "res_brand|product_category_ids").save()
        relations_database_class(re_id1: self.id, re_id2: journal_ids ?? [], re_table1_table2: "res_brand|journal_ids").save()
        relations_database_class(re_id1: self.id, re_id2: pos_ids ?? [], re_table1_table2: "res_brand|pos_ids").save()
        relations_database_class(re_id1: self.id, re_id2: pos_category_ids ?? [], re_table1_table2: "res_brand|pos_category_ids").save()
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = res_brand_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func get_brand(id:Int? = nil,isSelected:Bool? = nil) ->res_brand_class
    {
        var cls = res_brand_class(fromDictionary: [:])
        var whereQury:[String] = []
        if let id = id {
            whereQury.append("id = \(id)")
        }
        if let isSelected = isSelected {
            whereQury.append("is_select = \(isSelected)")
        }
        let  whereSql = whereQury.count > 0 ?  ("where " + whereQury.joined(separator: " ")) : ""
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: whereSql)
        if row != nil
        {
            cls = res_brand_class(fromDictionary: row!)
            cls.product_category_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "res_brand|product_category_ids")
            cls.journal_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "res_brand|journal_ids")
            cls.pos_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "res_brand|pos_ids")
            cls.pos_category_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "res_brand|pos_category_ids")
        }
        return cls
    }
    
    static func getAll() ->  [[String:Any]] {
        let cls = res_brand_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
    }
    static func getAllObject() ->  [res_brand_class] {
        let cls = res_brand_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr.map({res_brand_class(fromDictionary: $0)}) 
    }
    static func setDefultSelect(){
        if let posDeafultBrand = SharedManager.shared.posConfig().brand_id{
            self.setSelected(brandID:posDeafultBrand)
        }
    }
    static func getSelectedBrandIfEnableSetting() -> res_brand_class?{
        if SharedManager.shared.appSetting().enable_cloud_kitchen != enable_cloud_kitchen_option.DISABLE {
            if SharedManager.shared.posConfig().cloud_kitchen.count > 0 {
                let defaultBrand = res_brand_class.get_brand(isSelected: true)
                if defaultBrand.id != 0 {
                    return defaultBrand
                }
            }
        }
        return nil
    }
    static func setSelected(brandID:Int)
       {
           getAllObject().forEach { brand in
               brand.is_select = brand.id == brandID
               brand.save()
           }
       
      }
}
