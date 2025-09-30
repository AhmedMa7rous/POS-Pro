//
//  promotionSelectFilter.swift
//  pos
//
//  Created by khaled on 09/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

class promotionSelectFilter
{
    var getNamesOnly:Bool = true
    var getCount:Bool = false
    var required_code:Bool = false


    var orderTypes:[Int] = []
    var posIds:[Int] = []
 
    var date_from:String?
    var date_to:String?
    var time_from:String?
    var time_to:String?
    var filter_code:String?

   private var product_id:Int!
    private var promotion_id:Int?
    
    init(_product_id:Int,_podId:Int,_orderType:Int,_promotion_id:Int?)
    {
        promotion_id = _promotion_id
        product_id = _product_id
        posIds.append(_podId)
        orderTypes.append(_orderType)
        
    }
    
  private  func promotionSqlIn() -> String {
        
      let day_name:String = Date.get_day_name(date:Date())
 
      
        var sql = """
             SELECT
                                           pos_promotion.id as pos_promotion_id , pos_promotion.active as pos_promotion_active ,pos_promotion.discount_product_id as pos_promotion_discount_product_id ,pos_promotion.display_name as pos_promotion_display_name
                                           ,pos_promotion.from_date as pos_promotion_from_date ,pos_promotion.from_time as pos_promotion_from_time ,pos_promotion.operator as pos_promotion_operator ,pos_promotion.promotion_code as pos_promotion_promotion_code
                                           ,pos_promotion.promotion_type as pos_promotion_promotion_type ,pos_promotion."sequence" as pos_promotion_sequence ,pos_promotion.to_date as pos_promotion_to_date ,pos_promotion.to_time as pos_promotion_to_time
                                           ,pos_promotion.total_amount as pos_promotion_total_amount ,pos_promotion.total_discount as  pos_promotion_total_discount ,pos_promotion.product_id_amt as pos_promotion_product_id_amt
                                           , pos_promotion.product_id_qty as pos_promotion_product_id_qty ,pos_promotion.no_of_applied_times as pos_promotion_no_of_applied_times
                                           
                                           ,pos_conditions.display_name as pos_conditions_display_name ,pos_conditions.id as pos_conditions_id ,pos_conditions.operator as pos_conditions_operator  ,pos_conditions.pos_promotion_rel_id as pos_conditions_pos_promotion_rel_id
                                           ,pos_conditions.pos_promotion_rel_name as pos_conditions_pos_promotion_rel_name ,pos_conditions.product_x_id as pos_conditions_product_x_id ,pos_conditions.product_y_id as pos_conditions_product_y_id
                                           ,pos_conditions.quantity as pos_conditions_quantity,pos_conditions.quantity_y  as pos_conditions_quantity_y,pos_conditions.no_of_applied_times  as pos_conditions_no_of_applied_times
                                           
                                           
                                           ,discount_multi_products.display_name as discount_multi_products_display_name ,discount_multi_products.id as discount_multi_products_id ,discount_multi_products.multi_product_dis_rel_id as discount_multi_products_multi_product_dis_rel_id
                                           ,discount_multi_products.multi_product_dis_rel_name as discount_multi_products_multi_product_dis_rel_name,discount_multi_products.products_discount as discount_multi_products_products_discount
                                           
                                           ,discount_multi_categories.categ_discount as discount_multi_categories_categ_discount ,discount_multi_categories.display_name as discount_multi_categories_display_name ,discount_multi_categories.id as discount_multi_categories_id
                                           ,discount_multi_categories.multi_categ_dis_rel_id as discount_multi_categories_multi_categ_dis_rel_id ,discount_multi_categories.multi_categ_dis_rel_name as discount_multi_categories_multi_categ_dis_rel_name
                                           
                                           ,discount_above_price.discount as discount_above_price_discount ,discount_above_price.discount_type as discount_above_price_discount_type ,discount_above_price.display_name as discount_above_price_display_name
                                           ,discount_above_price.fix_price_discount as discount_above_price_fix_price_discount ,discount_above_price.free_product_id as discount_above_price_free_product_id ,discount_above_price.id as discount_above_price_id
                                           ,discount_above_price.pos_promotion_id_id as discount_above_price_pos_promotion_id_id,discount_above_price.pos_promotion_id_name as discount_above_price_pos_promotion_id_name ,discount_above_price.price as discount_above_price_price
                                           
                                           ,quantity_discount.discount_dis as quantity_discount_discount_dis ,quantity_discount.display_name as quantity_discount_display_name ,quantity_discount.id as quantity_discount_id
                                           ,quantity_discount.pos_quantity_rel_id as quantity_discount_pos_quantity_rel_id ,quantity_discount.pos_quantity_rel_name as quantity_discount_pos_quantity_rel_name
                                           ,quantity_discount.quantity_dis  as quantity_discount_quantity_dis,quantity_discount.no_of_applied_times  as quantity_discount_no_of_applied_times
                                           
                                           ,quantity_discount_amt.discount_price as quantity_discount_amt_discount_price ,quantity_discount_amt.display_name as quantity_discount_amt_display_name ,quantity_discount_amt.id as quantity_discount_amt_id
                                           ,quantity_discount_amt.pos_quantity_amt_rel_id as quantity_discount_amt_pos_quantity_amt_rel_id ,quantity_discount_amt.pos_quantity_amt_rel_name as quantity_discount_amt_pos_quantity_amt_rel_name
                                           ,quantity_discount_amt.quantity_amt as quantity_discount_amt_quantity_amt,quantity_discount_amt.no_of_applied_times  as  quantity_discount_amt_no_of_applied_times
                                           
                                           ,parent_product.parent_product_ids
                                           ,apply_on_pos.posID
                                           ,orderType.orderTypeID
                                            ,day_of_week_ids.daysID
                                           ,day_week.display_name as dayName
             
                                   from pos_promotion
                                   left join
                                   pos_conditions on pos_promotion.id = pos_conditions.pos_promotion_rel_id
                                   left join
                                   discount_multi_products   on  pos_promotion.id = discount_multi_products.multi_product_dis_rel_id
                                   left join
                                   discount_multi_categories     on  pos_promotion.id = discount_multi_categories.multi_categ_dis_rel_id
                                   left join
                                   discount_above_price   on  pos_promotion.id = discount_above_price.pos_promotion_id_id
                                   left join
                                   quantity_discount    on  pos_promotion.id = quantity_discount.pos_quantity_rel_id
                                   left join
                                   quantity_discount_amt   on  pos_promotion.id = quantity_discount_amt.pos_quantity_amt_rel_id
                                   left join
                                   (SELECT re_id2 as orderTypeID  ,re_id1  as promID from relations where re_table1_table2 = "pos_promotion|apply_on_order_types") as  orderType
                                   on orderType.promID =  pos_promotion.id
                                   left join
                                   (SELECT re_id2 as parent_product_ids ,re_id1  as promID from relations where re_table1_table2 = "pos_promotion|parent_product_ids") as  parent_product
                                   on parent_product.promID =  pos_promotion.id
                                   left join
                                   (SELECT re_id2 as posID ,re_id1  as promID from relations where re_table1_table2 = "pos_promotion|apply_on_pos") as  apply_on_pos
                                   on apply_on_pos.promID =  pos_promotion.id
                                   left join
                                   (SELECT re_id2 as daysID ,re_id1  as promID from relations where re_table1_table2 = "pos_promotion|day_of_week_ids") as  day_of_week_ids
                                   on day_of_week_ids.promID =  pos_promotion.id
             
                                    left join
                                    day_week
                                    on day_week.id = daysID
                                  
                                   WHERE
                                    (
                                    (pos_conditions_product_x_id = \(product_id!) and  pos_promotion_promotion_type = 'buy_x_get_y') -- Buy_X_Get_Y_Free
                                    OR
                                    (parent_product_ids =  \(product_id!) and  pos_promotion_promotion_type = 'buy_x_get_dis_y') -- Buy_X_Get_Discount_On_Y
                                    OR
                                    (parent_product_ids =  \(product_id!) and  pos_promotion_promotion_type = 'buy_x_get_fix_dis_y')   -- buy_x_get_fix_dis_y
                                    OR
                                    (pos_promotion_product_id_amt =  \(product_id!) and pos_promotion_promotion_type = 'quantity_price')  -- Fix_Discount_on_Quantity
                                    OR
                                    (pos_promotion_product_id_qty =  \(product_id!) and pos_promotion_promotion_type = 'quantity_discount') -- Percent_Discount_on_Quantity
                                    )
                                    AND
                                    (dayName = '\(day_name)' or dayName is NULL)
                                    AND
                                    orderTypeID in ( \(getList(orderTypes)) )
                                    AND
                                     posID in ( \(getList(posIds)) )
             
             
             """
        
      if (promotion_id ?? 0) != 0
      {
          sql = sql + " AND pos_promotion_id = \(promotion_id!)"
      }
      
      if required_code == true
      {
          sql = sql + " AND pos_promotion.filter_code = '\(filter_code!)' and pos_promotion.required_code = 1"

      }
      else
      {
          sql = sql + " AND  pos_promotion.required_code = 0"
      }
 
     
      if getNamesOnly
      {
          let groupbyName = " GROUP BY pos_promotion_display_name"
          sql = sql + groupbyName
      }
       
      if getCount
      {
          sql = " select count(*) from (\(sql))"
      }
        
      SharedManager.shared.printLog(sql)
        return sql
    }
    
    
    func getAvailablePromotions()  -> [[String : Any]]
    {
        let lst = database_class().get_rows(sql: promotionSqlIn())
        var avalibleLst:[[String:Any]] = []
        for prom in lst
        {
            let promotion = pos_promotion_class(fromDictionary: promotion_helper_class.remove_perfiex(dic: prom, prfiex: "pos_promotion_"))

            if promotionValidate.validate(promotion)
            {
                avalibleLst.append(prom)
            }
        }
        
        
        
        return avalibleLst

    }
    
