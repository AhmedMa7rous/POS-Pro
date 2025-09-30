//
//  stock_inventory_line.swift
//  pos
//
//  Created by M-Wageh on 01/09/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

struct StockInventoryLineModle : Codable {
    let id : Int?
    var product_id : [String] = [String]()
//    var product_uom_id : [String] = [String]()
    var uom_id : [String] = [String]()
    var location_id : [String] = [String]()
    let prod_lot_id : Int?
    let theoretical_qty : Double?
    var product_qty : Double?
    private var product_qty_uom : Double?
    var isQtyUpdated: Bool = false
    private var selected_qty : Double?


    enum CodingKeys: String, CodingKey {

        case id = "id"
        case product_id = "product_id"
//        case product_uom_id = "product_uom_id"
        case location_id = "location_id"
        case prod_lot_id = "prod_lot_id"
        case theoretical_qty = "theoretical_qty"
        case product_qty = "product_qty"
        case product_qty_uom = "product_qty_uom"
        case uom_id = "uom_id"


    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do { id = try values.decodeIfPresent(Int.self, forKey: .id)} catch { id = nil }
        do {
            var product_id_array = try values.nestedUnkeyedContainer(forKey: .product_id)
            while !product_id_array.isAtEnd {
                do {
                    let string = try product_id_array.decode(String.self)
                    product_id.append(string)
                } catch {
                    let int = try product_id_array.decode(Int.self)
                    product_id.append(String(int))
                }
            }
        } catch {
            product_id = []
            
        }
        /*
        do {
            var product_uom_id_array = try values.nestedUnkeyedContainer(forKey: .product_uom_id)
            while !product_uom_id_array.isAtEnd {
                do {
                    let string = try product_uom_id_array.decode(String.self)
                    product_uom_id.append(string)
                } catch {
                    let int = try product_uom_id_array.decode(Int.self)
                    product_uom_id.append(String(int))
                }
            }
        } catch { product_uom_id = [] }
        */
        do {
            var location_id_array = try values.nestedUnkeyedContainer(forKey: .location_id)
            while !location_id_array.isAtEnd {
                do {
                    let string = try location_id_array.decode(String.self)
                    location_id.append(string)
                } catch {
                    let int = try location_id_array.decode(Int.self)
                    location_id.append(String(int))
                }
            }
            
        } catch { location_id = [] }
        do { prod_lot_id = try values.decodeIfPresent(Int.self, forKey: .prod_lot_id)} catch { prod_lot_id = nil }
        do { theoretical_qty = try values.decodeIfPresent(Double.self, forKey: .theoretical_qty)} catch { theoretical_qty = nil }
        do { product_qty = try values.decodeIfPresent(Double.self, forKey: .product_qty)} catch { product_qty = nil }
        do { product_qty_uom = try values.decodeIfPresent(Double.self, forKey: .product_qty_uom)} catch { product_qty_uom = nil }
        do {
            var uom_id_array = try values.nestedUnkeyedContainer(forKey: .uom_id)
            while !uom_id_array.isAtEnd {
                do {
                    let string = try uom_id_array.decode(String.self)
                    uom_id.append(string)
                } catch {
                    let int = try uom_id_array.decode(Int.self)
                    uom_id.append(String(int))
                }
            }
        } catch {
            uom_id = []
            
        }
        isQtyUpdated = false
        selected_qty = 0.0

    }
    func getQty()->Double?{
        if SharedManager.shared.appSetting().enable_initalize_adjustment_with_zero{
            return self.selected_qty
        }else{
            return self.product_qty_uom
        }
    }
    mutating func setQty(with qty:Double){
        if SharedManager.shared.appSetting().enable_initalize_adjustment_with_zero{
             selected_qty = qty
        }else{
             product_qty_uom = qty
        }
    }
    mutating func initalizeQty(){
        if SharedManager.shared.appSetting().enable_initalize_adjustment_with_zero{
             selected_qty = product_qty_uom
        }
    }
    func getQtyForReport()->Double?{
        if SharedManager.shared.appSetting().enable_initalize_adjustment_with_zero{
            
            return self.selected_qty
        }else{
            return self.product_qty_uom
        }
    }
    

}
