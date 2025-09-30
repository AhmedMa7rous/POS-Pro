//
//  ProductAvaliablityVM.swift
//  pos
//
//  Created by M-Wageh on 20/03/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
class ProductAvaliablityVM{
    var categoriesData:[pos_category_class]?
//    var selectCategory:pos_category_class?
    var selectCategoryID:Int?
    var selectCategoryName:String?

    var productsData:[ProductAvalibleModel]?
    var selectProduct:ProductAvalibleModel?
    var indexProduct:Int?
    var updateListHandler:(()->Void)?
    
    var productIds: [Int] {
        return product_avaliable_class.getProductsIds().compactMap { $0["id"] as? Int }
    }
    
    func updateStatus(by isActive:Bool)  {
        self.selectProduct?.avaliable_class?.avaliable_status = isActive ? .ACTIVE : .NOT_ACTIVE
          
    }
    func saveUpdateQty(){
        
        self.selectProduct?.avaliable_class?.save()
        if let selectIndex = self.indexProduct{
            self.productsData?[selectIndex].avaliable_class = self.selectProduct?.avaliable_class
        }
        self.selectProduct = nil
        updateListHandler?()
        
    }
    func updateQty(by qtyString:String) -> Bool{
        if let qty = Double(qtyString){
            self.selectProduct?.avaliable_class?.avaliable_qty = qty
            return true
        }
        return false
    }
    func increaseQty(){
        self.selectProduct?.avaliable_class?.avaliable_qty! += 1
    }
    func decreaseQty(){
        if (self.selectProduct?.avaliable_class?.avaliable_qty ?? 0) > 0 {
            self.selectProduct?.avaliable_class?.avaliable_qty! -= 1
        }
    }
    func setSelectProduct(at index:Int){
        selectProduct = productsData?[index]
//        SharedManager.shared.printLog("PRODUCT ID: \(selectProduct?.product_class?.id) and QTY: \(selectProduct?.avaliable_class?.avaliable_qty) and STATUS: \(selectProduct?.avaliable_class?.avaliable_status)")
        indexProduct = index
    }
    
    func getCategoriesCount()->Int{
        return categoriesData?.count ?? 0
    }
    func getProductsCount()->Int{
        return productsData?.count ?? 0
    }
    func getProduct(at index:Int)->ProductAvalibleModel?{
        return self.productsData?[index]
    }
    func setProductsData() -> Bool{
     
            if let cateID = self.selectCategoryID{
                productsData =  ProductAvalibleModel.getProductAvaliable(for:cateID)
                return true

            }
        return false
    }
    func setCategoryList(){
        self.selectCategoryID = nil
        self.selectCategoryName = nil

        self.categoriesData = pos_category_class.getAll().map({pos_category_class(fromDictionary: $0)})
    }
    func getCategoryModel(at index:Int)->pos_category_class?{
        return categoriesData?[index]
    }
    func setSelectCategory(at index:Int){
        if let selectCategory = categoriesData?[index]{
            self.selectCategoryID = selectCategory.id
            self.selectCategoryName = selectCategory.display_name
        }

        
    }
    
   //ProductIDS FOR KATAKEET:  [2171, 4, 6, 2167, 2186, 2210, 1758, 2128, 2153, 1951, 2141, 2, 2075, 1912, 2211, 2132, 2157, 2164, 2133, 2158, 1765, 2117, 2147, 1920, 1821, 1827, 1757, 2139, 2168, 2140, 2032, 2111, 2137, 2161, 1919, 1742, 1741, 1764, 2119, 2142, 2148, 1743, 1745, 1828, 2143, 1744, 2097, 2144, 1746, 1756, 1747, 1918, 1748, 1916, 2120, 2145, 2149, 1735, 2121, 2150, 2093, 2122, 1763, 2126, 1761, 1818, 1767, 2115, 2127, 1762, 1913, 1760, 1759, 1960, 1750, 1829, 1736, 1751, 1752, 1753, 1749, 1738, 1737, 1739]
    
    
    func getProductsAvailability() {
        let api = api()
//        SharedManager.shared.printLog("IDDDDDDDDDDDDDS: \(self.productIds)")
        messages.showAlertForApi(message: "Updating Products Availability Please wait...", title: "Loading", hide: false)
        api.fetchProductAvailability(for: productIds) { [weak self] result in
            //TODO: - handles Error messages
            guard let self = self else {
                messages.showAlert("An unknown error occurred please try again")
                return
            }
            DispatchQueue.main.async {
                messages.showAlertForApi(hide: true)
            }
            if result.success {
                if let response = result.response {
                    let productAvailability = ProductAvailabilityResponseModel(dictionary: response)
                    if let resultData = productAvailability.result {
                        self.handleStorableProducts(resultData.storable)
                        //self.handleConsumableProducts(resultData.consumable)
                    } else {
                        messages.showAlert("Failed to serialize the data try again later")
                    }
                } else {
                    messages.showAlert("No response data please check your internet connection try again later")
                }
            } else {
                messages.showAlert(result.message ?? "An unknown error occurred please check your internet connection and try again")
//                SharedManager.shared.printLog("Failed to fetch product availability: \(result.message ?? "An unknown error occurred.")")
            }
        }
        
    }

    private func handleStorableProducts(_ storableProducts: [Storable]) {
        storableProducts.forEach { storable in
            //TODO: - call func update_qty_from_api from avaliable_class
            product_avaliable_class.update_qty_from_api(for: storable.productID, by: storable.quantity)
            SharedManager.shared.printLog("Storable Product ID: \(storable.productID), Quantity: \(storable.quantity)")
        }
    }

    private func handleConsumableProducts(_ consumableProducts: [Consumable]) {
        consumableProducts.forEach { consumable in
            SharedManager.shared.printLog("Consumable Product ID: \(consumable.productID), Factor: \(consumable.factor), Related Storable Product: \(consumable.relatedStorableProduct)")
        }
    }

    
}
