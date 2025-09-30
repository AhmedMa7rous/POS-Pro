//
//  promotionListVC.swift
//  pos
//
//  Created by khaled on 07/10/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import WebKit

class promotionViewVC: UIViewController
{
    
    var load_promotion_type:promotion_types?
    
    var promotion:pos_promotion_class?
    
    
    var webView: WKWebView!
    @IBOutlet weak var container: UIView!

    var   html:String = ""
    
    var indc: UIActivityIndicatorView?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame:self.view.bounds, configuration: webConfiguration)
        //        webView.uiDelegate = self
        webView.autoresizingMask =  [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        //        webView.frame = container.bounds
        container.addSubview(webView)
        
        loadReport( )
    }
    
    func printOrder_html() -> String {
        
        
         html = baseClass.get_file_html(filename: "promotion",showCopyRight: true)
 
        showActivityIndicator()
        
        html = html.replacingOccurrences(of: "#promotionName", with:promotion?.display_name ?? "")
        html = html.replacingOccurrences(of: "#promotion_details", with:promotion_details()  )

        conditions()
        
        hideActivityIndicator()
//              SharedManager.shared.printLog(html)
        return html
    }
    
     func loadReport( )
    {
 
 
        showActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
            self.html = self.printOrder_html()
//            SharedManager.shared.printLog( self.html )
            DispatchQueue.main.async {
                self.webView.loadHTMLString(self.html, baseURL:  Bundle.main.bundleURL)
            }
        }
    }
    
    
    func showActivityIndicator() {
        if indc == nil
        {
            indc = UIActivityIndicatorView(style: .whiteLarge)
            indc?.center = self.view.center
            indc?.color = UIColor.black
            self.view.addSubview(indc!)
        }
        DispatchQueue.main.async {
            self.indc?.startAnimating()
        }
    }
    
    func hideActivityIndicator(){
        if (indc != nil){
            DispatchQueue.main.async {
                self.indc?.stopAnimating()
            }
        }
    }
  
    
    
    func promotion_details() -> String
    {
 
        let rows:NSMutableString = NSMutableString()
        rows.append(" <tr><td width=\"300\">Promotion Type</td><td>: </td><td> \(promotion!.promotion_type ) </td></tr>")
        rows.append(" <tr><td>Apply On Pos</td><td>: </td><td> \(apply_on_pos() ) </td></tr>")
        rows.append(" <tr><td>Apply On Order Types</td><td>: </td><td> \(apply_on_order_types() ) </td></tr>")
        rows.append(" <tr><td>Day Of The Week</td><td>: </td><td> \(day_of_the_week() ) </td></tr>")
        rows.append(" <tr><td>From - To</td><td>: </td><td> \(promotion!.from_date) - \(promotion!.to_date) </td></tr>")
        rows.append(" <tr><td>From(hr) - To(hr)</td><td>: </td><td> \(promotion!.from_time) - \(promotion!.to_time) </td></tr>")

        if promotion!.promotion_type == promotion_types.Buy_X_Get_Discount_On_Y.rawValue
        {
            rows.append(" <tr><td>Products</td><td>: </td><td> \(parent_product_ids() ) </td></tr>")

        }
        else if   promotion!.promotion_type == promotion_types.Percent_Discount_on_Quantity.rawValue
                        || promotion!.promotion_type == promotion_types.Fix_Discount_on_Quantity.rawValue
        {
            rows.append(" <tr><td>Product</td><td>: </td><td> \(product_product_class.get(id: promotion!.product_id_amt)?.display_name ?? "") </td></tr>")
        }
        else   if promotion!.promotion_type == promotion_types.Discount_percentage_on_Total_Amount.rawValue
        {
            rows.append(" <tr><td>Total Invoice Amount</td><td>: </td><td> \( promotion!.total_amount ) </td></tr>")
            rows.append(" <tr><td>Operator</td><td>: </td><td> \( promotion!._operator ) </td></tr>")
            rows.append(" <tr><td>Total Discount(%)    </td><td>: </td><td> \( promotion!.total_discount ) </td></tr>")
            rows.append(" <tr><td>Discount Product </td><td>: </td><td> \(product_product_class.get(id: promotion!.discount_product_id)?.display_name ?? "") </td></tr>")

        }
        
        return String(rows)
    }
    
    func apply_on_pos() ->  String
    {
        let  ids = promotion?.get_apply_on_pos_ids() ?? []
        let lst = pos_config_class.get(ids: ids)
        
        var names = ""
        for i in lst
        {
            let name = i["name"] as? String ?? ""
            names = names + "," + name
        }
        
        if !names.isEmpty
        {
            names.removeFirst()
        }
        
        return names
    }
    
    func apply_on_order_types() ->  String
    {
        let  ids = promotion?.get_apply_on_order_types_ids()  ?? []
        let lst = delivery_type_class.get(ids: ids)
        
        var names = ""
        for i in lst
        {
            let name = i["display_name"] as? String ?? ""
            names = names + "," + name
        }
        
        if !names.isEmpty
        {
            names.removeFirst()
        }
        
        return names
        
    }
    
    func day_of_the_week() ->  String
    {
        let  ids = promotion?.get_day_of_week_ids() ?? []
        let lst = day_week_class.get(ids: ids)
        
        var names = ""
        for i in lst
        {
            let name = i["display_name"] as? String ?? ""
            names = names + "," + name
        }
        
        if !names.isEmpty
        {
            names.removeFirst()
        }
        
        return names
        
    }
    
    func parent_product_ids() ->  String
    {
        let  ids =  promotion!.get_parent_product_ids()

        let lst = product_product_class.get(ids: ids)
        
        var names = ""
        for i in lst
        {
            let name = i["display_name"] as? String ?? ""
            names = names + "," + name
        }
        
        if !names.isEmpty
        {
            names.removeFirst()
        }
        
        return names
        
    }
    
    func conditions()
    {
        if promotion?.promotion_type == promotion_types.Buy_X_Get_Y_Free.rawValue
        {
            condition_buy_x_get_y()
        }
        else if promotion?.promotion_type == promotion_types.Buy_X_Get_Discount_On_Y.rawValue
        {
            condition_buy_x_discount_y()
        }
        else if promotion?.promotion_type == promotion_types.Discount_percentage_on_Total_Amount.rawValue
        {
            html = html.replacingOccurrences(of: "#header_row", with: "" )
            html = html.replacingOccurrences(of: "#condtions", with: ""  )

        }
        else if promotion?.promotion_type == promotion_types.Percent_Discount_on_Quantity.rawValue
        {
            condition_percent_discount_on_quantity()
        }
        else if promotion?.promotion_type == promotion_types.Fix_Discount_on_Quantity.rawValue
        {
            condition_fix_discount_on_quantity()
        }
        
    }
    
    func condition_buy_x_get_y()
    {
        let header_row = "<th>Product(X)</th> <th>Operator</th> <th>QTY (X)</th> <th>Product(Y)</th> <th>QTY (Y)</th> <th>No of Applied times</th>"
        html = html.replacingOccurrences(of: "#header_row", with:header_row  )

        
        let rows:NSMutableString = NSMutableString()
       

        let conditions: [[String:Any]] = pos_conditions_class.getAll(promotion_id: promotion!.id)
        
         for cond in conditions
         {
            let item = pos_conditions_class(fromDictionary: cond)

            if item.product_x_id != 0 && item.product_y_id != 0
            {
                rows.append("""
                    <tr>
                    <td> \(product_product_class.get(id: item.product_x_id)!.display_name) </td>
                    <td> \(item._operator) </td>
                    <td> \(item.quantity)</td>
                    <td> \(product_product_class.get(id: item.product_y_id)!.display_name)</td>
                    <td> \(item.quantity_y) </td>
                    <td> \(item.no_of_applied_times) </td>
                    </tr>
                    """
            )
            }
         }
        
        html = html.replacingOccurrences(of: "#condtions", with:String(rows)  )

    }
    
    
    func condition_buy_x_discount_y()
    {
        let header_row = "<th>Product</th>   <th>QTY  </th> <th>Discount Y</th>   <th>No of Applied times</th>"
        html = html.replacingOccurrences(of: "#header_row", with:header_row  )

        
        let rows:NSMutableString = NSMutableString()
       

        let conditions: [[String:Any]] = get_discount_class.getAll(promotion_id: promotion!.id)
        
         for cond in conditions
         {
            let item = get_discount_class(fromDictionary: cond)

            if item.product_id_dis_id != 0
            {
                rows.append("""
                    <tr>
                    <td> \(item.product_id_dis_name) </td>
                    <td> \(item.qty) </td>
                    <td> \(item.discount_dis_x)</td>
                    <td> \(item.no_of_applied_times) </td>
                    </tr>
                    """
            )
            }
         }
        
        html = html.replacingOccurrences(of: "#condtions", with:String(rows)  )

    }
    
    func condition_percent_discount_on_quantity()
    {
        let header_row = "   <th>QTY  </th> <th>Discount Y</th>   <th>No of Applied times</th>"
        html = html.replacingOccurrences(of: "#header_row", with:header_row  )

        
        let rows:NSMutableString = NSMutableString()
       

        let conditions: [[String:Any]] = quantity_discount_class.getAll(promotion_id: promotion!.id)
        
         for cond in conditions
         {
            let item = quantity_discount_class(fromDictionary: cond)
 
                rows.append("""
                    <tr>
                     <td> \(item.quantity_dis) </td>
                    <td> \(item.discount_dis)</td>
                    <td> \(item.no_of_applied_times) </td>
                    </tr>
                    """
            )
           
         }
        
        html = html.replacingOccurrences(of: "#condtions", with:String(rows)  )

    }
    
    func condition_fix_discount_on_quantity()
    {
        let header_row = "   <th>QTY  </th> <th>Discount Y</th>   <th>No of Applied times</th>"
        html = html.replacingOccurrences(of: "#header_row", with:header_row  )

        
        let rows:NSMutableString = NSMutableString()
       

        let conditions: [[String:Any]] = quantity_discount_amt_class.getAll(promotion_id: promotion!.id)
        
         for cond in conditions
         {
            let item = quantity_discount_amt_class(fromDictionary: cond)
 
                rows.append("""
                    <tr>
                     <td> \(item.quantity_amt) </td>
                    <td> \(item.discount_price)</td>
                    <td> \(item.no_of_applied_times) </td>
                    </tr>
                    """
            )
           
         }
        
        html = html.replacingOccurrences(of: "#condtions", with:String(rows)  )

    }
}
