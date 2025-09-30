//
//  promotionSelect.swift
//  pos
//
//  Created by khaled on 08/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit




class promotionSelect:  baseViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tableviewPromotions: UITableView!
    @IBOutlet weak var tableCondtions: UITableView!
    @IBOutlet weak var container: UIView!

    var list_promotions:[[String:Any]] = []
    var list_condtions:[[String:Any]] = []
    var list_selected:[pos_order_line_class] = []


    var didSelect : (([pos_order_line_class],promotion_types) -> Void)?
    
    var parent_line:pos_order_line_class!
    var  order:pos_order_class!
  
    var filter:promotionSelectFilter!
    var selectedhelper:promotionSelectHelper = promotionSelectHelper()
    
    override func viewDidLoad() {
        self.stop_zoom = true
        super.viewDidLoad()

 
        selectedhelper.order = order
        selectedhelper.parentLine = parent_line
         
        list_selected.append(contentsOf: selectedhelper.getChildPromotion())

        for row in list_selected
        {
            row.tag_temp = "selected"
        }
        
        if list_selected.count != 0
        {
            let tempLine = list_selected.first(where: {$0.pos_promotion_id != 0})
            
            if tempLine != nil
            {
                let promotion_id = tempLine!.pos_promotion_id

                selectedhelper.promotion = pos_promotion_class.get(id: promotion_id!)
                
                showCondtions()
            }
            
     
        }
 
    }

  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.tag == 0
        {
            return 55
        }
        else
        {
            return 80

        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0
        {
            return tableViewPromotions(tableView,numberOfRowsInSection:section)
        }
        else
        {
            return tableViewCondtions(tableView,numberOfRowsInSection: section)

        }
     }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0
        {
            return tableViewPromotions(tableView,cellForRowAt:indexPath)
        }
        else
        {
            return tableViewCondtions(tableView,cellForRowAt: indexPath)

        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView.tag == 0
        {
            return tableViewPromotions(tableView,didSelectRowAt:indexPath)
        }
        else
        {
            return tableViewCondtions(tableView,didSelectRowAt: indexPath)

        }
        
    }
    
 
    
    func getProduct(_ _selectedhelper:promotionSelectHelper) -> product_product_class?
    {
        if _selectedhelper.promotion.promotionType == .Buy_X_Get_Y_Free
          {
              return   product_product_class.get(id: _selectedhelper.pos_condition!.product_y_id)!
                
          }
          else if _selectedhelper.promotion.promotionType  == .Buy_X_Get_Discount_On_Y
          {
               return product_product_class.get(id: _selectedhelper.get_discount!.product_id_dis_id)!
  
          }
          else if _selectedhelper.promotion.promotionType  == .Buy_X_Get_Fix_Discount_On_Y
          {
               return product_product_class.get(id: _selectedhelper.get_discount!.product_id_dis_id)!
 
          }
          else if _selectedhelper.promotion.promotionType  == .Percent_Discount_on_Quantity
          {
               return product_product_class.get(id: _selectedhelper.promotion.product_id_qty)!
 
          }
          else if _selectedhelper.promotion.promotionType  == .Fix_Discount_on_Quantity
          {
               return product_product_class.get(id: selectedhelper.promotion.product_id_amt)!
 
          }
        
        return nil
    }
    

    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnApply(_ sender: Any) {
        let listSelected = list_selected.filter({$0.tag_temp == "selected"})
        if listSelected.count <= 0 {
            SharedManager.shared.initalBannerNotification(title: "", message: "You must select promotion which will apply".arabic("يجب عليك تحديد العرض الذي سيتم تطبيقه"), success: false, icon_name: "icon_error")
            SharedManager.shared.banner?.dismissesOnTap = true
            SharedManager.shared.banner?.show(duration: 3.0)
            
            return

            
        }
        
        if selectedhelper.promotion != nil
        {
            self.didSelect!(list_selected,selectedhelper.promotion.promotionType! )
        }
        
        self.dismiss(animated: true, completion: nil)

     
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

