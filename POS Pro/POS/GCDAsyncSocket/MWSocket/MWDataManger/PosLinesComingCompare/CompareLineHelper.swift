//
//  CompareLineHelper.swift
//  pos
//
//  Created by M-Wageh on 19/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class CompareLineHelper{
     static let shaed = CompareLineHelper()
    private init(){}
     func checkLineDifferent(_ comingLine:pos_order_line_class,_ existLine:pos_order_line_class) -> Bool {
        let isNotSameQty = comingLine.qty != existLine.qty
        let isNotSameProductID =  comingLine.product_id != existLine.product_id
        let isNotSameProductTmplID = comingLine.product_tmpl_id != existLine.product_tmpl_id
        let isNotSameVoid = existLine.is_void !=  comingLine.is_void
        let isNotSameNote = existLine.note !=  comingLine.note
         let isNotSameScrapResson = existLine.scrap_reason !=  comingLine.scrap_reason

         let isNotSamePrice = existLine.price_subtotal_incl !=  comingLine.price_subtotal_incl

        return isNotSameQty || isNotSameProductID || isNotSameProductTmplID || isNotSameVoid || isNotSameNote || isNotSamePrice || isNotSameScrapResson
    }
    //MARK: - saveComboLine
     func saveNewComboProductLine(line:pos_order_line_class,
                               lineID:Int,
                               order_id:Int
                               ,with order_uid:String
                               ){
        var count = 0
        
        line.selected_products_in_combo.forEach { combo_line in
            combo_line.id = 0
            if !(combo_line.is_void ?? false) {
            count += 1
            SharedManager.shared.printLog("combo_line = \(count) , line_id = \(lineID) , combo_line = \(combo_line.id)")
            combo_line.order_id = order_id
            combo_line.parent_line_id = lineID
                combo_line.last_qty = 0
                combo_line.printed = ptint_status_enum.none
                combo_line.combo_id = nil
           let id_combo_db = combo_line.save()
                SharedManager.shared.printLog("id_combo_db = \(id_combo_db) ")
            }
        }
    }
    //MARK: - saveNewLines
    func saveNewLines(_ newLines:[pos_order_line_class],with order_uid:String, order_id:Int,line_id:Int? ){
        var count = 0
        newLines.forEach { newLine in
            newLine.id = 0
            count += 1
            SharedManager.shared.printLog("==============================================================")
            SharedManager.shared.printLog("line_number = \(count) , line_id = \(newLine.id)")

            if let lineID = line_id {
                //product combo
                
               
                newLine.order_id = order_id
                newLine.parent_line_id = lineID
                newLine.last_qty = 0
                newLine.printed = ptint_status_enum.none

                let id_line_db = newLine.save(write_info:false)
                SharedManager.shared.printLog("id_line_db = \(id_line_db) ")

            }else{
                if !(newLine.is_void ?? false) {
                newLine.order_id = order_id
                newLine.last_qty = 0
                newLine.printed = ptint_status_enum.none

                let lineID = newLine.save()
                    SharedManager.shared.printLog("lineID = \(lineID) ")

                if newLine.is_combo_line ?? false {
                    self.saveNewComboProductLine(line:newLine,lineID:lineID,order_id:order_id,with:order_uid)
                }
            }
            }
        }
    }
    //MARK: - saveEditLines
    func saveEditLines(_ editLines:[pos_order_line_class],with order_uid:String,isVoid:Bool? = nil){
        Array(Set(editLines)).forEach { editLine in
            let db_line = getLineDB(for :editLine)
            db_line.qty = editLine.qty
            db_line.last_qty = editLine.last_qty
            if  db_line.qty != editLine.qty || db_line.isVoidFromUI() != editLine.isVoidFromUI() {
                db_line.printed = .none
            }else{
                db_line.printed = editLine.printed
            }
//            db_line.last_qty = editLine.last_qty
            db_line.product_id =  editLine.product_id
            db_line.product_tmpl_id = editLine.product_tmpl_id
            if let isVoid = isVoid {
                db_line.is_void =  isVoid
            }else{
            db_line.is_void =  editLine.is_void
            }
            db_line.note =  editLine.note
            db_line.write_pos_id = editLine.write_pos_id
            db_line.write_user_id = editLine.write_user_id
            db_line.write_user_name = editLine.write_user_name
            db_line.write_pos_code = editLine.write_pos_code
            db_line.write_pos_name = editLine.write_pos_name
            db_line.custom_price = editLine.custom_price
            db_line.price_unit = editLine.price_unit
            db_line.price_subtotal = editLine.price_subtotal
            db_line.price_subtotal_incl = editLine.price_subtotal_incl
            db_line.extra_price = editLine.extra_price
            db_line.discount = editLine.discount
            db_line.discount_type = editLine.discount_type
            db_line.discount_display_name = editLine.discount_display_name
            db_line.product_lst_price = editLine.product_lst_price
            db_line.scrap_reason = editLine.scrap_reason
            db_line.void_status = editLine.void_status
            db_line.promotion_row_parent = editLine.promotion_row_parent
            db_line.pos_promotion_id = editLine.pos_promotion_id
            db_line.pos_conditions_id = editLine.pos_conditions_id
            db_line.line_repeat = editLine.line_repeat
            db_line.sync_void = editLine.sync_void
            db_line.is_promotion = editLine.is_promotion
            db_line.is_scrap = editLine.is_scrap

            let _ = db_line.save()
        }
    }
    //MARK: - getLineDB
     func getLineDB(for pos_line:pos_order_line_class)->pos_order_line_class{
        if let current_pos_line = pos_order_line_class.get(uid:pos_line.uid ){
            return current_pos_line
            
        }else{
            return pos_order_line_class(fromDictionary: pos_line.toDictionary())
        }
        
    }
}
