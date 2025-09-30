//
//  product_avaliable_class.swift
//  pos
//
//  Created by M-Wageh on 20/03/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
enum AVALIABLE_STATUS:Int{
    case NONE,ACTIVE,NOT_ACTIVE
}
class product_avaliable_class: NSObject {
    var dbClass:database_class?
    
    var id:Int?
    var product_product_id:Int?
    var avaliable_status:AVALIABLE_STATUS = .NONE
    var avaliable_qty:Double?
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        product_product_id = dictionary["product_product_id"] as? Int ?? 0
        avaliable_status = AVALIABLE_STATUS.init(rawValue:  dictionary["avaliable_status"] as? Int ?? 0)!
        avaliable_qty = dictionary["avaliable_qty"] as? Double ?? 0
        
        dbClass = database_class(table_name: "product_avaliable", dictionary: self.toDictionary(),id: id!,id_key:"id")
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["product_product_id"] = product_product_id
        dictionary["avaliable_status"] = avaliable_status.rawValue
        dictionary["avaliable_qty"] = avaliable_qty
        
        return dictionary
        
    }
    
    
    func save()
    {
        if let product_product_id = self.product_product_id{
            let selectQuery = "SELECT * FROM product_avaliable WHERE  product_product_id = \(product_product_id)"
            let resutSelect =  database_class(connect: .database).get_row(sql: selectQuery)
            if (!((resutSelect ?? [:]).isEmpty) ) {
                if let id = resutSelect?["id"] as? Int{
                    
                    let sql = "UPDATE product_avaliable SET avaliable_qty = \(avaliable_qty ?? 0), avaliable_status = \(avaliable_status.rawValue  ) WHERE  id = \(id)"
                    let resutUpdate = database_class(connect: .database).runSqlStatament(sql: sql)
                    
                   
                }
              
            } else {
             
                dbClass?.dictionary = self.toDictionary()
                dbClass?.id = self.id!
                dbClass?.insertId = false
                _ =  dbClass!.save()
            }
        }
    }
    
    
    static func getProductAvaliable(for productID:Int)-> product_avaliable_class?
    {
        let cls = product_avaliable_class(fromDictionary: [:])
        if let dicObject =  cls.dbClass!.get_row(whereSql: " where  product_product_id = \(productID)"  ){
            let productAvaliable =  product_avaliable_class(fromDictionary: dicObject)
            if productAvaliable.avaliable_status != .NOT_ACTIVE{
                return productAvaliable
            }
        }
        return nil
    }
    
    //TODO: - static func call update_qty_from_api to update qty , status for product_id
    static func update_qty_from_api(for productId: Int, by qty:Double) {
    
        let selectQuery = "SELECT * FROM product_avaliable WHERE  product_product_id = \(productId)"
        let resutSelect =  database_class(connect: .database).get_row(sql: selectQuery)
        if (!((resutSelect ?? [:]).isEmpty) ) {
            let sql = "UPDATE product_avaliable SET avaliable_qty = \(qty), avaliable_status = \(AVALIABLE_STATUS.ACTIVE.rawValue) WHERE  product_product_id = \(productId)"
            let resutUpdate = database_class(connect: .database).runSqlStatament(sql: sql)
        } else {
            let sql = "INSERT INTO product_avaliable  (avaliable_qty, avaliable_status, product_product_id) VALUES (\(qty), \(AVALIABLE_STATUS.ACTIVE.rawValue), \(productId))"
            let resutInsert = database_class(connect: .database).runSqlStatament(sql: sql)
        }
    }
    
    static func getProductsIds()-> [[String: Any]]{
        let sql = """
            SELECT id FROM product_product
        """
        return database_class(connect: .database).get_rows(sql: sql)
    }
}

class ProductAvalibleModel{
    var avaliable_class:product_avaliable_class?
    var product_class:product_product_class?
    init(from dic:[String:Any]){
        product_class = product_product_class(fromDictionary: dic)
        if let existAvaliable = product_avaliable_class.getProductAvaliable(for:product_class?.id ?? 0) {
            self.avaliable_class = existAvaliable
        }else{
            let newAvaliable = product_avaliable_class(fromDictionary: [:])
            newAvaliable.product_product_id = product_class?.id
            self.avaliable_class = newAvaliable
        }

    }
    static func getProductAvaliable(for categoryID:Int)-> [ProductAvalibleModel]?{
        let pos = SharedManager.shared.posConfig()

        var brand_option = ""
        if let brand_id = SharedManager.shared.selected_pos_brand_id {
            brand_option = "and (product_product.brand_id is null or product_product.brand_id = \(brand_id) ) "
        }
        let sql = """
            SELECT count(product_template_id ) as variants_count , MIN( lst_price ) ,products.*from (
               SELECT product_template .id as product_template_id ,product_product.* from product_product
               inner join product_template
               on product_template .id  = product_product.product_tmpl_id
               where product_product.deleted  = 0 and product_product.pos_categ_id = \(categoryID)  \(brand_option) and (company_id = \(String(pos.company_id!)) OR company_id = 0 ) ) as products
               GROUP by  product_template_id
               order by products."sequence"
        """
        let sql2 = """
            SELECT count(product_template_id ) as variants_count , MIN( lst_price ) ,products.*,product_avaliable.* from (
               SELECT product_template .id as product_template_id ,product_product.*,product_avaliable.* from product_product
               inner join product_template
               on product_template .id  = product_product.product_tmpl_id and product_avaliable.product_product_id = product_product.id
               where product_product.deleted  = 0 and product_product.pos_categ_id = \(categoryID)  \(brand_option) and (company_id = \(String(pos.company_id!)) OR company_id = 0 ) ) as products
               GROUP by  product_template_id
               order by products."sequence"
        """
        
        let sql1 = """
        select *  from product_avaliable,product_product
        WHERE product_avaliable.product_product_id = product_product.id
        and product_product.pos_categ_id = \(categoryID)
        and product_product.is_combo = 0
        and product_product.deleted = 0 ;
"""
        
         
        return database_class(connect: .database).get_rows(sql:sql).map({ProductAvalibleModel(from: $0)})
    }
}
