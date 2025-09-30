//
//  homeCollectionViewCell.swift
//  pos
//
//  Created by khaled on 8/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class product_noteViewCell: UICollectionViewCell {
    
    
    //    @IBOutlet var lblTitle: KLabel!
    //    @IBOutlet var cell_bg: ShadowView!
    //
    //
    //    var note :pos_product_notes_class!
    //
    //    var selected_bg:Bool = false
    //
    //    func updateCell() {
    //
    //          lblTitle.text = note.display_name
    //        if selected_bg == true
    //        {
    //            cell_bg.backgroundColor = UIColor.lightGray
    //        }
    //        else
    //        {
    //            cell_bg.backgroundColor = UIColor.white
    //
    //        }
    //    }
    
    
    //
    //  homeCollectionViewCell.swift
    //  pos
    //
    //  Created by khaled on 8/14/19.
    //  Copyright © 2019 khaled. All rights reserved.
    //
    
    
    @IBOutlet var combo_view: ShadowView!
    @IBOutlet var combo_view_selected: ShadowView!
    
    @IBOutlet var combo_qty: KLabel!
    @IBOutlet var combo_title: KLabel!
    @IBOutlet var combo_title_selected: KLabel!
    
    var note :pos_product_notes_class!
    
    var parent_vc:product_note?
    
    func updateCell()
    {
         
        combo_view_selected.isHidden = true
        
        combo_view.isHidden = false
        
         let get_note =  parent_vc?.list_notes_selected[note.id]
        
       if get_note != nil
          {
              if get_note!.qty > 0
                    {
                        combo_view.isHidden = true
                                       combo_view_selected.isHidden = false
                                     combo_qty.text = String( get_note!.qty)
                    }
          }
        
        
        
        combo_title.text = note.display_name
        combo_title_selected.text = note.display_name
        
    }
    
    @IBAction func btn_plus(_ sender: Any) {
            
        
                parent_vc?.add_note(note: note , plus: true)
          

        }
        
        @IBAction func btn_minus(_ sender: Any) {
             
                      parent_vc?.add_note(note: note , plus: false)
        }
    
}
