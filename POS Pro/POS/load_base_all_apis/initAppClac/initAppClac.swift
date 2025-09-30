////
////  initAppClac.swift
////  pos
////
////  Created by Khaled on 1/7/20.
////  Copyright © 2020 khaled. All rights reserved.
////
//
//import UIKit
//
//class initAppClac: UIViewController {
//
//    var all_products:[[String:Any]] =  [[:]]
//    var all_pricelist:[[String:Any]] =  [[:]]
//    var list_combo_price:[[String:Any]] =  [[:]]
//    var list_combo:[[String:Any]] =  [[:]]
//    var product_variant:[[String:Any]] =  [[:]]
//    var product_variant_ids:[Int] = []
//
////    var delivery_product_id:Int?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//
//
//
//        //      let filteredArray = list_combo.filter{$0["id"]! as? Int == 12}
//        //        print(filteredArray)
//    }
//
//    func checkToRun() ->Bool
//    {
////        let run = myuserdefaults.getitem("run", prefix: "initAppClac") as? String
//        let run = cashClass.get(key: "initAppClac_run")
//        if run ==  nil
//        {
//            return true
//        }
//        return false
//    }
//
//    static func forceToRun()
//    {
//        cashClass.remove(key: "initAppClac_run")
////        myuserdefaults.deleteitems("run", prefix: "initAppClac")
//    }
//
//    func doneRun()
//    {
//        cashClass.set(key: "initAppClac_run", value: "1")
////        myuserdefaults.setitems("run", setValue: "1", prefix: "initAppClac")
//    }
//
//    func loadGuides()
//    {
//        if checkToRun() == false
//        {
//            return
//        }
//
//
//        self.perform(#selector(loadAll))
//
//
//    }
//
//    @objc func loadAll()  {
//        self.all_products =  productProductClass.getAll() // api.get_last_cash_result(keyCash: "Items_by_POS_Category2") as? [[String:Any]] ?? [[:]]
//        self.all_pricelist = productPricelistClass.getAll() // api.get_last_cash_result(keyCash:"get_product_pricelist") as? [[String:Any]] ?? [[:]]
//        self.list_combo_price    = productComboPriceClass.getAll() // api.get_last_cash_result(keyCash: "get_product_combo_prices") as? [[String:Any]] ?? [[:]]
//        self.list_combo  = productComboClass.getAll() // api.get_last_cash_result(keyCash: "get_porduct_combo") as? [[String:Any]] ?? [[:]]
//        //        self.product_variant  = api.get_last_cash_result(keyCash: "get_porduct_template") as? [[String:Any]] ?? [[:]]
//
////        get_delivery_product()
////        get_default_cash()
//
//        if all_products.count  > 0
//        {
//            //            get_allVariantIDs()
//            self.check_products_combo()
//
//            self.doneRun()
//        }
//
//
//    }
//
////    func get_delivery_product()
////    {
//
////        let all_orderType: [[String:Any]] =  orderTypeClass.getAll() // api.get_last_cash_result(keyCash: "get_order_type") as? [[String:Any]] ?? [[:]]
////        for item in all_orderType
////        {
////            let order_type = item["order_type"] as? String ?? ""
////            if order_type == "delivery"
////            {
////                let delivery_product_id_arr = item["delivery_product_id"] as? [Any] ?? []
////                if delivery_product_id_arr.count > 0
////                {
////                    delivery_product_id = delivery_product_id_arr[0] as? Int ?? 0
////                    break
////                }
////            }
////        }
////    }
//
////    func get_default_cash()
////    {
////        let get_account_Journals:[[String:Any]]  =  accountJournalsClass.getAll() // api.get_last_cash_result(keyCash: "get_account_Journals") as? [[String:Any]] ?? [[:]]
////        var account_cash :accountJournalsClass?
////        var account_STC :accountJournalsClass?
////
////        for obj in get_account_Journals
////        {
////            let temp = accountJournalsClass(fromDictionary: obj)
////            if temp.type == "cash"
////            {
////                account_cash = temp
////                //                break
////            }
////
////            if temp.payment_type == "stc"
////            {
////                account_STC = temp
////            }
////
////        }
////
////        let pos = posConfigClass.getDefault()
////        pos.accountJournals_cash_default =  account_cash
////        pos.accountJournals_STC = account_STC
////        pos .save()
////
////    }
//
//
////    func get_allVariantIDs()
////    {
////        for obj in product_variant
////        {
////            let temp = product_templateClass(fromDictionary: obj)
////            if temp.product_variant_ids.count > 1
////            {
////                product_variant_ids.append(contentsOf: temp.product_variant_ids)
////            }
////        }
////    }
//
//    func check_products_combo()
//    {
//
//        var variants:[[String:Int]] = []
//
//        for i in 0...all_products.count - 1
//        {
//            let dic = all_products[i]
//            let product = productProductClass(fromDictionary: dic)
//
////            if product.id == delivery_product_id
////            {
////
////                api.save_last_cash_result(dictionary: [dic], keyCash: "delivery_produc")
////
////            }
//
//
//            if product.invisible_in_ui == false
//            {
//
//                if product.is_combo == true
//                {
//                    let product_combo_ids = product.product_combo_ids
//
//                    let arr_avalalibe_combo = get_avalalibe_combos(product_combo_ids: product_combo_ids, list_combo: list_combo)
//                    let products_InCombo = get_products_InCombo(avalabile_combos: arr_avalalibe_combo)
////                    product.products_InCombo = products_InCombo.list
//                    product.products_InCombo_avalibale_total_items = products_InCombo.total_items
//
//                }
//                else
//                {
//                    let product_tmpl_id = product.product_tmpl_id
//
//                    if product.product_variant_ids.count > 1
//                    {
//
//
//                        let isexist =  variants.filter{ $0["product_tmpl_id"] == product_tmpl_id }
//                        if isexist.count == 0
//                        {
//                            product.invisible_in_ui = false
//
//                            product.product_variant_lst = get_variant(product_variant_ids: product.product_variant_ids)
//
//                            var dic:[String:Int] = [:]
//                            dic["product_tmpl_id"] = product_tmpl_id
//                            variants.append(dic)
//                        }
//                        else
//                        {
//                            product.invisible_in_ui = true
//                         }
//
//                    }
//
//
//
//                }
//
//                all_products[i] = product.toDictionary()
//
//            }
//
//        }
//
//        //        all_products.append(contentsOf: variants)
//
////        api.save_last_cash_result(dictionary: all_products, keyCash: "Items_by_POS_Category2")
//    }
//
//    func get_variant(product_variant_ids:[Int]) -> [Any]
//    {
//        var lst:[Any] = []
//
//        for id in product_variant_ids
//        {
//            let filteredArray = all_products.filter{$0["id"]! as? Int == id}
//            lst.append(contentsOf: filteredArray)
//        }
//
//        return lst
//
//    }
//
//    func get_avalalibe_combos( product_combo_ids: [Int] ,list_combo:[[String:Any]]) ->[[String:Any]]
//    {
//        var arr_avalalibe_combo:[[String:Any]] = []
//
//        for item:Int in product_combo_ids
//        {
//            let filteredArray = list_combo.filter{$0["id"]! as? Int == item}
//            arr_avalalibe_combo.append(contentsOf: filteredArray)
//
//
//        }
//
//        return arr_avalalibe_combo
//    }
//
//    func get_products_InCombo(avalabile_combos:[[String:Any]]) -> (list:[String:[[String:Any]]] , total_items:Double)
//    {
//
//        var list_collection: [String:[[String:Any]]] = [:]
//        var avalibale_total_items = 0.0
//        let Require_header = "0_Require"
//
//        var index = 1
//        for combo  in avalabile_combos
//        {
//            var list:[[String:Any]] = []
//
//            //            let require = combo["require"] as? Bool ?? false
//            //            let no_of_items = combo["no_of_items"] as? Bool ?? false
//            //            let product_ids:[Int] = combo["product_ids"] as! [Int]
//
//            let cls_combo = productComboClass(fromDictionary: combo)
//            avalibale_total_items = avalibale_total_items + Double(cls_combo.no_of_items)
//
//
//            let arr_products = get_product_item(combo: cls_combo)
//            list.append(contentsOf: arr_products)
//
//            if cls_combo.require == true
//            {
//                var newList = list_collection[Require_header]  ?? []
//                newList.append(contentsOf: list)
//
//                list_collection[Require_header] = newList
//            }
//            else
//            {
//                var categ_name = ""
//
//                if cls_combo.pos_category_id != 0
//                {
//                    categ_name =   cls_combo.pos_category_id_name
//                }
//
//                categ_name = String(format: "%d_%@" , index , categ_name)
//
//                var newList = list_collection[categ_name]   ?? []
//                newList.append(contentsOf: list)
//
//                list_collection[categ_name] = newList
//
//
//                index += 1
//            }
//
//        }
//
//        return (list_collection , avalibale_total_items)
//    }
//
//
//    func get_product_item(combo:productComboClass) -> [[String:Any]]
//    {
//        var list:[[String:Any]] = []
//
//        for id:Int  in combo.product_ids
//        {
//            for item in all_products
//            {
//                var product = productProductClass(fromDictionary: item )
//
//                if product.id == id
//                {
//                    if combo.pos_category_id == 0
//                    {
////                        combo.pos_category_id = [ 0 ,"Default"]
//                        combo.pos_category_id_name = "Default"
//                    }
//
//                    product.combo = combo
//
//                    product = get_extraPrice(product: product )
//
//
//                    list.append(product.toDictionary())
//                }
//            }
//
//
//        }
//
//        return list
//    }
//
//
//    func get_extraPrice(product:productProductClass ) -> productProductClass {
//        var product_new = product
////        let product_tmpl_id = product_new.combo?.product_tmpl_id ?? []
//
//        if  product_new.combo?.product_tmpl_id != 0
//        {
//
//            let combo_tmpl_id = product_new.combo!.product_tmpl_id
//
//            product_new = get_extra_price(tmpl_id: combo_tmpl_id,product: product_new)
//
//
//        }
//
//        return product_new
//    }
//
//
//
//    func get_extra_price(tmpl_id:Int,product:productProductClass) -> productProductClass
//    {
//        for item in list_combo_price
//        {
//            let combo = productComboClass(fromDictionary: item )
////            let combo_tmpl_id = combo.product_tmpl_id // (combo.product_tmpl_id.count > 0) ? combo.product_tmpl_id[0]  as? Int ?? 0 : 0
////            let product_id_temp =  ( combo.product_id.count > 0) ? combo.product_id[0] : 0
//            var combo_product_id = combo.product_tmpl_id // (combo.product_tmpl_id.count > 0) ?  product_id_temp as? Int ?? 0 : 0
//            if combo_product_id == 0
//            {
//                combo_product_id = combo.product_id
//            }
//
//
//        }
//
//        return product
//    }
//
//
//}
