//
//  calculate_pricelist.swift
//  pos
//
//  Created by khaled on 8/24/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class calculate_pricelist: NSObject {
    
    func get_price(product:product_product_class,rule:product_pricelist_class? ,quantity:Double) -> Double  {
        var price:Double = product.price
        
        if rule == nil
        {
            return price
        }
        if let pricelistID = rule?.id {
            
                PriceListInteractor.initilze(pricelistID:pricelistID,
                                             productTmplID: product.product_tmpl_id,
                                             productID: product.id,
                                             categID: product.pos_categ_id,
                                             brandID: product.brand_id)
                
                let priceListItems = PriceListInteractor.shared.fetchPriceItems()
//                SharedManager.shared.printLog("priceListItems count === \(priceListItems.count) ======= priceListItems === \(priceListItems)")
                priceListItems.forEach { listItem in
                    let calcPrice = get_price_item(product: product, rule: listItem, quantity: quantity)
                    if calcPrice.match == true
                    {
                        price = calcPrice.price
                    }
                }
            return price
            

        }
        //WARNING:- LOOP
        
        //TODO: - WARNING:- LOOP
        let price_list_needed = get_sub_priceList(rule: rule)
        //TODO: - WARNING:- LOOP
        for item:product_pricelist_item_class in price_list_needed
        {
            if checkApply(product: product, rule: item)
            {
                let calcPrice = get_price_item(product: product, rule: item, quantity: quantity)
                if calcPrice.match == true
                {
                    return calcPrice.price
                    
                }
            }
        }
        
        
        return price
    }
    
    
    func get_sub_priceList(rule:product_pricelist_class?) -> [product_pricelist_item_class]
    {
        let all_price_list_items:[product_pricelist_item_class] = product_pricelist_item_class.get(pricelist_id: rule!.id!)
        
//        return all_price_list_items
        var price_list_needed:[product_pricelist_item_class] = []
// TODO: - waring
        for ID in rule!.get_item_ids() {
            let id = ID
            for item in all_price_list_items
            {
                let cls = item
                if cls.id == id
                {
                    price_list_needed.append(cls)
                }
            }

        }

        return price_list_needed
    }
    
    func checkApply(product:product_product_class,rule:product_pricelist_item_class) -> Bool  {
        
        if rule.applied_on == "3_global"
        { return true}
        
        if rule.product_tmpl_id != nil
        {
            let product_tmpl_id  = rule.product_tmpl_id!
            if  product_tmpl_id == product.product_tmpl_id
            {
                return true
            }
        }
        
        
        if rule.product_id != nil
        {
            let product_id  = rule.product_id!
            if  product_id == product.id
            {
                return true
            }
        }
        
        if rule.categ_id != nil && product.categ_id != 0
        {
            let categ_id  = rule.categ_id!
            var categ_ids = pos_category_class.get_sub_category(parent_id: categ_id).compactMap({$0["id"] as? Int})
            
            categ_ids.append(categ_id)
            
            let categ_id_product  = product.categ_id  ?? 0
            
            for item in categ_ids
            {
                if  item  == categ_id_product
                {
                    return true
                }
            }
            
        }
        
        let formateDate = "yyyy-MM-dd"
        let dateNow = Date().toString(dateFormat: formateDate, UTC: true)//ClassDate.getNow(formateDate)
        
        if rule.date_start != nil
        {
            let def = baseClass.compareTwoDate(rule.date_start!, dt2_new: dateNow,formate: formateDate)
            
            if def > 0
            {
                return true
            }
            
        }
        
        if rule.date_end != nil
        {
            let def = baseClass.compareTwoDate(dateNow, dt2_new: rule.date_start!,formate: formateDate)
            
            if def < 0
            {
                return true
            }
            
        }
        
        
        return false
    }
    
    
    
    
    func get_price_item(product:product_product_class,rule:product_pricelist_item_class ,quantity:Double) -> (price:Double , match:Bool) {
        var price:Double = product.price
        
        if rule.product_id == 0  {
            
            if rule.product_tmpl_id != 0 && (rule.product_tmpl_id != product.product_tmpl_id)
            {
                return (price,false);
            }
            
        }else{
            if rule.product_id != product.id
            {
                return (price,false);
            }
        }
        if (rule.min_quantity == 0 && quantity < rule.min_quantity!) {
            return (price,false);
        }
        
        if (rule.base == "pricelist") {
            //            price =  get_price(product: product,rule: rule.base_pricelist, quantity: quantity)
        } else if (rule.base == "standard_price") {
            price = product.standard_price;
        }
        
        if (rule.compute_price == "fixed") {
            price = rule.fixed_price!;
            return (price,true)
        } else if (rule.compute_price == "percentage") {
            price = price - (price * (rule.percent_price! / 100));
            return (price,true)
        } else {
            
            let price_limit = price;
            price = price - (price * (rule.price_discount! / 100));
            if ( rule.price_round  != 0) {
//                price = price.rounded(toPlaces: rule.price_round!)

                price = price.rounded(value: rule.price_round!)
            }
            if ( rule.price_surcharge  != 0) {
                price += rule.price_surcharge!;
            }
            if ( rule.price_min_margin  != 0) {
                price =  max(price, price_limit + rule.price_min_margin!)
            }
            if ( rule.price_max_margin != 0) {
                price =  min(price, price_limit + rule.price_max_margin!);
            }
            return (price,true)
        }
        
        //      return (price,false)
        
    }
}


