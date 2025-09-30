 
 import Foundation
 
 
 public class product_pricelist_class: NSObject {
    var dbClass:database_class?
    
    
    var id : Int?
    var name : String?
    var active : Bool?
    var sequence : Double?
    var discount_policy : String?
    //      var code : Bool?
    //      var selectable : Bool?
    //      var create_date : String?
    //      var write_date : String?
    var display_name : String?
    var __last_update : String?
     var deleted : Bool = false

    
    private var item_ids : [Int] = []
    //      var currency_id :[Any]?
    //      var company_id : [Any]?
    //      var country_group_ids : [Any]?
    //      var website_id : [Any]?
    //      var create_uid : [Any]?
    //      var write_uid : [Any]?
    
    
    
    
    
    
    
    init(fromDictionary dictionary: [String:Any] ) {
        
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
        
        name = dictionary.toString(key: "name")
        active = dictionary.toBool(key: "active")
        sequence = dictionary.toDouble (key: "sequence")
        discount_policy = dictionary.toString(key: "discount_policy")
        //        code = dictionary.toBool(key: "code")
        //        selectable = dictionary.toBool(key: "selectable")
        
        //        create_date = dictionary.toString(key: "create_date")
        //        write_date = dictionary.toString(key: "write_date")
        display_name = dictionary.toString(key: "display_name")
        __last_update = dictionary.toString(key: "__last_update")
        
        item_ids = dictionary["item_ids"] as? [Int] ?? []
        
        //        item_ids = dictionary.toArray(key: "item_ids")
        //        currency_id = dictionary.toArray(key: "currency_id")
        //        company_id = dictionary.toArray(key: "company_id")
        //        country_group_ids = dictionary.toArray(key: "country_group_ids")
        //        website_id = dictionary.toArray(key: "website_id")
        //        create_uid = dictionary.toArray(key: "create_uid")
        //        write_uid = dictionary.toArray(key: "write_uid")
        
        dbClass = database_class(table_name: "product_pricelist", dictionary: self.toDictionary(),id: id!,id_key:"id")

    }
    
    public func toDictionary() -> [String :Any] {
        
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.name, forKey: "name")
        dictionary.setValue(self.active, forKey: "active")
        dictionary.setValue(self.sequence, forKey: "sequence")
        dictionary.setValue(self.discount_policy, forKey: "discount_policy")
        //        dictionary.setValue(self.code, forKey: "code")
        //        dictionary.setValue(self.selectable, forKey: "selectable")
        //        dictionary.setValue(self.create_date, forKey: "create_date")
        //        dictionary.setValue(self.write_date, forKey: "write_date")
        dictionary.setValue(self.display_name, forKey: "display_name")
        dictionary.setValue(self.__last_update, forKey: "__last_update")
        dictionary.setValue(self.deleted, forKey: "deleted")

        
        //        dictionary.setValue(self.item_ids, forKey: "item_ids")
        //        dictionary.setValue(self.currency_id, forKey: "currency_id")
        //        dictionary.setValue(self.company_id, forKey: "company_id")
        //        dictionary.setValue(self.country_group_ids, forKey: "country_group_ids")
        //        dictionary.setValue(self.website_id, forKey: "website_id")
        //        dictionary.setValue(self.create_uid, forKey: "create_uid")
        //        dictionary.setValue(self.write_uid, forKey: "write_uid")
        
        return dictionary as! [String : Any]
    }
    
    
    static func reset(temp:Bool = false)
    {
        let cls = product_pricelist_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")
         relations_database_class.reset(  re_table1_table2: "product_pricelist|product_pricelist_item")

//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
//
//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='product_pricelist|product_pricelist_item' ")
//
        
    }
    
    func save(temp:Bool = false)
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id!
        
        if temp
        {
            dbClass!.table_name =  "temp_" + dbClass!.table_name
        }
        
        _ =  dbClass!.save()
        
        
        
        relations_database_class(re_id1: self.id!, re_id2: item_ids, re_table1_table2: "product_pricelist|product_pricelist_item").save()
        
    }
    func get_item_ids() -> [Int]
      {
          return dbClass?.get_relations_rows(re_id1: self.id!, re_table1_table2: "product_pricelist|product_pricelist_item") ?? []
      }
    
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = product_pricelist_class(fromDictionary: item)
            pos.deleted = false
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
     static func getAll(deleted:Bool? = nil) ->  [[String:Any]] {
        
        let cls = product_pricelist_class(fromDictionary: [:])
         var sql = ""
         if let deleted = deleted{
             sql += "where product_pricelist.deleted = \(deleted ? 1:0)"
         }
        let arr  = cls.dbClass!.get_rows(whereSql: sql)
        return arr
        
    }
    
    static func getAll(deleted:Bool? = nil) -> [product_pricelist_class] {
        
        
        
        let  pos = SharedManager.shared.posConfig()
        let available_pricelist_ids = pos.available_pricelist_ids
        let arr:[[String:Any]] = product_pricelist_class.getAll(deleted:deleted) //api.get_last_cash_result(keyCash:"get_product_pricelist")
        var list_products :[product_pricelist_class] = []
        
        for item in arr
        {
            let cls:product_pricelist_class = product_pricelist_class(fromDictionary: item  )
            
            if available_pricelist_ids.firstIndex(of: cls.id ?? 0) != nil {
                list_products.append(cls)
            }
            
        }
        
        
        return  list_products
    }
    
    
    
    static func getDefault()-> product_pricelist_class?
    {
        
        
        let  pos = SharedManager.shared.posConfig()
        if pos.pricelist_id != nil
        {
            return product_pricelist_class.get_pricelist(pricelist_id: pos.pricelist_id!)
        }
        
        return nil
    }
    
    
    static func get_pricelist(pricelist_id:Int?)-> product_pricelist_class?
    {
        if pricelist_id != nil
        {
                 let cls = product_pricelist_class(fromDictionary: [:])
                  let row  = cls.dbClass!.get_row(whereSql: " where id = " + String(pricelist_id!) + " and deleted = 0" )
                 if row !=  nil
                 {
                   let temp:product_pricelist_class = product_pricelist_class(fromDictionary: row!  )
                   return temp
                 }
            
        }
 
        
        
        return nil
    }
    
 }
