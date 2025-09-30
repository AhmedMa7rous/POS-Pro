//
//   StorableItemModel.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/11/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
struct StorableItemModel : Codable {
    let id : Int?
    let display_name : String?
    let name : String?
    let tracking : String?
    var categ_id : [String] = [String]()
    let barcode : Bool?
    let default_code : String?
    var uom_id : [String] = [String]()
    var uom_category_id : [String] = [String]()
    var product_tmpl_id : [String] = [String]()
    var qty : Double = 0.0
    var inv_uom_id : [String] = [String]()
    var select_uom_id : [String] = [String]()
    var uom_po_id : [String] = [String]()

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case display_name = "display_name"
        case name = "name"
        case tracking = "tracking"
        case categ_id = "categ_id"
        case barcode = "barcode"
        case default_code = "default_code"
        case uom_id = "uom_id"
        case uom_category_id = "uom_category_id"
        case product_tmpl_id = "product_tmpl_id"
        case inv_uom_id = "inv_uom_id"
        case uom_po_id = "uom_po_id"

    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {  id = try values.decodeIfPresent(Int.self, forKey: .id) } catch { id = nil }
        
        do {  display_name = try values.decodeIfPresent(String.self, forKey: .display_name) } catch { display_name = nil }
        do {  name = try values.decodeIfPresent(String.self, forKey: .name) } catch { name = nil }
        do {  tracking = try values.decodeIfPresent(String.self, forKey: .tracking) } catch { tracking = nil }
        do {
            var categIddArray = try values.nestedUnkeyedContainer(forKey: .categ_id)
            while !categIddArray.isAtEnd {
                do {
                    let string = try categIddArray.decode(String.self)
                    categ_id.append(string)
                } catch {
                    let int = try categIddArray.decode(Int.self)
                    categ_id.append(String(int))
                }
            }
        } catch {
            categ_id = []
        }
        
        
        
        do {  barcode = try values.decodeIfPresent(Bool.self, forKey: .barcode) } catch { barcode = nil }
        do {  default_code = try values.decodeIfPresent(String.self, forKey: .default_code) } catch { default_code = nil }
        do {
            var uomIdArray = try values.nestedUnkeyedContainer(forKey: .uom_id)
            while !uomIdArray.isAtEnd {
                do {
                    let string = try uomIdArray.decode(String.self)
                    uom_id.append(string)
                } catch {
                    let int = try uomIdArray.decode(Int.self)
                    uom_id.append(String(int))
                }
            }
        } catch {
            uom_id = []
        }
        do {
            var uomCategoryIdArray = try values.nestedUnkeyedContainer(forKey: .uom_category_id)
            while !uomCategoryIdArray.isAtEnd {
                do {
                    let string = try uomCategoryIdArray.decode(String.self)
                    uom_category_id.append(string)
                } catch {
                    let int = try uomCategoryIdArray.decode(Int.self)
                    uom_category_id.append(String(int))
                }
            }
        } catch {
            uom_category_id = []
        }
        do {
            var uproductTmplIDArray = try values.nestedUnkeyedContainer(forKey: .product_tmpl_id)
            while !uproductTmplIDArray.isAtEnd {
                do {
                    let string = try uproductTmplIDArray.decode(String.self)
                    product_tmpl_id.append(string)
                } catch {
                    let int = try uproductTmplIDArray.decode(Int.self)
                    product_tmpl_id.append(String(int))
                }
            }
        } catch {
            product_tmpl_id = []
        }
        
        do {
            var uomIdArray = try values.nestedUnkeyedContainer(forKey: .inv_uom_id)
            while !uomIdArray.isAtEnd {
                do {
                    let string = try uomIdArray.decode(String.self)
                    inv_uom_id.append(string)
                } catch {
                    let int = try uomIdArray.decode(Int.self)
                    inv_uom_id.append(String(int))
                }
            }
        } catch {
            inv_uom_id = []
        }
        do {
            var uomPoIdArray = try values.nestedUnkeyedContainer(forKey: .uom_po_id)
            while !uomPoIdArray.isAtEnd {
                do {
                    let string = try uomPoIdArray.decode(String.self)
                    uom_po_id.append(string)
                } catch {
                    let int = try uomPoIdArray.decode(Int.self)
                    uom_po_id.append(String(int))
                }
            }
        } catch {
            uom_po_id = []
        }
        select_uom_id = inv_uom_id
    }

}