class PriceListInteractor{
    var pricelist_id:Int?
    var product_id:Int?
    var product_tmpl_id:Int?
    var categ_id:Int?
    var brand_id:Int?
    static var shared:PriceListInteractor = PriceListInteractor()
    private var cashItems:[product_pricelist_item_class]?
    private init(){}
    static func initilze(pricelistID:Int,productTmplID:Int?,productID:Int?,categID:Int?,brandID:Int?){
       var current = PriceListInteractor.shared
       
       if let cashItems = current.cashItems{
           if (current.pricelist_id != pricelistID) ||
                (current.product_id != productID){
               current.cashItems?.removeAll()
           }
       }
       
       current.pricelist_id = pricelistID
       current.product_id = productID
       current.product_tmpl_id = productTmplID
       current.categ_id = categID
       current.brand_id = brandID
    }
    
    
    func fetchPriceItems() -> [product_pricelist_item_class]{
        if (self.pricelist_id ?? 0) <= 0 {
            return []
        }
        if (self.cashItems?.count ?? 0) > 0{
            return cashItems ?? []
        }
        let itemsGlobal = self.getGlobalItems()
        if itemsGlobal.count > 0 {
            self.cashItems = itemsGlobal
            return itemsGlobal
        }
        let itemsTemp = self.getProductTempItems()
        if itemsTemp.count > 0 {
            self.cashItems = itemsTemp
            return itemsTemp
        }
        let itemsProducts = self.getProductItems()
        if itemsProducts.count > 0 {
            self.cashItems = itemsProducts
            return itemsProducts
        }
        let itemsCategs =  self.getCategItems()
        if itemsCategs.count > 0 {
            self.cashItems = itemsCategs
            return itemsCategs
        }
        let itemsStartDay =  self.getStartDayItems()
        if itemsStartDay.count > 0 {
            self.cashItems = itemsStartDay
            return itemsStartDay
        }
        let itemsEndDay =  self.getEndDayItems()
        if itemsEndDay.count > 0 {
            self.cashItems = itemsEndDay
            return itemsEndDay
        }
        self.cashItems = []

        return []

        
    }
    private func getCategItems()  -> [product_pricelist_item_class]{
        if let categID = self.categ_id {
            var categ_ids = pos_category_class.get_sub_category(parent_id: categID).compactMap({$0["id"] as? Int})
            categ_ids.append(categID)
            let whereCategsItems = self.generateCondation(categIDS:categ_ids )
            let itemsCategs = self.hitSelectPriceItems(whereCond: whereCategsItems)
            if itemsCategs.count > 0 {
                return itemsCategs
            }
        }
        return []
    }
    private func getProductItems()  -> [product_pricelist_item_class]{
        if let productlID = self.product_id {
            let whereProductItems = self.generateCondation(productID:productlID )
            let itemsProducts = self.hitSelectPriceItems(whereCond: whereProductItems)
            if itemsProducts.count > 0 {
                return itemsProducts
            }
        }
        return []
    }
    private func getProductTempItems()  -> [product_pricelist_item_class]{
        if let productTmplID = self.product_tmpl_id {
            let whereTempItems = self.generateCondation(productTmplID:productTmplID )
            let itemsTemp = self.hitSelectPriceItems(whereCond: whereTempItems)
            if itemsTemp.count > 0 {
                return itemsTemp
            }
        }
        return []
    }
    private func getGlobalItems()  -> [product_pricelist_item_class]{
        let whereProductIdZeroGlobal = self.generateCondation(global: generatGlobalCondation(productIdZero:true))
        let itemsProductIdZeroGlobal = self.hitSelectPriceItems(whereCond: whereProductIdZeroGlobal)
        if itemsProductIdZeroGlobal.count > 0 {
            return itemsProductIdZeroGlobal
        }else{
            let whereProductIdGlobal = self.generateCondation(global: generatGlobalCondation(tempIdZero:true))
            let itemsProductIdGlobal = self.hitSelectPriceItems(whereCond: whereProductIdGlobal)
            return itemsProductIdGlobal
        }
        return []
    }
    private func getStartDayItems()  -> [product_pricelist_item_class]{
        let whereStartDate = self.generateCondation(startDate: true)
        let itemsStartDate = self.hitSelectPriceItems(whereCond: whereStartDate)
        if itemsStartDate.count > 0 {
            return itemsStartDate
        }
        return []
    }
    private func getEndDayItems()  -> [product_pricelist_item_class]{
        let whereEndDate = self.generateCondation(endDate: true)
        let itemsEndDate = self.hitSelectPriceItems(whereCond: whereEndDate)
        if itemsEndDate.count > 0 {
            return itemsEndDate
        }
        return []
    }
    
    
    private func hitSelectPriceItems(whereCond:String?) -> [product_pricelist_item_class]{
        if let whereCond = whereCond{
            let sql = """
        select *  from product_pricelist_item
        WHERE \(whereCond) ;
"""
            var dataBaseConnect:database_class? = database_class(connect: .database)
            let results = dataBaseConnect?.get_rows(sql:sql).map({product_pricelist_item_class(fromDictionary: $0)})
            dataBaseConnect = nil
            return results ?? []
        }
        return []
    }
    private func generatGlobalCondation(productIdZero:Bool = false,tempIdZero:Bool = false) -> [String]{
        var condationGlobal:[String] = []
        condationGlobal.append("applied_on = '3_global' ")
        if productIdZero {
            if let productTmplID = self.product_tmpl_id{
                condationGlobal.append("product_tmpl_id = \(productTmplID)")
            }
        }
        if tempIdZero {
            if let productID = self.product_id{
                condationGlobal.append("product_id = \(productID)")
            }
        }
        
        return condationGlobal


    }
    
