//
//  order_cell_header.swift
//  pos
//
//  Created by Khaled on 8/3/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class order_cell_header: UITableViewHeaderFooterView {
    @IBOutlet var view_header: ShadowView!
    @IBOutlet var lbl_total_qty: UILabel!
    @IBOutlet var lbl_product_name: UILabel!
    @IBOutlet var lbl_price: UILabel!
    @IBOutlet var lbl_notes: UILabel!

    @IBOutlet var img_status: KSImageView!

    @IBOutlet weak var statusShadowView: ShadowView!
    @IBOutlet var view_qty: ShadowView!
    var parent_create_order:create_order? // increase memoory

    @IBOutlet weak var voidBtn: KButton!
    
    var tableView:UITableView!
    var offset:CGFloat = 0

    var product_combo:pos_order_line_class?{
        didSet{
            voidBtn.isHidden =  product_combo?.is_void ?? false
            if product_combo?.is_sent_to_kitchen() == true && product_combo?.is_void == false {
                statusShadowView.backgroundColor = #colorLiteral(red: 0.6862745098, green: 0.8980392157, blue: 0.6549019608, alpha: 1)
                lbl_total_qty.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            } else if product_combo?.is_sent_to_kitchen() == false && product_combo?.is_void == false {
                statusShadowView.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.8078431373, blue: 0.6823529412, alpha: 1)
                lbl_total_qty.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            }
        }
    }

    
    func  get_status(line:pos_order_line_class)  {
          // none,pendding,send,rececived
          
//          switch line.pos_multi_session_status {
//          case .none?:
//              img_status.image = nil
//              view_qty.backgroundColor = UIColor.clear
//
//              break
//          case .last_update_from_local:
//
//              img_status.image = nil
//                 view_qty.backgroundColor = UIColor.clear
//              break
//          case .last_update_from_server:
//              img_status.image = UIImage.init(named: "arrow_down.png")
//              view_qty.backgroundColor = UIColor.green
//
//              break
//          case .sending_update_to_server:
//                   img_status.image = UIImage.init(named: "arrow_up.png")
//                  view_qty.backgroundColor = UIColor.yellow
//
//                    break
//          case .sended_update_to_server:
//               img_status.image = UIImage.init(named: "arrow_up.png")
//               view_qty.backgroundColor = UIColor.green
//
//              break
//          default:
//              break
//          }
        
        // no need to colors
            img_status.image = nil
            view_qty.backgroundColor = UIColor.clear
          
          if line.kitchen_status == .done
          {
//              img_status.image = UIImage.init(named: "select.png")
              view_qty.backgroundColor = UIColor.clear
          }
      }
 
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Touches Began. Disable user activity on UITableView
        if product_combo?.is_void ?? false {
            return
        }
        if let touch = touches.first {
            // Get the point where the touch started
            let point = touch.location(in: self.view_header)
            offset = point.x
        }
        
     

    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if product_combo?.is_void ?? false {
            return
        }
        if let touch = touches.first {

            // Get the point where the touch is moving in header
            let point = touch.location(in: self.view_header)

            // Calculate the movement of finger
            let x:CGFloat = offset - point.x
            if x > 0 {
                // Move cells by offset
                moveCellsBy(x: x)
            }

            // Set new offset
            offset = point.x
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Reset offset when user lifts finter
        if product_combo?.is_void ?? false {
            return
        }
        if offset < 80
        {
            offset = 0
        }
        else
        {
            offset =  -80 //self.view_header.frame.size.width
        }

        moveCellsTo(x: offset)
        
//        offset = 0
    }

    func moveCellsBy(x: CGFloat) {
        // Move each visible cell with the offset
        UIView.animate(withDuration: 0.05, animations: {
            self.view_header.frame = CGRect(x:  self.view_header.frame.origin.x - x, y:  self.view_header.frame.origin.y, width:  self.view_header.frame.size.width, height:  self.view_header.frame.size.height)
        })
    }
    
    func moveCellsTo(x: CGFloat) {
        // Move each visible cell with the offset
        UIView.animate(withDuration: 0.3, animations: {
            self.view_header.frame = CGRect(x:  x, y:  self.view_header.frame.origin.y, width:  self.view_header.frame.size.width, height:  self.view_header.frame.size.height)
        } )
        offset = x
    }
    
    @IBAction func btn_void(_ sender: Any) {
        if product_combo != nil
        {
            moveCellsTo(x: 0)
            parent_create_order?.orderVc?.delete_Row(line: product_combo!)

        }

    }
}
