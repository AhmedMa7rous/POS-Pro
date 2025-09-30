//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

enum Shape: String, Codable {
    case round = "round"
    case square = "square"
}

class restaurant_table_class: NSObject {
    var dbClass:database_class?
    
    var order_id : Int = 0
    var order_amount : Double = 0
    var uid : String?
    var sequence_number : Int?
    var create_user_id:Int?
    
    var create_date : String?
    
    var create_user_name: String?
    
    var id : Int = 0
    var name : String?
    var display_name : String?
    
    var floor_id : Int?
    var floor_name : String?
    
    var position_h : Double?
    var position_v : Double?
    var width : Double?
    var height : Double?
    
    var seats : Int?
    
    var update_postion:Bool?
    
    var active : Bool?
    
    var shape_str : String?
    var shape : Shape
    {
        get
        {
            if shape_str == "square"
            {
                return .square
            }
            
            return .round
        }
    }
    
    var color_str : String?
    var color:UIColor?
    {
        get
        {
            if !color_str!.isEmpty
            {
                if color_str!.starts(with: "#") == true
                {
                    return UIColor.init(hexFromString: color_str!)
                }
                else
                {
                    var col = color_str?.replacingOccurrences(of: "rgb(", with: "")
                    col = col?.replacingOccurrences(of: ")", with: "")
                    
                    let arr_color = col?.components(separatedBy: ",") ?? []
                    if arr_color.count == 3
                    {
                        let r_int = Double(arr_color[0].toInt() ?? 0)
                        let g_int = Double(arr_color[1].toInt() ?? 0)
                        let b_int = Double(arr_color[2].toInt() ?? 0)
                        
                        let r: CGFloat = CGFloat(r_int) / 255.0
                        let g: CGFloat = CGFloat(g_int) / 255.0
                        let b: CGFloat = CGFloat(b_int)  / 255.0
                        
                        return   UIColor(red: r, green: g, blue: b, alpha: 1.0)
                    }
                }
                
                
            }
            
            
            return #colorLiteral(red: 0.3019607843, green: 0.7450980392, blue: 0.4549019608, alpha: 1)
        }
        
    }
    var countOrders:Int?
    
    override init() {
        
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        order_id = dictionary["order_id"] as? Int ?? 0
        order_amount = dictionary["order_amount"] as? Double ?? 0.0

        uid = dictionary["uid"] as? String ?? ""
        //if SharedManager.shared.appSetting().enable_make_user_resposiblity_for_order{
            if let userName = dictionary["order_resp_name"] as? String , !userName.isEmpty {
                create_user_name = userName
                create_user_id = dictionary["order_resp_id"] as? Int
                
            }else{
                if let userName = dictionary["order_creator_name"] as? String{
                    create_user_name = userName

                }else{
                    create_user_name = SharedManager.shared.activeUser().name ?? ""
                }
                
                if let userID = dictionary["order_creator_id"] as? Int{
                    create_user_id = userID
                }else{
                    create_user_id = SharedManager.shared.activeUser().id
                }
//                create_user_name = dictionary["order_creator_name"] as? String ?? ""
//                create_user_id = dictionary["order_creator_id"] as? Int
                
                
            }
        /*
        }else{
            create_user_name = dictionary["order_creator_name"] as? String ?? ""
            create_user_id = dictionary["order_creator_id"] as? Int
            
        }
         */
        sequence_number = dictionary["order_number"] as? Int
        create_date = dictionary["create_date"] as? String ?? ""
        
        
        
        id = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
        display_name = dictionary["display_name"] as? String ?? ""
        shape_str = dictionary["shape"] as? String ?? ""
        
        position_h = dictionary["position_h"] as? Double ?? 0
        position_v = dictionary["position_v"] as? Double ?? 0
        width = dictionary["width"] as? Double ?? 0
        height = dictionary["height"] as? Double ?? 0
        
        seats = dictionary["seats"] as? Int ?? 0
        color_str = dictionary["color"] as? String ?? ""
        
        
        active = dictionary["active"] as? Bool ?? false
        
        update_postion = dictionary["update_postion"] as? Bool ?? false
        
        
        
        floor_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "floor_id", keyOfDatabase: "floor_id",Index: 0) as? Int ?? 0
        
        
        dbClass = database_class(table_name: "restaurant_table", dictionary: self.toDictionary(),id: id,id_key:"id")
        
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
//        dictionary["order_amount"] = order_amount
        dictionary["name"] = name
        dictionary["display_name"] = display_name
        dictionary["shape"] = shape_str
        dictionary["position_h"] = position_h
        dictionary["position_v"] = position_v
        dictionary["width"] = width
        dictionary["height"] = height
        dictionary["seats"] = seats
        dictionary["color"] = color_str
        dictionary["active"] = active
        dictionary["floor_id"] = floor_id
        dictionary["update_postion"] = update_postion
        
