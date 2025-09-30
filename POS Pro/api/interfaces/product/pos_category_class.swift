//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class pos_category_class: NSObject {
    var dbClass:database_class?

    
    var id : Int = 0
    
    var name_temp:String?
    
    var name : String
    {
        get
        {
            if LanguageManager.currentLang() == .ar
            {
                if self.name_ar.isEmpty
                {
                    return name_temp ?? ""
                }
                
                return self.name_ar
            }
            else
            {
      
                return name_temp ?? "";
            }
         }
        
        set
        {
            name_temp = newValue
       }
         
    }
    var name_ar : String = ""
    var image : String = ""
    var __last_update : String = ""
    var sequence : Int = 0
    var display_name : String = ""
    var invisible_in_ui : Bool = false
    
    
    var parent_id :Int?
    var parent_name :String?

    var child_id : [Int] = []
  
    var brand_id :Int?
    var brand_name :String?
 

    override init() {
         super.init()
    }
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
         super.init()
        
         id = dictionary["id"] as? Int ?? 0
        

        
        
         name = dictionary["name"] as? String ?? ""
         name_ar = dictionary["name_ar"] as? String ?? ""

         __last_update = dictionary["__last_update"] as? String ?? ""
       
        
        sequence = dictionary["sequence"] as? Int ?? 0
        display_name = dictionary["display_name"] as? String ?? ""
        invisible_in_ui = dictionary["invisible_in_ui"] as? Bool ?? false

 