   static func getPromotionId(promotion_row_parent:Int,order_id:Int) -> Int
    {
        let sql = """
        SELECT  pos_promotion_id from pos_order_line
        WHERE   order_id  = \(order_id) and promotion_row_parent  = \(promotion_row_parent) and pos_promotion_id != 0 LIMIT  0,1
        """
        
        let dic =   database_class().get_row(sql: sql) ?? [:]
        let pos_promotion_id = dic["pos_promotion_id"] as? Int ?? 0

        
        return pos_promotion_id
    }
    
    func isHavePromotion()  -> Bool
    {
        self.getCount = true
        self.getNamesOnly = false
        
        let cnt = database_class().get_count(sql: promotionSqlIn())
         if cnt > 0
        {
             return true
         }
        return false

    }
    
    
    func getList(_ lst:[Int]) -> String
    {
        var str = ""
        for v in lst
        {
            str = str + ","  + String(v)
        }
        
        str.removeFirst()
        
        return str
    }
    
   static func checkPromotionCode(code:String) -> Bool
    {
        if code.isEmpty
        {
            return false
        }
        
        let sql = """
        SELECT count(*) as cnt from pos_promotion WHERE filter_code = '\(code)'
        """
        
        let dic =   database_class().get_row(sql: sql) ?? [:]
        let cnt = dic["cnt"] as? Int ?? 0

        
        return cnt > 0 ? true : false
    }
    
    
}