        return dictionary
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
    
    
    static func reset(temp:Bool = false)
    {
        let cls = restaurant_table_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
        if temp
        {
            table =   "temp_" + cls.dbClass!.table_name
        }
        
        _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = restaurant_table_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = restaurant_table_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    static func getUpdatedPostion() ->  [[String:Any]] {
        
        let cls = restaurant_table_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " where update_postion = 1")
        return arr
        
    }
    
    static func getWithOrders() ->  [[String:Any]] {
        
        let sql = """
          SELECT orders.id as order_id, orders.amount_total as order_amount , orders.uid,orders.create_date, orders.sequence_number as order_number, orders.write_user_id as order_creator_id, orders.write_user_name as order_creator_name, orders.table_control_by_user_name as order_resp_name, orders.table_control_by_user_id as order_resp_id,restaurant_table.*  from restaurant_table
            left  join (   select * from pos_order
             inner join pos_session
             on pos_order.session_id_local  = pos_session.id
             where is_closed  = 0  and is_void = 0 and pos_session.isOpen = 1) as orders
            on restaurant_table.id  = orders.table_id
        """
        let cls = restaurant_table_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(sql: sql)
        return arr
        
    }
    
    static func get(id:Int?)-> restaurant_table_class?
    {
        if id != nil
        {
            
            
            let cls = restaurant_table_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   id = " + String(id!))
            if row !=  nil
            {
                let temp:restaurant_table_class = restaurant_table_class(fromDictionary: row!  )
                return temp
            }
        }
        return nil
    }
    func getCountOrder( complete:@escaping (Int)->()){
        DispatchQueue.global(qos: .background).async {
        let activeSession = pos_session_class.getActiveSession()
        if activeSession?.isOpen ?? false{
            let sql = """
            SELECT count(*) as cnt from pos_order WHERE table_id = \(self.id) and is_closed = 0 and is_void = 0 and session_id_local = \(activeSession?.id ?? 0)
            """
            let dic =   database_class().get_row(sql: sql) ?? [:]
            let cnt = dic["cnt"] as? Int ?? 0
                self.countOrders = cnt
            complete(cnt)
            
        }else{
            self.countOrders = 0
            complete(0)
        }
        }

    }
      
        
        
    func getTableOrder() -> pos_order_class?{
        if SharedManager.shared.appSetting().enable_make_user_resposiblity_for_order{
            return getOrderList().first
        }
        return nil
    }

    func getOrderList() -> [pos_order_class]{
        let activeSession = pos_session_class.getActiveSession()
        if activeSession?.isOpen ?? false{
            let sql = """
            SELECT *  from pos_order WHERE table_id = \(self.id) and is_closed = 0 and is_void = 0 and session_id_local = \(activeSession?.id ?? 0) ORDER BY ID DESC LIMIT 1
            """
            
            let dicArray =   database_class().get_rows(sql: sql)
            let option = ordersListOpetions()
            option.parent_product = true
            return dicArray.map({pos_order_class(fromDictionary: $0,options_order: option)})

        }
        return []
    }
    
    func setUserResponse(with id:Int, name:String){
        let user = SharedManager.shared.activeUser()
        let pos = SharedManager.shared.posConfig()
       
        
        let sql = """
            update pos_order set table_control_by_user_id  = \(id) ,
                        table_control_by_user_name = '\(name)', write_user_id = \(user.id), write_user_name = '\(user.name ?? "")', write_pos_id = \(pos.id), write_pos_name = '\(pos.name ?? "")',write_pos_code = '\(pos.code)' , write_date = '\(baseClass.get_date_now_formate_datebase())'    where uid = '\(self.uid ?? "")'
            """
        self.dbClass?.runSqlStatament(sql: sql)
        
    }
    
    
    
    
}
