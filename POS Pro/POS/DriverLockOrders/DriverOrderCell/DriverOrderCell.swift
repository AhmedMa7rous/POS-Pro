//
//  DriverOrderCell.swift
//  pos
//
//  Created by M-Wageh on 16/01/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit



class DriverOrderCell: UITableViewCell ,UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet weak var removeBtn: UIButton!
    let cellIdentifier = "DriverOrderCollectionCell"
    
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
    var memberShipItem :MemberShipSearchModel? {
        didSet {
            self.updateMemberShipCell()
        }
    }
    var return_order_from_search :pos_order_class? {
        didSet {
            self.updateReturnOrderCell()
        }
    }

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
    func updateReturnOrderCell(){
        guard let object = return_order_from_search else {
            return
        }
        var pos:String = ""
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
        
        addToList(cell_item(title: "POS".arabic("نقاط البيع"), value:pos))
        addToList(cell_item(title: "Order".arabic("الطلب"), value: String( object.sequence_number )))
        addToList(cell_item(title: "Order type".arabic("نوع الطلب"), value:  object.orderType?.display_name ?? ""))
        addToList(cell_item(title: "Time".arabic("الوقت"), value: timeString))
        if SharedManager.shared.appSetting().enable_move_pending_orders {
            let dateString = Date(strDate: object.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: baseClass.date_fromate_satnder_date, UTC: false)

            addToList(cell_item(title: "Date".arabic("التاريخ"), value: dateString))

        }
        if let driverName = object.driver?.name, !driverName.isEmpty{
            addToList(cell_item(title: "Driver".arabic("السائق"), value: driverName))
        }
        if let tableName = object.table_name, !tableName.isEmpty{
            addToList(cell_item(title: "Table".arabic("الطاوله"), value: tableName))
        }
        if let customerName = object.customer?.name , !customerName.isEmpty{
            addToList(cell_item(title: "Customer".arabic("العميل"), value:  customerName))
        }
        
        
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
        setupCollection()
        collectionView.reloadData()
    }
    func updateMemberShipCell() {
        guard let memberShipItem = memberShipItem else {
            return
        }
        let timeString = memberShipItem.date_order ?? ""
       
        
        addToList(cell_item(title: "Order".arabic("الطلب"), value: String( memberShipItem.name ?? "--" )))
        addToList(cell_item(title: "Time".arabic("الوقت"), value: timeString))
        if SharedManager.shared.appSetting().enable_move_pending_orders {
            let dateString = Date(strDate: object.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: baseClass.date_fromate_satnder_date, UTC: false)

            addToList(cell_item(title: "Date".arabic("التاريخ"), value: dateString))

        }
        if let partner = memberShipItem.partnerObject{
             let name =  partner.name
            if !name.isEmpty {
                addToList(cell_item(title: "Customer".arabic("العميل"), value: name))

            }
             let phone = partner.phone
            if !phone.isEmpty {
                addToList(cell_item(title: "Phone".arabic("الجوال"), value: phone))

            }
             let email =  partner.email
            if !email.isEmpty {
                addToList(cell_item(title: "E-mail".arabic("البريد"), value: email))
            }

        }else{
            addToList(cell_item(title: "Customer".arabic("العميل"), value: memberShipItem.partner_id.last ?? " - "))

        }
        addToList(cell_item(title: "Meal".arabic("الوجبه"), value: memberShipItem.meal_type_id.last ?? "--"))

        addToList(cell_item(title: "Period".arabic("المده"), value: memberShipItem.period_id.last ?? "--"))
                

        self.contentView.layer.borderWidth = 0
            
        setupCollection()
        collectionView.reloadData()
        
        
    }
    
    func updateCell(_ showDriver:Bool) {
        
        var pos:String = ""
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
//            pos = object.order_integration == .DELIVERY ? (object.pos_order_integration?.online_order_source ?? "JAHEZ") :  "Menu"
            
        }
        
        let timeString = Date(strDate: object.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: baseClass.date_fromate_time, UTC: false)
        if let brandName = object.brand?.display_name {
            addToList(cell_item(title: "Brand".arabic("البراند"), value:brandName))
        }
        
        addToList(cell_item(title: "POS".arabic("نقاط البيع"), value:pos))
        addToList(cell_item(title: "Order".arabic("الطلب"), value: String( object.sequence_number )))
        addToList(cell_item(title: "Order type".arabic("نوع الطلب"), value:  object.orderType?.display_name ?? ""))
        addToList(cell_item(title: "Time".arabic("الوقت"), value: timeString))
        if SharedManager.shared.appSetting().enable_move_pending_orders {
            let dateString = Date(strDate: object.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: baseClass.date_fromate_satnder_date, UTC: false)

            addToList(cell_item(title: "Date".arabic("التاريخ"), value: dateString))

        }
        
        addToList(cell_item(title: "Driver".arabic("السائق"), value: object.driver?.name ?? ""))
        addToList(cell_item(title: "Table".arabic("الطاوله"), value:  object.table_name ?? ""))
        addToList(cell_item(title: "Customer".arabic("العميل"), value:  object.customer?.name ?? ""))
        
        
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
        setupCollection()
        collectionView.reloadData()
        
        
    }
    
    func setupCollection(){
        let nib = UINib(nibName: "DriverOrderCollectionCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
//        self.collectionView.register(DriverOrderCollectionCell.self, forCellWithReuseIdentifier:cellIdentifier)

        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //            adjustPathCollectionWidth()
        return self.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! DriverOrderCollectionCell
        
        //in this example I added a label named "title" into the MyCollectionCell class
        
        let cls =  self.list[indexPath.item]
        
        
        cell.lblTtile.text = cls.title
        cell.lblValue.text = cls.value
        
        
       // cell.lblTtile.textColor = UIColor.init(hexString: "#FC7700")
        cell.lblTtile.font =  UIFont.init(name: app_font_name + "-Medium", size: 15)
        
        
       
        
        return cell
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
