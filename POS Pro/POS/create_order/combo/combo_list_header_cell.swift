//
//  homeCollectionViewCell.swift
//  pos
//
//  Created by khaled on 8/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class combo_list_header_cell: UICollectionReusableView {
    
 
    
    @IBOutlet var btn_clear_notes: UIButton!
    @IBOutlet var lblTitle: KLabel!

    var parent_combo:combo_vc?
  
    @IBAction func btn_clear_notes(_ sender: Any) {
        
        parent_combo?.clear_notes()
    }
    
    
}
