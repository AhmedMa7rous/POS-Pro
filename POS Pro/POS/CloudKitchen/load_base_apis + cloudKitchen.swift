//
//  load_base_apis + cloudKitchen.swift
//  pos
//
//  Created by M-Wageh on 13/10/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
typealias SyncFunc = () -> ()

extension load_base_apis {
    func appendSyncCloudKitchenAPIS(){
        let cloudKitchenIDs = SharedManager.shared.posConfig().cloud_kitchen
        if cloudKitchenIDs.count > 0 {
            let indexCategoryKey = 3

            /*
             var indexCategoryKey = 1

            if let index_cate = list_items.index(forKey: "get_pos_category") , let index_key = list_keys.firstIndex(where: {$0 == "get_pos_category"} ) {
                list_items.remove(at: index_cate)
                list_keys.remove(at: index_key)
                indexCategoryKey = index_key

            }
            if let index_product = list_items.index(forKey: "get_product_product")  , let index_key = list_keys.firstIndex(where: {$0 == "get_product_product"} ) {
                list_items.remove(at: index_product)
                list_keys.remove(at: index_key)

            }
             */
            
                
            var previous_index_cate = 1
            var previous_index_product = 2
            var cloud_kitchen_list_key:[String] = []
            cloudKitchenIDs.forEach { brand_id in
                let key_cloud_kitchen_category = "get_cloud_kitench_category_\(brand_id)"
                let key_cloud_kitchen_product = "get_cloud_kitench_product_product_\(brand_id)"

                previous_index_cate += 1
                previous_index_product += 1
               
                cloud_kitchen_list_key.append(key_cloud_kitchen_category)
                cloud_kitchen_list_key.append(key_cloud_kitchen_product)
                let syncCateegoryFunc:SyncFunc = {
                    self.get_cloud_kitchen_category(brand_id)
                }
                let syncProductsFunc:SyncFunc = {
                    self.get_cloud_kitchen_product_product(brand_id)
                }
                list_items[key_cloud_kitchen_category ] = ["get cloud kitench category \(brand_id)",
                                                                         false,
                                                                        syncCateegoryFunc,
                                                                         "",previous_index_cate ,true]
                
                list_items[key_cloud_kitchen_product] = [ "get cloud kitench product product \(brand_id)",false,syncProductsFunc,"",previous_index_product ,true]

            }
            list_keys.insert(contentsOf: cloud_kitchen_list_key , at: indexCategoryKey)
//            if cloudKitchenIDs.count > 0 {
//                SharedManager.shared.appSetting().enable_cloud_kitchen = .START_SESSION
//                SharedManager.shared.appSetting().save()
//            }

        }
        
    }
    func get_cloud_kitchen_product_product(_ brand_id:Int)
    {
        
        let item_key = "get_cloud_kitench_product_product_\(brand_id)"
        if localCash?.isTimeTopdate(item_key) == false {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
            
        }
        
        
        con!.get_cloud_kitench_product_product(with: brand_id) { (result) in
            
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
//                let cls = product_product_class(fromDictionary: [:])
                
//                pos_base_class.create_temp(  cls.dbClass!)
                product_product_class.resetBrandId(with :brand_id)

                product_product_class.saveAll(arr: list,temp: false)
//                pos_base_class.copy_temp( cls.dbClass!)
                let tagFileName = "_\(brand_id)"
                SharedManager.shared.removeNotUsesFiles(from: .images, in: .product_product,
                                                                        filesName: list.map({"\($0["id"] as? Int ?? 0 )\(tagFileName).png"}),tagName: tagFileName)
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
        }
        
    }
    func get_cloud_kitchen_category(_ brand_id: Int)
    {
        let item_key = "get_cloud_kitench_category_\(brand_id)"
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
 
        
        con!.get_cloud_kitench_category(with: brand_id) { (result) in
            
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
//                let cls = pos_category_class(fromDictionary: [:])
//
//                pos_base_class.create_temp(  cls.dbClass!)
                pos_category_class.resetBrandId(with :brand_id)

                pos_category_class.saveAll(arr: list,temp: false)
//                pos_base_class.copy_temp( cls.dbClass!)
                let tagFileName = "_\(brand_id)"

                SharedManager.shared.removeNotUsesFiles(from: .images, in: .pos_category,
                                                                        filesName: list.map({"\($0["id"] as? Int ?? 0 )\(tagFileName).png"}),tagName: tagFileName)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
        }
        
        
    }
}
