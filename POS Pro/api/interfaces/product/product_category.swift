 
import Foundation
 

public class product_category {
    
	public var id : Int   = 0
    public var name : String = ""
    public var display_name : String = ""

    public var parent_id : [Any] = []
    public var child_id : [Any] = []
 
    
	init(fromDictionary dictionary: [String:Any]) {

		id = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
        display_name = dictionary["display_name"] as? String ?? ""
        parent_id = dictionary["parent_id"] as? [Any] ?? []
        child_id = dictionary["child_id"] as? [Any]  ?? []

		 
        
	}

	public func toDictionary() -> [String:Any] {

        var dictionary:[String:Any] = [:]
         dictionary["id"] = self.id
        dictionary["name"] = self.name
        dictionary["display_name"] = self.display_name
        dictionary["parent_id"] = self.parent_id
        dictionary["child_id"] = self.child_id

 
        

		return dictionary
	}
    
    static func saveAll(array : [Any])
    {
        let className:String = "product_category"
        
//        myuserdefaults.setitems("product_category", setValue:array, prefix: className)
        
    }
    
    static func getLocal() -> [product_category] {
        let className:String = "product_category"

        let arr :[Any] = [] //= myuserdefaults.getitem("product_category", prefix: className) as? [Any] ?? []
        var list:[product_category] = []
        
        for item in arr
        {
            let cls:product_category = product_category(fromDictionary: item as! [String : Any]  )
            list.append (cls)
        }
        
        
        return list
    }
    
    static func get_sub_category(parent_id:Int) -> [Any]
    {
        let categ_ids_sub = product_category.getLocal()
        
        for item:product_category in categ_ids_sub
        {
             if item.id == parent_id
             {
                return item.child_id
            }
        }

        return []
    }
    
    
    
}