    private func generateCondation(global:[String]? = nil,
                                   productTmplID:Int? = nil,
                                   productID:Int? = nil,
                                   categIDS:[Int]? = nil,
                                   brandID:Int? = nil,startDate:Bool? = nil,endDate:Bool? = nil)->String?{
        guard let pricelistID = self.pricelist_id else { return nil }
        var condationArray:[String] = []
        condationArray.append("pricelist_id = \(pricelistID)")
        condationArray.append("deleted = 0")
        if let global = global {
            condationArray.append(contentsOf: global )
        }else if let productTmplID = productTmplID{
            condationArray.append("product_tmpl_id = \(productTmplID)")
        }else if let productID = productID{
            condationArray.append( "product_id = \(productID)")
        }else if let categIDS = categIDS, categIDS.count > 0{
            let stringIDS = categIDS.map({"\($0)"}).joined(separator: ",")
            condationArray.append("categ_id  in (\(stringIDS))")
        }else if let startDate = startDate,startDate{
            let formateDate = "yyyy-MM-dd"
            let dateNow = Date().toString(dateFormat: formateDate, UTC: true)
            condationArray.append( "strftime('%Y-%m-%d',date_start) BETWEEN '\(dateNow)' AND '2050-12-31'")
        }else if let endDate = endDate,endDate{
            let formateDate = "yyyy-MM-dd"
            let dateNow = Date().toString(dateFormat: formateDate, UTC: true)
            condationArray.append( "strftime('%Y-%m-%d',date_end) BETWEEN '2000-01-01'  AND '\(dateNow)'")

        }else{
            condationArray.removeAll()
        }
        if condationArray.count > 0 {
            condationArray.append(" id in ( select r.re_id2 from relations r where r.re_id1 = \(pricelistID) and r.deleted = 0 and r.re_table1_table2 = 'product_pricelist|product_pricelist_item' )")
        }
        return condationArray.joined(separator: " and ")
        
    }
    
}