//        parent_id = (dictionary["parent_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        parent_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "parent_id", keyOfDatabase: "parent_id",Index: 0) as? Int ?? 0

        parent_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "parent_id", keyOfDatabase: "parent_name",Index: 1)as? String  ?? ""
        
        brand_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "brand_id", keyOfDatabase: "brand_id",Index: 0) as? Int
        if let base64String = dictionary["image"] as? String, !base64String.isEmpty {
            var name_Image = "\(id)"
            if let brandID = brand_id , brandID != 0 {
                name_Image += "_\(brandID)"
            }
            name_Image += ".png"
            if base64String != name_Image{
                self.image = name_Image
                FileMangerHelper.shared.saveBase64AsImage(base64String, in :.pos_category,with:name_Image)
            }else{
                image = name_Image
            }
        }else{
            image = ""
        }

        brand_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "brand_id", keyOfDatabase: "brand_name",Index: 1)as? String
        child_id = dictionary["child_id"] as? [Int] ?? []

  dbClass = database_class(table_name: "pos_category", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
//    func getLevel() -> Int {
//
////        if parent_id.count > 0 {
////            let path = parent_id[1] as? String ?? ""
////            let split = path.split(separator: "/")
////            return split.count
////        }
//        return parent_id ?? 0
//    }
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["__last_update"] = __last_update
        dictionary["image"] = image
        dictionary["sequence"] = sequence
        dictionary["display_name"] = display_name
        dictionary["parent_id"] = parent_id
        dictionary["parent_name"] = parent_name
        dictionary["child_id"] = child_id
        dictionary["invisible_in_ui"] = invisible_in_ui
        dictionary["brand_id"] = brand_id
        dictionary["brand_name"] = brand_name

        
        
        return baseClass.fillterProperties(dictionary: dictionary, excludeProperties: ["child_id"])
    }
    
    func getChildIds() ->[Int]
    {
       return  dbClass?.get_relations_rows(re_id1:  id, re_table1_table2: "pos_category|child_id") ?? []
    }
    
    static func getAll() ->  [[String:Any]] {
                    
            let cls = pos_category_class(fromDictionary: [:])
//             let arr  = cls.dbClass!.get_rows(whereSql: " where invisible_in_ui=0")
        var brand_option = ""
        if let brand_id = SharedManager.shared.selected_pos_brand_id {
            brand_option = "and ( pos_category.brand_id  is null or pos_category.brand_id = \(brand_id) ) "
        }
        let sql = """
                SELECT IfNULL (ir_translation.value,pos_category.name) as name_ar ,pos_category.* from pos_category
                left join (select * from ir_translation where  (ir_translation.name = 'pos.category,name' and lang = 'ar_001') or (ir_translation.name = 'pos.category,name' and lang = 'ar_SA') )  as ir_translation
                on ir_translation.res_id  = pos_category.id \(brand_option)
        """
//        let pos_query = pos_config_class.get_categories_excluded_query()
//        if !pos_query.isEmpty {
//            sql +=  " where " + pos_query.replacingOccurrences(of: "and", with: "")
//        }
        let arr  = cls.dbClass!.get_rows(sql: sql)

            return arr
    
      }
    
  static  func   getCategoryTopLevel() -> [Any] {

    let cls = pos_category_class(fromDictionary: [:])
      var brand_option = ""
      if let brand_id = SharedManager.shared.selected_pos_brand_id {
          brand_option = "and ( pos_category.brand_id  is null or pos_category.brand_id = \(brand_id) ) "
      }
    let sql = """
            SELECT IfNULL (ir_translation.value,pos_category.name) as name_ar ,pos_category.* from pos_category
            left join (select * from ir_translation where  (ir_translation.name = 'pos.category,name' and lang = 'ar_001') or (ir_translation.name = 'pos.category,name' and lang = 'ar_SA') )  as ir_translation
            on ir_translation.res_id  = pos_category.id
            where parent_id = 0  and invisible_in_ui=0 \(brand_option) order by sequence asc,id

    """
//     let arr  = cls.dbClass!.get_rows(whereSql: "where parent_id = 0  and invisible_in_ui=0 order by sequence asc")
   
         let arr  = cls.dbClass!.get_rows(sql: sql)

      return arr

    
    }
    
    
    
     static func get(id:Int) ->pos_category_class
           {
            
            let cls = pos_category_class(fromDictionary: [:])
        
           let sql = """
                SELECT IfNULL (ir_translation.value,pos_category.name) as name_ar ,pos_category.* from pos_category
                left join (select * from ir_translation where  (ir_translation.name = 'pos.category,name' and lang = 'ar_001') or (ir_translation.name = 'pos.category,name' and lang = 'ar_SA') )  as ir_translation
                on ir_translation.res_id  = pos_category.id
                where pos_category.id = \(id)

                """
        
        
        let dic  = cls.dbClass!.get_row(sql: sql  ) ?? [:]

            return pos_category_class(fromDictionary: dic)
           }
    
    static func get(ids:[Int]) -> [[String : Any]]
          {
        
        let ids_str:String = ids.toString() ?? ""
       
        
           
           let cls = pos_category_class(fromDictionary: [:])
       
          let sql = """
               SELECT IfNULL (ir_translation.value,pos_category.name) as name_ar ,pos_category.* from pos_category
               left join (select * from ir_translation where  (ir_translation.name = 'pos.category,name' and lang = 'ar_001') or (ir_translation.name = 'pos.category,name' and lang = 'ar_SA') )  as ir_translation
               on ir_translation.res_id  = pos_category.id
               where pos_category.id in (\(ids_str))

               """
       
        let arr  = cls.dbClass!.get_rows(sql: sql  )

           return arr
     }
    
    static func get_up_category(parent_id:Int) ->pos_category_class?
    {
        
        let cls = pos_category_class(fromDictionary: [:])
        let sql = """
             SELECT IfNULL (ir_translation.value,pos_category.name) as name_ar ,pos_category.* from pos_category
             left join (select * from ir_translation where  (ir_translation.name = 'pos.category,name' and lang = 'ar_001') or (ir_translation.name = 'pos.category,name' and lang = 'ar_SA') )  as ir_translation
             on ir_translation.res_id  = pos_category.id
             where pos_category.id = \(parent_id)

             """
//        let dic  = cls.dbClass!.get_row(whereSql: " where id = " + String(parent_id)  )
        let dic  = cls.dbClass!.get_row(sql: sql  )

        if dic == nil
        {
            return nil
        }
        
        return pos_category_class(fromDictionary: dic!)
    }
    
    
    static func get_sub_category(parent_id:Int) -> [[String : Any]]
       {
        
        let cls = pos_category_class(fromDictionary: [:])
        
        let sql = """
                SELECT IfNULL (ir_translation.value,pos_category.name) as name_ar ,pos_category.* from pos_category
                left join (select * from ir_translation where  (ir_translation.name = 'pos.category,name' and lang = 'ar_001') or (ir_translation.name = 'pos.category,name' and lang = 'ar_SA') )  as ir_translation
                on ir_translation.res_id  = pos_category.id
                where pos_category.parent_id = \(parent_id) and pos_category.invisible_in_ui=0 order by sequence asc,id
        """
        
//            let arr  = cls.dbClass!.get_rows(whereSql: " where parent_id = " + String(parent_id) + " and invisible_in_ui=0 order by sequence asc")
        let arr  = cls.dbClass!.get_rows(sql: sql)

           return arr
        
 
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
             
            relations_database_class(re_id1: self.id, re_id2: child_id, re_table1_table2: "pos_category|child_id").save()
 
         
            
        }
        
       static func saveAll(arr:[[String:Any]],temp:Bool = false)
        {
            
            for item in arr
            {
                let cls = pos_category_class(fromDictionary: item)
                SharedManager.shared.pos_categ_ids.append(cls.id)
                cls.dbClass?.insertId = true
                cls.save(temp: temp)
            }
        }
    
    static func reset(temp:Bool = false)
     {
        let cls = pos_category_class(fromDictionary: [:])

        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set invisible_in_ui = 1")
    }
    static func resetBrandId(with brand_id:Int)
       {
       let table = "pos_category"
        let cls = product_product_class(fromDictionary: [:])
        let ids =   cls.dbClass!.get_ids(sql: "Select id from \(table) where brand_id = \(brand_id)")
           if ids.count <= 0 {
               return
           }
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set invisible_in_ui = 1 where brand_id = \(brand_id)")
    }
    
//    static func create_temp()  {
//        let cls = pos_category_class(fromDictionary: [:])
//
//        _ =   cls.dbClass!.runSqlStatament(sql: "DROP TABLE IF EXISTS temp_\(cls.dbClass!.table_name)")
//
//         let sql = " CREATE   TABLE temp_\(cls.dbClass!.table_name) AS select * from \(cls.dbClass!.table_name)"
//        _ =   cls.dbClass!.runSqlStatament(sql: sql)
//    }
//
//    static func copy_temp()  {
//
//        let table = "pos_category"
//
//        let sql = """
//            PRAGMA foreign_keys=off;
//
//            BEGIN TRANSACTION;
//
//            ALTER TABLE \(table) RENAME TO old_\(table);
//
//            ALTER TABLE temp_\(table) RENAME TO \(table);
//
//            DROP TABLE IF EXISTS old_\(table);
//
//            COMMIT;
//
//            PRAGMA foreign_keys=on;
//
//            """
//
//        let cls = pos_category_class(fromDictionary: [:])
//       _ =   cls.dbClass!.runSqlStatament(sql: sql)
//
//    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
