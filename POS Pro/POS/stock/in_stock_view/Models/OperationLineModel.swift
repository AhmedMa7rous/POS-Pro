//
//  OperationLineModel.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/17/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
struct OperationLineModel : Codable {
    let id : Int?
    var product_id : [String]  = [String]()
    var product_uom_qty : Double?
    var product_uom : [String]  = [String]()
    var inv_uom_id : [String]  = [String]()
    var select_uom_id : [String] = [String]()

    var isQtyUpdated: Bool = false
    var quantity_done : Double?
    var total_quantity : Double?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case product_id = "product_id"
        case product_uom_qty = "product_uom_qty"
        case product_uom = "product_uom"
        case quantity_done = "quantity_done"
        case inv_uom_id = "inv_uom_id"

    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {  id = try values.decodeIfPresent(Int.self, forKey: .id) } catch { id = nil }
        do {
            var productIdArray = try values.nestedUnkeyedContainer(forKey: .product_id)
            while !productIdArray.isAtEnd {
                do {
                    let string = try productIdArray.decode(String.self)
                    product_id.append(string)
                } catch {
                    let int = try productIdArray.decode(Int.self)
                    product_id.append(String(int))
                }
            }} catch {
                product_id = []
        }
    
        do { product_uom_qty = try values.decodeIfPresent(Double.self, forKey: .product_uom_qty) } catch { product_uom_qty = nil }
        do { quantity_done = try values.decodeIfPresent(Double.self, forKey: .quantity_done) } catch { quantity_done = nil }

        do {
            var productUomArray = try values.nestedUnkeyedContainer(forKey: .product_uom)
            while !productUomArray.isAtEnd {
                do {
                    let string = try productUomArray.decode(String.self)
                    product_uom.append(string)
                } catch {
                    let int = try productUomArray.decode(Int.self)
                    product_uom.append(String(int))
                }
            }
        } catch {
            product_uom = []
            
        }
        do {
            var invUomIdArray = try values.nestedUnkeyedContainer(forKey: .inv_uom_id)
            while !invUomIdArray.isAtEnd {
                do {
                    let string = try invUomIdArray.decode(String.self)
                    inv_uom_id.append(string)
                } catch {
                    let int = try invUomIdArray.decode(Int.self)
                    inv_uom_id.append(String(int))
                }
            }} catch {
                inv_uom_id = []
        }
        isQtyUpdated = false
        total_quantity = (product_uom_qty ?? 0) + (quantity_done ?? 0)
        select_uom_id = product_uom
    }
    
    init(from model:StockRequestOrderDetailsModel){
         id = model.order_id
         product_id = model.product_id
         product_uom_qty = model.product_uom_qty
         product_uom = model.product_uom_id
        quantity_done = nil
        total_quantity = nil
    }

}
