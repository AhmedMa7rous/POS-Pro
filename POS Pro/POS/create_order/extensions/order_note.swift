//
//  order_note.swift
//  pos
//
//  Created by Khaled on 8/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation
typealias order_note = create_order
extension order_note:product_note_delegate
{
    
    func show_add_note()
    {
        if self.orderVc?.order.pos_order_lines.count == 0
                  {
                      printer_message_class.show("Please add product.")
                      return
                  }
        
          //        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
          //        let vc = storyboard.instantiateViewController(withIdentifier: "product_note") as! product_note
          //
          //        vc.orderVc?.order = orderVc?.order
          //        vc.delegate = self
          //
          //        vc.modalPresentationStyle = .overFullScreen
          //
          //        self.present(vc, animated: true, completion: nil)
          
          let storyboard = UIStoryboard(name: "notes", bundle: nil)
        product_note_vc = storyboard.instantiateViewController(withIdentifier: "product_note") as? product_note
          
        product_note_vc!.delegate = self
        product_note_vc!.order = orderVc?.order
        product_note_vc!.view.frame = self.right_view.bounds
        
        clear_right()
        self.right_view.addSubview(product_note_vc!.view)
    }
    
    func add_note(product:product_product_class?)
      {

          show_add_note()
        
//          vc.modalPresentationStyle = .popover
//
//          let popover = vc.popoverPresentationController!
//          popover.sourceView = view_orderList
//          popover.sourceRect = view_orderList.frame
          
//          self.present(vc, animated: true, completion: nil)
      }
      
      func note_added() {
          
          orderVc?.reload_footer()
        orderVc?.tableview.reloadData()
//          self.orderVc?.reloadTableOrders()
          self.reloadTableOrders()
              newBannerHolderview.setEnableSendKitchen(with: true)
//          failureSendBtn.isHidden = true

          
      }
      
      func no_notes()
      {
          
      }
      
}
