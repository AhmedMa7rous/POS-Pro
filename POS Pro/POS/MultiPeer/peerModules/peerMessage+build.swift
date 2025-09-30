//
//  peerMessage+ext.swift
//  CDS
//
//  Created by khaled on 11/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
extension peerMessage
{
    func build(pos:pos_config_class) -> String?
    {
        let pos = SharedManager.shared.posConfig()
        
        let config = peerConfig(
            messageType: peerMessageType.posInfo.rawValue,
            id: pos.id,
            name: pos.name,
            logo: FileMangerHelper.shared.getLogoBase64(),
            casherName: SharedManager.shared.activeUser().name,
            sliderImages: pos.slider_images,
            posUrl: api.getDomain()
        )
        
        return config.toJson()
    }
    
    func build(order:pos_order_class)  -> String?
    {
        let customer = order.customer
        
        var peerLines:[peerOrderLine] = []
        
        for line in order.pos_order_lines
        {
           
           let prl =  readLine(line: line)
            
            peerLines.append(prl)
            
        }
        let isVoid = order.is_void //|| (order.amount_total == 0.0)
        let priceDelivery = order.get_delivery_line(wtCheckArea: false)?.price_subtotal ?? 0
        let priceServiceCharge = order.get_service_charge_line()?.price_subtotal ?? 0
        let priceDisCount = order.get_discount_line()?.price_subtotal ?? 0
        let priceTobaco = order.is_have_extra_fees()?.price_subtotal ?? 0

        let subTotal = (order.amount_total) //- priceServiceCharge - priceDisCount - priceTobaco - priceDelivery

        let ord = peerOrder(
            messageType:peerMessageType.order.rawValue,
            id: order.id,
            sequence_number: order.sequence_number,
            table_id: order.table_id,
            
            total_items: isVoid ? "0" : order.total_items.toIntString(),
            amount_tax:  isVoid ? "0" : order.amount_tax.toIntString(),
            amount_paid: isVoid ? "0" : order.amount_paid.toIntString(),
            amount_return:  isVoid ? "0" : order.amount_return.toIntString(),
            amount_total:  isVoid ? "0" : subTotal.toIntString(),
            delivery_amount:  isVoid ? "0" : priceDelivery.toIntString(),
            setvice_charge_amount :  isVoid ? "0" : priceServiceCharge.toIntString() ,
            discount_amount:  isVoid ? "0" : priceDisCount.toIntString() ,
            tobaco_fees_amount: isVoid ? "0" :  priceTobaco.toIntString(),
            customerName: customer?.name,
            customerPhone: customer?.phone,
            closed:order.is_closed,
            void:order.is_void,

            pos_order_lines:peerLines,
            loyalty_earned_point: isVoid ? "0" : order.loyalty_earned_point.toIntString(),
            loyalty_earned_amount: isVoid ? "0" : order.loyalty_earned_amount.toIntString(),
            loyalty_redeemed_point:isVoid ? "0" : order.loyalty_redeemed_point.toIntString(),
            loyalty_redeemed_amount:isVoid ? "0" : order.loyalty_redeemed_amount.toIntString(),
            loyalty_points_remaining_partner:isVoid ? "0" : order.loyalty_points_remaining_partner.toIntString(),
            loyalty_amount_remaining_partner:isVoid ? "0" : order.loyalty_amount_remaining_partner.toIntString()
          
           )
        
        
        return ord.toJson()

    }
    
    func readLine(line:pos_order_line_class) -> peerOrderLine
    {
        var comboLines:[peerOrderLine] = []

        if line.is_combo_line == true
        {
            
            for comboline in line.selected_products_in_combo
            {
               
               let prl =  readLine(line: comboline)
                comboLines.append(prl)
                
            }
        }
        
        
        let prlCombo = peerOrderLine(
            qty:  line.qty.toIntString() ,
         productName: line.product.name,
         productPrice: line.price_subtotal_incl?.toIntString() ?? "" ,
         productNote: line.note ?? "",
         is_combo_line: line.is_combo_line ?? false,
         selected_products_in_combo: comboLines,
            void:line.is_void ?? false
        )
        
        return prlCombo
        
    }
    
}
