//
//  Invoice+items.swift
//  pos
//
//  Created by  Mahmoud Wageh on 4/1/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
//MARK:-ITEMS
extension InvoiceComposer {
    //MARK:- Render items.
    func renderItems(item:pos_order_class) -> String {
//        guard let item = self.objecPrinter!.order else {
//            return ""
//        }
        let rowsItems:NSMutableString = NSMutableString()
        let singleItemHtmlString =  getSingleItemFromHtmlFile()
        let comboItemHtmlString =  getSingleItemComboFromHtmlFile()
        
        rowsItems.append( renderOrderItem(item,htmlContent: singleItemHtmlString,htmlContentCombo:comboItemHtmlString) )
        for subItem in ( self.objecPrinter!.sub_Order ?? [])
        {
            guard let subItem = subItem else {
                continue
            }
            rowsItems.append(renderOrderItem(subItem,isReturn: true,htmlContent: singleItemHtmlString,htmlContentCombo: comboItemHtmlString) )
        }
        return String(rowsItems)
    }
     func getSingleItemFromHtmlFile() -> String{
        let isKDS = self.objecPrinter!.for_kds
        if isKDS {
            return CashHtmlFiles.shared.single_item_kds ?? ""
        }
        if SharedManager.shared.appSetting().enable_show_unite_price_invoice {
             return CashHtmlFiles.shared.single_item_unite_price ?? ""
         }
        return CashHtmlFiles.shared.single_item ?? ""
    }
     func getSingleItemComboFromHtmlFile() -> String{
        let isKDS = self.objecPrinter!.for_kds
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
     func renderOrderItem(_  item: pos_order_class,isReturn:Bool = false , htmlContent:String,htmlContentCombo:String ) -> String {
        let isKDS = self.objecPrinter!.for_kds
        let rowsItems:NSMutableString = NSMutableString()
        
        for line in  item.pos_order_lines
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

            if self.objecPrinter!.hideComboDetails == false || self.objecPrinter!.for_kds == true{
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
                
                if self.objecPrinter!.hideCalories == false
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
    //MARK:- get Single Item From pos_order_line_class
     func getItemFrom(_ line: pos_order_line_class,is_return: Bool = false) -> SingleInvocieItem
    {
        //MARK:- QTY
        var qty_new = line.qty
        let price_additional_tax_double = (((line.price_subtotal_incl ?? 0) - (line.price_subtotal ?? 0)))/qty_new
        let price_additional_tax = price_additional_tax_double.toIntString()
        let price_unite = ((line.price_subtotal ?? 0)/qty_new ).toIntString()
        if self.objecPrinter!.print_new_only == true
        {
            // KDS ONLY
            // MARK:- Problem wrong qunaty with kitchen
            let print_count = pos_order_helper_class.get_print_count(order_id:  self.objecPrinter!.order!.id!)
            if abs(line.qty - line.last_qty) != 0
                && line.qty > 0
                && print_count > 1
            {
                qty_new =   line.qty - line.last_qty
            }
            
        }
        //MARK:- DES NAME
         let product:product_product_class? = product_product_class.get(id: line.product_id!) //line.product!
        var name = ""
        if ( product?.name ?? "" ) ==  (product?.name_ar ?? "") {
            name = product?.name ?? ""
        }else{
            name = String(format: "%@ <br> %@", product?.name ?? "" , product?.name_ar ?? "")
        }
        //        if !product.attribute_names.isEmpty
        //        {
        //            name = String(format: "%@ - %@", name, product.attribute_names)
        //        }
        if (line.pos_multi_session_write_date ?? "") != "" &&
            line.qty > 0 &&
            line.last_qty > 0  &&
            self.objecPrinter!.for_kds == true
        {
            if (qty_new < line.qty){
                name = String(format: "*** Added - %@ (total: %@)", name, "\(line.qty)" )

            }else{
                name = String(format: "*** Updated - %@ (total: %@)", name, "\(line.qty)" )

            }
            
        }
        else if line.qty < 0 &&  self.objecPrinter!.for_kds == true
        {
            name = String(format: "*** Updated - %@", name )
        }
        
        if line.qty > 1 &&  self.objecPrinter!.for_kds == false
        {
            let priceUnite = String(format: "( \(SharedManager.shared.getCurrencySymbol()) %@/pcs )" , line.price_unit!.toIntString())
            name = String(format: "%@ %@" ,name, priceUnite)
        }
        
        if  self.objecPrinter!.hideCalories == false
        {
            if line.product.calories != 0
            {
                name = String(format: "%@ - Calories( %@ ) ", name , line.product.calories.toIntString())
            }
        }
        //MARK:- note
        var note = line.note ?? ""
        if !note.isEmpty
        {
            note = note.replacingOccurrences(of: "\n", with: " ")
            name = String(format: "%@ <br /> %@", name , "")
        }
        
        if line.pos_promotion_id != 0 && self.objecPrinter!.for_kds == false
        {
            let prom = pos_promotion_class.get(id: line.pos_promotion_id!) 
            if prom != nil
            {
                note = note + "<br /> <b> " + (prom?.display_name ?? "") + "</b>"
            }
        }
        
        //MARK:- price
        var price:String = baseClass.currencyFormate(line.price_subtotal_incl! )   //+  currency
        if  self.objecPrinter!.hidePrice
        {
            price = "&nbsp"
        }
        //MARK:- return_style
        var return_style = ""
        if ( is_return &&  self.objecPrinter!.for_kds == true) ||
            (line.qty < 0 &&  self.objecPrinter!.for_kds == true)
        {
            return_style = "text-decoration-line: line-through;"
            name = name.replacingOccurrences(of: "*** Updated -", with: "")
            name = String(format: "*** Return - %@", name )
        }else{
            if qty_new < 0
            {
                return_style = "text-decoration-line: line-through;"
                name = name.replacingOccurrences(of: "*** Updated -", with: "")
                if self.objecPrinter!.for_kds == true{
                    name = String(format: "*** Void - %@", name )
                }
                //            qty_new =  qty_new
            }else{
                if line.is_void!
                {
                    return_style = "text-decoration-line: line-through;"
                    name = name.replacingOccurrences(of: "*** Updated -", with: "")
                    if self.objecPrinter!.for_kds == true{
                        name = String(format: "*** Void - %@", name )
                    }
                    qty_new =  qty_new * -1
                    
                }
            }
            
        }
        if self.objecPrinter!.hideComboDetails  && self.objecPrinter!.for_kds == false {
            note = ""
        }
        
        return SingleInvocieItem(qt: qty_new.toIntString(),
                                 des: name + " " + note, price: price, returnStyle: return_style,price_unite:price_unite,price_additional_tax: price_additional_tax)
    }
    //MARK:- get Single combo Item From pos_order_line_class
     func getComboItemFrom(_ p: pos_order_line_class,is_return: Bool = false) -> (SingleInvocieItem,Double)
    {
        var total_calories = 0.0
        //MARK:- QTY
        var qty = p.qty.toIntString()
        let price_additional_tax_double = (((p.price_subtotal_incl ?? 0) - (p.price_subtotal ?? 0))) /  p.qty
        let price_additional_tax = price_additional_tax_double.toIntString()
        let price_unite = ((p.price_subtotal ?? 0)/p.qty).toIntString()
        if self.objecPrinter!.print_new_only == true
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
            if self.objecPrinter!.hideCalories == false
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
            if self.objecPrinter!.hideComboDetails && self.objecPrinter!.for_kds == false {
                line_notes = ""
            }
            
            if p.extra_price !=  0 &&  self.objecPrinter!.hidePrice == false
            {
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
