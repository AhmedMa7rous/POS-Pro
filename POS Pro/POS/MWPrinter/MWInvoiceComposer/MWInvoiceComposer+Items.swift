//
//  MWInvoiceComposer+Items.swift
//  pos
//
//  Created by M-Wageh on 06/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
//MARK:-ITEMS
extension MWInvoiceComposer {
    //MARK:- Render items.
    func renderItems(item:pos_order_class) -> String {
       
        let rowsItems:NSMutableString = NSMutableString()
        let singleItemHtmlString =  getSingleItemFromHtmlFile()
        let comboItemHtmlString =  getSingleItemComboFromHtmlFile()
        
        rowsItems.append( renderOrderItem(item,isReturn: fileType == .return_order ,htmlContent: singleItemHtmlString,htmlContentCombo:comboItemHtmlString) )
//        for subItem in ( self.sub_Order ??   [])
//        {
//            guard let subItem = subItem else {
//                continue
//            }
//            rowsItems.append(renderOrderItem(subItem,isReturn: true,htmlContent: singleItemHtmlString,htmlContentCombo: comboItemHtmlString) )
//        }
        return String(rowsItems)
    }
    private func getSingleItemFromHtmlFile() -> String{
        let isKDS = self.for_kds
        if isKDS {
            return CashHtmlFiles.shared.single_item_kds ?? ""
        }
        if SharedManager.shared.appSetting().enable_show_unite_price_invoice {
             return CashHtmlFiles.shared.single_item_unite_price ?? ""
         }
        return CashHtmlFiles.shared.single_item ?? ""
    }
    private func getSingleItemComboFromHtmlFile() -> String{
        let isKDS = self.for_kds
         if isKDS {
             return CashHtmlFiles.shared.single_item_combo_kds ?? ""
         }
         if SharedManager.shared.appSetting().enable_show_unite_price_invoice {
              return CashHtmlFiles.shared.single_item_combo_unite_price ?? ""
          }
         return CashHtmlFiles.shared.single_item_combo ?? ""
         /*
        
        var pathToSingleItemComboHTMLTemplate = Bundle.main.path(forResource: "single_item_combo", ofType:"html") ?? ""
        if isKDS {
            pathToSingleItemComboHTMLTemplate = Bundle.main.path(forResource: "single_item_combo_kds", ofType:"html") ?? ""
        }
        do{
            let HTMLContentCombo = try String(contentsOfFile: pathToSingleItemComboHTMLTemplate)
            return HTMLContentCombo
        } catch {
            SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
*/
    }
    //MARK:- Render Order Item.
    private func renderOrderItem(_  item: pos_order_class,isReturn:Bool = false , htmlContent:String,htmlContentCombo:String ) -> String {
        let isKDS = self.for_kds
        let rowsItems:NSMutableString = NSMutableString()
        var posLines = item.pos_order_lines
        if !self.for_kds{
          //  if (item.orderType?.order_type ?? "") == "delivery" {
                if let delivery_line = item.get_delivery_line(){
                    if !(delivery_line.is_void ?? false){
                        posLines.removeAll(where: {$0.product_id == delivery_line.product_id })
                        delivery_line.product_id = -2
                        posLines.append(delivery_line)
                    }
                }
          //  }
        }
        for line in  posLines
        {
            var HTMLContent = htmlContent
            let objcITEM = getItemFrom( line,is_return: isReturn)
            let DESC = objcITEM.des
            //                if !(line.note?.isEmpty ?? true)
            //                {
            //                 //   DESC += "<br/>" + (line.note ?? "")
            //                }
            HTMLContent = HTMLContent.replacingOccurrences(of: "#QTY#", with: objcITEM.qty)
            if isKDS {
                HTMLContent = HTMLContent.replacingOccurrences(of: "#RETURN_STYLE#", with: objcITEM.returnStyle)
            }else{
                HTMLContent = HTMLContent.replacingOccurrences(of: "#RETURN_STYLE#", with: "")
            }
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_DESC#", with:  DESC)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PRICE_UNITE#", with: objcITEM.price_unite)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PRICE_ADDITIONAL_TAX#", with: objcITEM.price_additional_tax)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PRICE#", with: objcITEM.price)
            //Combo

            if self.hideComboDetails == false || self.for_kds == true{
                let rowsItemsCombo:NSMutableString = NSMutableString()

            if line.selected_products_in_combo.count > 0 {
                var total_calories = 0.0
                for combo in line.selected_products_in_combo{
                    var HTMLContentCombo = htmlContentCombo
                    let comboObject = getComboItemFrom( combo, is_return: isReturn)
                    total_calories += comboObject.1
                    let singleItem = comboObject.0
                    if isKDS {
                        HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#RETURN_STYLE#", with: singleItem.returnStyle)
                    }else{
                        HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#RETURN_STYLE#", with: "")
                    }
                    HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#QTY#", with: singleItem.qty)
                    HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#ITEM_DESC#", with:  " " + singleItem.des)
                    HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#PRICE_UNITE#", with: singleItem.price_unite)
                    HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#PRICE_ADDITIONAL_TAX#", with: singleItem.price_additional_tax)
                    HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#PRICE#", with:singleItem.price)
                    
                    //                        if combo == line.selected_products_in_combo.last
                    //                        {
                    //                            HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#separator_combo#", with: "separator_combo")
                    //
                    //                        }
                    
                    rowsItemsCombo.append(HTMLContentCombo)
                }
                
                if self.hideCalories == false
                {
                    if total_calories != 0
                    {
                        var HTMLContentCombo = htmlContentCombo
                        HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#RETURN_STYLE#", with: "")
                        HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#QTY#", with: "")
                        HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#ITEM_DESC#", with: "Calories  \(total_calories.toIntString()) Cal ")
                        HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#PRICE_UNITE#", with: "")
                        HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#PRICE_ADDITIONAL_TAX#", with: "")
                        HTMLContentCombo = HTMLContentCombo.replacingOccurrences(of: "#PRICE#", with:"")
                        rowsItemsCombo.append(HTMLContentCombo)
                        
                    }
                    
                }
                
                
            }
                HTMLContent = HTMLContent.replacingOccurrences(of: "#COMBO_ITEM#", with:String(rowsItemsCombo))

            }else{
                HTMLContent = HTMLContent.replacingOccurrences(of: "#COMBO_ITEM#", with:"")
            }
            rowsItems.append(HTMLContent)
        }
        
        return String(rowsItems)
        
        
    }
    private func getQtyAction(for line: pos_order_line_class,is_return:Bool)->String{
        var qtyAction = ""
        if self.for_kds {
        let currentQty = line.qty
        let lastQty = line.last_qty
        let newQty = line.qty - line.last_qty
        if is_return {
            qtyAction = "*** Return -"
        }else if line.is_void ?? false {
            qtyAction = "*** Void -"
        }else  if line.last_qty == 0 {
            qtyAction = ""
        }else if newQty < 0 {
            qtyAction = "*** Void -"
        }else  if currentQty > lastQty {
            qtyAction = "*** Added -"
        }else if lastQty > currentQty{
            qtyAction = "*** Updated -"
        }
        }
        return qtyAction
    }
    //MARK:- get Single Item From pos_order_line_class
    private func getItemFrom(_ line: pos_order_line_class,is_return: Bool = false) -> SingleInvocieItem
    {
        //MARK:- QTY
        var qty_new = line.qty
        let price_additional_tax_double = (((line.price_subtotal_incl ?? 0) - (line.price_subtotal ?? 0)))/qty_new
        let price_additional_tax = price_additional_tax_double.toIntString()
        let price_unite = ((line.price_subtotal ?? 0)/qty_new ).toIntString()

        let actionQty = getQtyAction(for:line,is_return:is_return)
        //MARK:- return_style
        var return_style = ""
        if actionQty.lowercased().contains("void") || actionQty.lowercased().contains("return")
        {
            return_style = "text-decoration-line: line-through;"
        }
        if self.print_new_only  == true
        {
            // KDS ONLY
            // MARK:- Problem wrong qunaty with kitchen
            let print_count = pos_order_helper_class.get_print_count(order_id:  self.order!.id!)
            if abs(line.qty - line.last_qty) != 0
                && line.qty > 0
                && print_count > 1
            {
                qty_new =   line.qty - line.last_qty
            }
            
        }
        if line.is_void ?? false {
            qty_new =  qty_new * -1
        }
        //MARK:- DES NAME
        let productID = line.product_id ?? 0
        var name = ""
        var nameProduct:String = ""
        var nameProductAr:String = ""
        if productID == -2 {
            nameProduct = "Delivery service"
            nameProductAr = "خدمة توصيل"

        }else{
            let product:product_product_class! = product_product_class.get(id: line.product_id!) //line.product!
            nameProduct = product.name
            nameProductAr = product.name_ar
        }
        if  nameProduct ==  nameProductAr {
            name = nameProduct
        }else{
            name = String(format: "%@ <br> %@", nameProduct , nameProductAr)
        }
       //(line.pos_multi_session_write_date ?? "") != "" &&
        if ( line.qty > 0 &&
            line.last_qty > 0  &&
            self.for_kds == true)
        {
            let currentQty = (line.is_void ?? false) ? 0 : line.qty
            name = String(format: "\(actionQty) %@ (total: %@)", name, "\(currentQty)" )
        }else if is_return{
            name = String(format: "\(actionQty) %@ ", name )
        }
       
        
        if line.qty > 1 &&  self.for_kds == false
        {
            let priceUnite = String(format: "( \(SharedManager.shared.getCurrencySymbol()) %@/pcs )" , line.price_unit!.toIntString())
            name = String(format: "%@ %@" ,name, priceUnite)
        }
        
        if  self.hideCalories == false
        {
            if line.product.calories != 0
            {
                name = String(format: "%@ - Calories( %@ ) ", name , line.product.calories.toIntString())
            }
        }
        //MARK:- note
        var note = line.note ?? ""
        if for_kds{
            let kds_note = line.note_kds
            if !kds_note.isEmpty
            {
                note += (" " + kds_note)
            }
        }
        if !note.isEmpty
        {
            note = "\u{202a}\u{2067} \(note.replacingOccurrences(of: "\n", with: " "))"
            name = String(format: "%@ <br /> %@", name , "")
        }
        if line.pos_promotion_id != 0 && self.for_kds == false
        {
            let prom = pos_promotion_class.get(id: line.pos_promotion_id!)
            if prom != nil
            {
                note = note + "<br /> <b> " + (prom?.display_name ?? "") + "</b>"
            }
        }
        
        //MARK:- price
        var price:String = baseClass.currencyFormate(line.price_subtotal_incl! )   //+  currency
        if  SharedManager.shared.appSetting().enable_show_price_without_tax {
            price = baseClass.currencyFormate(line.price_subtotal! )   //+  currency
        }
        if  self.hidePrice
        {
            price = "&nbsp"
        }
       
        if self.hideComboDetails && self.for_kds == false {
            note = ""
        }
        return SingleInvocieItem(qt: qty_new.toIntString(),
                                 des: name + " " + note, price: price, returnStyle: return_style,price_unite:price_unite,price_additional_tax: price_additional_tax)
    }
    //MARK:- get Single combo Item From pos_order_line_class
    private func getComboItemFrom(_ p: pos_order_line_class,is_return: Bool = false) -> (SingleInvocieItem,Double)
    {
        var total_calories = 0.0
        //MARK:- QTY
        var qty = p.qty.toIntString()
        let price_additional_tax_double = (((p.price_subtotal_incl ?? 0) - (p.price_subtotal ?? 0))) /  p.qty
        let price_additional_tax = price_additional_tax_double.toIntString()
        let price_unite = ((p.price_subtotal ?? 0)/p.qty).toIntString()

        if self.print_new_only  == true
        {
            if p.is_void == false
            {
                qty = abs(p.qty - p.last_qty).toIntString()
            }
            else
            {
                qty = p.last_qty.toIntString()
            }
        }
        //MARK:- NOTES
        var line_notes:String = ""
        if !(p.note ?? "").isEmpty
        {
            line_notes = "<br/><br/>"
            line_notes = String(format: "%@-%@",  line_notes  , p.note!.replacingOccurrences(of: "\n", with: " - "))
        }
        
        if p.pos_promotion_id != 0
        {
            let prom = pos_promotion_class.get(id: p.pos_promotion_id!)
            if prom != nil
            {
                line_notes = line_notes + "<br />" + (prom?.display_name ?? "")
            }
        }
        
        //MARK:- NAME
        var name = ""
        if  p.product.name ==  p.product.name_ar {
            name = p.product.name
        }else{
            name = String(format: "%@ - %@", p.product.name , p.product.name_ar)
        }
        //        let name = String(format: "%@ - %@", p.product.name , p.product.name_ar)
        
        if p.default_product_combo == false
        {
            if self.hideCalories == false
            {
                if p.product.calories != 0
                {
                    total_calories = total_calories +  p.product.calories
                    
                }
            }
            //MARK:- return_style
            var return_style = ""
            if p.is_void == true
            {
                
                return_style = "text-decoration-line: line-through;"
            }
            if self.hideComboDetails && self.for_kds == false {
                line_notes = ""
            }
            
            if p.extra_price !=  0 &&  self.hidePrice == false
            {
                if  SharedManager.shared.appSetting().enable_show_price_without_tax {
                    return (SingleInvocieItem(qt: qty,
                                              des: "\(name) \(line_notes)",
                                              price: "\(p.price_subtotal!.toIntString())",
                                              returnStyle: return_style,price_unite:price_unite,price_additional_tax: price_additional_tax),
                            total_calories)
                }
                return (SingleInvocieItem(qt: qty,
                                          des: "\(name) \(line_notes)",
                                          price: "\(p.price_subtotal_incl!.toIntString())",
                                          returnStyle: return_style,price_unite:price_unite,price_additional_tax: price_additional_tax),
                        total_calories)
                
            }
            else
            {
                
                return (SingleInvocieItem(qt: qty,
                                          des: "\(name) \(line_notes)",
                                          price: "",
                                          returnStyle: return_style,price_unite:"",price_additional_tax: ""),
                        total_calories)
            }
        }
        else
        {
            if !(p.note ?? "").isEmpty
            {
                return (SingleInvocieItem(qt: qty,
                                          des: "\(name) \(line_notes)",
                                          price: "",
                                          returnStyle: "",price_unite:"",price_additional_tax: ""),
                        total_calories)
                
            }
        }
        
        return (SingleInvocieItem(qt: qty,
                                  des: "\(name) \(line_notes)",
                                  price: "",
                                  returnStyle: "",price_unite:"",price_additional_tax: ""),
                total_calories)
    }
}
