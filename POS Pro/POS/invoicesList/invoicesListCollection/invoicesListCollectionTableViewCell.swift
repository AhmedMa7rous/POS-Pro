//
//  customerTableViewCell.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

struct cell_item {
    var title: String!
    var value: String!

}

class invoicesListCollectionCell: UICollectionViewCell {
    
    @IBOutlet var lblTtile: KLabel!
    @IBOutlet var lblValue: KLabel!

    override func prepareForReuse() {
     super.prepareForReuse()
     // clear any subview here
        lblTtile.text = ""
        lblValue.text = ""
        lblValue.textColor = #colorLiteral(red: 0.3411764706, green: 0.3411764706, blue: 0.3411764706, alpha: 1)
    }
    
}

protocol invoicesListCollectionCell_delegate:class {
    func order_selected(order_selected:pos_order_class);
 
}

class invoicesListCollectionTableViewCell: UITableViewCell ,UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{

    weak var delegate:invoicesListCollectionCell_delegate?

    
    @IBOutlet var collectionView: UICollectionView!
   
    @IBOutlet weak var removeBtn: UIButton!
    let cellIdentifier = "cellIdentifier"
    
    var list :[cell_item] = []

    var  PindexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var object :pos_order_class!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        list = []
        collectionView.reloadData()
    }
    
    func addToList(_ item:cell_item)
    {
        if !item.value.isEmpty
        {
            list.append(item )
        }
    }
    func updateMenuCell() {
        let timeString = Date(strDate: object.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: baseClass.date_fromate_time, UTC: false)
        
        if let referenceNumber = object.delivery_type_reference, !referenceNumber.isEmpty {
            addToList(cell_item(title: "Reference Number".arabic("الرقم المرجعي"), value:referenceNumber))
        }
        var name_delivery = ((object?.pos_order_integration?.online_order_source) ?? "JAHEZ")
        if (object?.order_integration ?? .NONE) == .DELIVERY  {
            if let platFormName = object?.platform_name , !platFormName.isEmpty{
                name_delivery = platFormName
            }else{
                name_delivery = ((object?.pos_order_integration?.online_order_source) ?? "JAHEZ")
            }
        }else{
            name_delivery =   "Menu"
        }
        let channelName =  name_delivery
        
        addToList(cell_item(title: "Order".arabic("الطلب"), value: "#" + String( object.sequence_number )))
        addToList(cell_item(title: "Table".arabic("الطاوله"), value:  object.table_name ?? ""))
        addToList(cell_item(title: "Time".arabic("الوقت"), value: timeString))
        if SharedManager.shared.appSetting().enable_move_pending_orders {
            let dateString = Date(strDate: object.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: baseClass.date_fromate_satnder_date, UTC: false)

            addToList(cell_item(title: "Date".arabic("التاريخ"), value: dateString))

        }
        addToList(cell_item(title: "Channel".arabic("القناه"), value:  channelName))
        if let numberGuests = object?.guests_number, numberGuests > 0  {
            addToList(cell_item(title: "Guests".arabic("الضيوف"), value:  "\(numberGuests)"))
        }
        
//        addToList(cell_item(title: "Customer".arabic("العميل"), value:  object.customer?.name ?? ""))

        
        addToList(cell_item(title: "TOTAL".arabic("المجموع"), value:baseClass.currencyFormate(object.amount_total  )))
 
        
        
        
        if object.sub_orders_count != 0
        {
            self.contentView.layer.borderWidth = 1
            self.contentView.layer.borderColor = UIColor(hexString: "#FC7700").cgColor
        }
        else
        {
            self.contentView.layer.borderWidth = 0

        }
        
        
        
 
    }

    func updateCell(_ showDriver:Bool) {
         
        var pos:String = ""
        if object.sequence_number > 0{
            addToList(cell_item(title: "Order".arabic("الطلب"), value: String( object.sequence_number )))
        }
        let nameTable =  (object.table_name ?? "")
        list.append(cell_item(title: "Table".arabic("الطاوله"), value:  nameTable.isEmpty ? "--" : nameTable)   )
        addToList(cell_item(title: "TOTAL".arabic("المجموع"), value:baseClass.currencyFormate(object.amount_total  )))

        if let creat_pos_code = object.create_pos_code , !creat_pos_code.isEmpty {
            pos = creat_pos_code
        }else{
            if object.order_integration == .DELIVERY {
                if let platFormName = object.platform_name , !platFormName.isEmpty{
                    pos = platFormName
                }else{
                    pos = (object.pos_order_integration?.online_order_source ?? "JAHEZ")
                }
            }else{
                pos =   "Menu"
            }
        }
        
        let timeString = Date(strDate: object.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: baseClass.date_fromate_time, UTC: false)
        if let brandName = object.brand?.display_name {
            addToList(cell_item(title: "Brand".arabic("البراند"), value:brandName))
        }
        if let referenceNumber = object.delivery_type_reference, !referenceNumber.isEmpty {
            addToList(cell_item(title: "Reference Number".arabic("الرقم المرجعي"), value:referenceNumber))
        }
        addToList(cell_item(title: "POS".arabic("نقاط البيع"), value:pos))
       // addToList(cell_item(title: "Order".arabic("الطلب"), value: String( object.sequence_number )))
        addToList(cell_item(title: "Order type".arabic("نوع الطلب"), value:  object.orderType?.display_name ?? ""))
        addToList(cell_item(title: "Time".arabic("الوقت"), value: timeString))
        if SharedManager.shared.appSetting().enable_move_pending_orders {
            let dateString = Date(strDate: object.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: baseClass.date_fromate_satnder_date, UTC: false)

            addToList(cell_item(title: "Date".arabic("التاريخ"), value: dateString))

        }
        addToList(cell_item(title: "Driver".arabic("السائق"), value: object.driver?.name ?? ""))
        addToList(cell_item(title: "Customer".arabic("العميل"), value:  object.customer?.name ?? ""))
        if let numberGuests = object?.guests_number, numberGuests > 0  {
            addToList(cell_item(title: "Guests".arabic("الضيوف"), value:  "\(numberGuests)"))
        }
        addToList(cell_item(title: "POS".arabic("نقاط البيع"), value:pos))

 
        
        
        
        if object.sub_orders_count != 0
        {
            self.contentView.layer.borderWidth = 1
            self.contentView.layer.borderColor = UIColor(hexString: "#FC7700").cgColor
        }
        else
        {
            self.contentView.layer.borderWidth = 0

        }
        
        
        
 
    }
 

 
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            adjustPathCollectionWidth()
            return self.list.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! invoicesListCollectionCell
            
            //in this example I added a label named "title" into the MyCollectionCell class
            
            let cls =  self.list[indexPath.item]
            
         
            cell.lblTtile.text = cls.title
            cell.lblValue.text = cls.value

            
            cell.lblTtile.textColor = UIColor.init(hexString: "#FC7700")
            cell.lblTtile.font =  UIFont.init(name: app_font_name + "-Medium", size: 15)
            
 
            if (!(object.pos_multi_session_write_date ?? "").isEmpty && object.is_closed == false ) || object.create_pos_id != SharedManager.shared.posConfig().id
            {
                
                let txt_color = UIColor(hexString: "#3A8B27")
                cell.lblValue.textColor = txt_color

            }
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
        {
           
            object.reFetchPosLines()
            object.calcAll()
            delegate?.order_selected(order_selected: object)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let cls =  self.list[indexPath.item]
            
            var content_len = cls.value
            if cls.title.count > cls.value.count
            {
                content_len = cls.title
            }
            
            return CGSize(width: getWidthLblFor( content_len!), height: 50)
        }
        func getWidthLblFor(_ name:String) -> CGFloat{
            let label = KLabel(frame: CGRect.zero)
            label.font = UIFont.systemFont(ofSize: 20)
            label.text = name
            label.sizeToFit()
            let widthLbl = label.frame.width + 30
            return widthLbl
        }
 
    }





 

