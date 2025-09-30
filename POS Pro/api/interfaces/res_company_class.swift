//
//  resCompanyClass.swift
//  pos
//
//  Created by khaled on 10/23/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation

class res_company_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var name : String = ""
    var email : String = ""
    var phone : String = ""
    var logo : String = ""
    var website : String = ""
    var vat : String = ""
    var company_registry : String = ""
    var __last_update : String?
    
    var currency_id : Int = 0
    var currency_name :String = ""
    var deleted : Bool = false
    var account_sale_tax_id:Int?
    var account_sale_tax_name:String?
    
    var l10n_sa_edi_building_number:String?
    var l10n_sa_edi_plot_identification:String?
    var street:String?
    var state_id_name:String?
    var city:String?
    var zip:String?
    var country_name:String = "Saudi Arabia"
    var country_code:String = "SA"
    
    var l10n_sa_private_key:String?
    var l10n_sa_additional_identification_scheme:String?
    var l10n_sa_additional_identification_number:String?


    
    //    var currency:currenciesClass =  currenciesClass()
    
    
    
    
    override init()
    {
        
    }
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
        
        
        name = dictionary["name"] as? String ?? ""
        email = dictionary["email"] as? String ?? ""
        phone = dictionary["phone"] as? String ?? ""
        if let base64String = dictionary["logo"] as? String, !base64String.isEmpty {
            let name_Image = "\(id)" + ".png"
            if base64String != name_Image{
                self.logo = name_Image
                FileMangerHelper.shared.saveBase64AsImage(base64String, in :.res_company,with:name_Image)
            }else{
                logo = name_Image
            }
        }else{
            logo = ""
        }
        website = dictionary["website"] as? String ?? ""
        vat = dictionary["vat"] as? String ?? ""
        company_registry = dictionary["company_registry"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        
        l10n_sa_edi_building_number = dictionary["l10n_sa_edi_building_number"] as? String ?? ""
        l10n_sa_edi_plot_identification = dictionary["l10n_sa_edi_plot_identification"] as? String ?? ""
        street = dictionary["street"] as? String ?? ""
        state_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "state_id", keyOfDatabase: "state_id",Index: 1)as? String  ?? ""
        city = dictionary["city"] as? String ?? ""
        zip = dictionary["zip"] as? String ?? ""
        country_name = dictionary["country_name"] as? String ?? "Saudi Arabia"
        country_code = dictionary["country_code"] as? String ?? "SA"
        l10n_sa_private_key = dictionary["l10n_sa_private_key"] as? String
        l10n_sa_additional_identification_scheme = dictionary["l10n_sa_additional_identification_scheme"] as? String
        l10n_sa_additional_identification_number = dictionary["l10n_sa_additional_identification_number"] as? String

        
//        currency_id = dictionary["currency_id"] as? Int  ?? 0
        currency_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "currency_id", keyOfDatabase: "currency_id",Index: 0) as? Int ?? 0
        currency_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "currency_id", keyOfDatabase: "currency_name",Index: 1)as? String  ?? ""
        
        account_sale_tax_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "account_sale_tax_id", keyOfDatabase: "account_sale_tax_id",Index: 0) as? Int ?? 0
        account_sale_tax_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "account_sale_tax_id", keyOfDatabase: "account_sale_tax_name",Index: 1)as? String  ?? ""

        
        //        let currency_dic =  dictionary["currency"]
        //        if currency_dic != nil
        //        {
        //            currency = currenciesClass(fromDictionary: currency_dic as! [String : Any])
        //        }
        dbClass = database_class(table_name: "res_company", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["email"] = email
        dictionary["phone"] = phone
        dictionary["logo"] = logo
        dictionary["website"] = website
        dictionary["vat"] = vat
        dictionary["company_registry"] = company_registry
        dictionary["currency_id"] = currency_id
        dictionary["currency_name"] = currency_name
        dictionary["__last_update"] = __last_update
        dictionary["deleted"] = deleted
        dictionary["account_sale_tax_id"] = account_sale_tax_id
        dictionary["account_sale_tax_name"] = account_sale_tax_name

        dictionary["l10n_sa_edi_building_number"] = l10n_sa_edi_building_number
        dictionary["l10n_sa_edi_plot_identification"] = l10n_sa_edi_plot_identification
        dictionary["street"] = street
        dictionary["state_id_name"] = state_id_name
        dictionary["city"] = city
        dictionary["zip"] = zip
        dictionary["country_name"] = country_name
        dictionary["country_code"] = country_code
        dictionary["l10n_sa_private_key"] = l10n_sa_private_key
        dictionary["l10n_sa_additional_identification_scheme"] = l10n_sa_additional_identification_scheme
        dictionary["l10n_sa_additional_identification_number"] = l10n_sa_additional_identification_number

        //            dictionary["currency"] = currency.toDictionary()
        
        return dictionary
        
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = res_company_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")

//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
 
        
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
        
        
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = res_company_class(fromDictionary: item)
            pos.deleted = false
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
   static func get_company(id:Int) ->res_company_class
    {
            var cls = res_company_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where id = \(id)")
        if row != nil
             {
         cls = res_company_class(fromDictionary: row!)
        }
        
        return cls
    }
    
    
    func currency() ->res_currency_class
    {
        var cls = res_currency_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where id = \(self.currency_id)")
        if row != nil
             {
        cls = res_currency_class(fromDictionary: row!)
        }
        
        return cls
    }
    
    static func getAll() ->  [[String:Any]] {
          
          let cls = res_company_class(fromDictionary: [:])
          let arr  = cls.dbClass!.get_rows(whereSql: "")
          return arr
          
      }
    convenience init(from brand:res_brand_class,company:res_company_class){
        self.init()
        self.id = brand.id
        if (brand.register_name ?? "").isEmpty{
            if (brand.name ?? "").isEmpty {
                self.name = company.name
            }else{
                self.name = brand.name ?? ""
            }
        }else{
            self.name = brand.register_name ?? ""
        }
        if (brand.email ?? "").isEmpty {
            self.email = company.email
        }else{
            self.email = brand.email ?? ""
        }
        
        if (brand.telephone ?? "").isEmpty {
            self.phone = company.phone
        }else{
            self.phone = brand.telephone ?? ""
        }
        
        if (brand.logo ?? "").isEmpty {
            self.logo = company.logo
        }else{
            self.logo = brand.logo ?? ""
        }
        if (brand.website ?? "").isEmpty {
            self.website = company.website
        }else{
            self.website = brand.website ?? ""
        }
        if (brand.tax_id ?? "").isEmpty {
            self.vat = company.vat
        }else{
            self.vat = brand.tax_id ?? ""
        }
        if (brand.register_name ?? "").isEmpty {
            self.company_registry = company.company_registry
        }else{
            self.company_registry = brand.register_name ?? ""
        }
        if (brand.currency_name ?? "").isEmpty {
            self.currency_name = company.currency_name
        }else{
            self.currency_name = brand.currency_name ?? ""
        }
        if (brand.currency_id ?? 0) == 0 {
            self.currency_id = company.currency_id
        }else{
            self.currency_id = brand.currency_id ?? 0
        }
        self.__last_update = brand.__last_update
       
        self.l10n_sa_private_key = company.l10n_sa_private_key
        self.l10n_sa_edi_building_number = company.l10n_sa_edi_building_number
        self.l10n_sa_edi_plot_identification = company.l10n_sa_edi_plot_identification
        self.l10n_sa_additional_identification_number = company.l10n_sa_additional_identification_number
        self.l10n_sa_additional_identification_scheme = company.l10n_sa_additional_identification_scheme


    }
    
}
