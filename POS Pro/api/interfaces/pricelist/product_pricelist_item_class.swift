 
import Foundation
 

public class product_pricelist_item_class: NSObject {
    var dbClass:database_class?

	public var id : Int?
    
    //=======================================
    
    public var product_tmpl_id : Int?
    public var product_id :Int?
    public var categ_id : Int?
    public var base_pricelist_id : Int?
    public var pricelist_id : Int?
    public var currency_id :Int?

    //=======================================

    

	public var min_quantity : Double?
	public var applied_on : String?
	public var base : String?

	public var price_surcharge : Double?
	public var price_discount : Double?
	public var price_round : Double?
	public var price_min_margin : Double?
	public var price_max_margin : Double?
    
	public var company_id : Int?
	public var date_start : String?
	public var date_end : String?
	public var compute_price : String?
	public var fixed_price : Double?
	public var percent_price : Double?
  
	public var name : String?
	public var price : String?
	public var display_name : String?
	public var __last_update : String?
    public var deleted : Bool = false

    
    
	init(fromDictionary dictionary: [String:Any]) {

	
        super.init()
               
           id = dictionary["id"] as? Int ?? 0
               
        
//         product_tmpl_id = (dictionary["product_tmpl_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
//        product_id = (dictionary["product_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
//        categ_id = (dictionary["categ_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
//        pricelist_id = (dictionary["pricelist_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
//        base_pricelist_id = (dictionary["base_pricelist_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
//        currency_id = (dictionary["currency_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0

        product_tmpl_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_id",Index: 0) as? Int ?? 0
        product_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_id", keyOfDatabase: "product_id",Index: 0) as? Int ?? 0
        categ_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "categ_id", keyOfDatabase: "categ_id",Index: 0) as? Int ?? 0
        pricelist_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pricelist_id", keyOfDatabase: "pricelist_id",Index: 0) as? Int ?? 0
        base_pricelist_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "base_pricelist_id", keyOfDatabase: "base_pricelist_id",Index: 0) as? Int ?? 0
        currency_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "currency_id", keyOfDatabase: "currency_id",Index: 0) as? Int ?? 0

	 
         
		min_quantity = dictionary["min_quantity"] as? Double
		applied_on = dictionary["applied_on"] as? String
		base = dictionary["base"] as? String
 
		 
        
		price_surcharge = dictionary["price_surcharge"] as? Double
		price_discount = dictionary["price_discount"] as? Double
        price_round = dictionary["price_round"] as? Double
		price_min_margin = dictionary["price_min_margin"] as? Double
		price_max_margin = dictionary["price_max_margin"] as? Double
		company_id = dictionary["company_id"] as? Int
        
		 
        
        
		date_start = dictionary["date_start"] as? String
		date_end = dictionary["date_end"] as? String
		compute_price = dictionary["compute_price"] as? String
		fixed_price = dictionary["fixed_price"] as? Double
		percent_price = dictionary["percent_price"] as? Double
        
	 
		name = dictionary["name"] as? String
		price = dictionary["price"] as? String
		display_name = dictionary["display_name"] as? String
		__last_update = dictionary["__last_update"] as? String
        
        dbClass = database_class(table_name: "product_pricelist_item", dictionary: self.toDictionary(),id: id!,id_key:"id")

	}

	public func toDictionary() -> [String:Any]{

       var dictionary:[String:Any] = [:]
            
            dictionary["id"] = id
        dictionary["product_tmpl_id"] = product_tmpl_id
        dictionary["product_id"] = product_id
        dictionary["categ_id"] = categ_id
        dictionary["base_pricelist_id"] = base_pricelist_id
        dictionary["pricelist_id"] = pricelist_id
        dictionary["currency_id"] = currency_id
        dictionary["min_quantity"] = min_quantity
        dictionary["applied_on"] = applied_on
        dictionary["base"] = base
        dictionary["price_surcharge"] = price_surcharge
        dictionary["price_discount"] = price_discount
        dictionary["price_round"] = price_round
        dictionary["price_min_margin"] = price_min_margin
        dictionary["price_max_margin"] = price_max_margin
        dictionary["company_id"] = company_id
        dictionary["date_start"] = date_start
        dictionary["date_end"] = date_end
        dictionary["compute_price"] = compute_price
        dictionary["fixed_price"] = fixed_price
        dictionary["percent_price"] = percent_price
        dictionary["name"] = name
        dictionary["price"] = price
        dictionary["display_name"] = display_name
        dictionary["__last_update"] = __last_update
        dictionary["deleted"] = deleted


        

		return dictionary
	}
    
    static func reset(temp:Bool = false)
    {
        let cls = product_pricelist_item_class(fromDictionary: [:])
        
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
          dbClass?.id = self.id!
                     
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
                 let pos = product_pricelist_item_class(fromDictionary: item)
                 pos.deleted = false
                 pos.dbClass?.insertId = true
                 pos.save(temp: temp)
             }
         }
      
    static func getAll() ->  [[String:Any]] {
                       
                         let cls = product_pricelist_item_class(fromDictionary: [:])
                         let arr  = cls.dbClass!.get_rows(whereSql: "")
                        return arr
       
      }
    
    
    static func getAll() ->  [product_pricelist_item_class] {
//        let className:String = "product_pricelist_item"
        
          let cls = product_pricelist_item_class(fromDictionary: [:])
          let arr  = cls.dbClass!.get_rows(whereSql: "")
        
//        let arr :NSArray =  = myuserdefaults.getitem("product_pricelist_item", prefix: className) as! NSArray
        var list_products : [product_pricelist_item_class] = []
        
        for item in arr
        {
            let cls:product_pricelist_item_class = product_pricelist_item_class(fromDictionary: item  )
            list_products.append(cls)
        }
        
        
        return list_products
    }
    
    
    static func get(pricelist_id:Int) ->  [product_pricelist_item_class] {
    //        let className:String = "product_pricelist_item"
            
              let cls = product_pricelist_item_class(fromDictionary: [:])
              let arr  = cls.dbClass!.get_rows(whereSql: " where pricelist_id =\(pricelist_id)")
            
             var list_products : [product_pricelist_item_class] = []
            
            for item in arr
            {
                let cls:product_pricelist_item_class = product_pricelist_item_class(fromDictionary: item  )
                list_products.append(cls)
            }
            
            
            return list_products
        }
    
}
