//
//  create_order + cloudKitchen.swift
//  pos
//
//  Created by M-Wageh on 13/10/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
extension create_order {
    func didSelectBrand(){
        if let selectedBrandName = SharedManager.shared.selected_pos_brand_name {
            self.categories_top.resetCategory(AnyClass.self)
            self.categories_top.setTitleHome(with: selectedBrandName)
            self.getProduct()
        }
       
    }
}
