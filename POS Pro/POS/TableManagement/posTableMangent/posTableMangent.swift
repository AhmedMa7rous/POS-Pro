//
//  posTableMangent.swift
//  pos
//
//  Created by Khaled on 11/19/20.
//  Copyright © 2020 khaled. All rights reserved.
//

  
import UIKit

class posTableMangent: baseViewController {
    
    var didSelect : ((restaurant_table_class) -> Void)?
    var didSelectOrder : ((pos_order_class) -> Void)?

    
    // MARK: - Properties
    @IBOutlet weak var lblOtherOrderNo: UILabel!
    @IBOutlet weak var lblAvalibleNo: UILabel!
    @IBOutlet weak var lblOngooingNo: UILabel!

    @IBOutlet weak var scFloors: UISegmentedControl!
    @IBOutlet weak var floorView: UIView!
    @IBOutlet weak var scView: UIView!
    private var floors = [restaurant_floor_class?]()
    private var tables = [restaurant_table_class?]()
    var selectedTable: restaurant_table_class?
    var timer_refresh: Timer?

    @IBOutlet weak var btnEditPostion: KButton!
    @IBOutlet weak var btnAutoArrange: KButton!
var rule: rule_tables_key?
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        stop_zoom = true
        blurView(alpha: 1, style: .light)

        super.viewDidLoad()
        
        
        scFloors.backgroundColor = UIColor.white
        scFloors.removeBorders(tintColor: UIColor(hexFromString: "#A2A2A2"))
        scFloors.frame.size.height = 47

        let font_medium = UIFont.init(name: "HelveticaNeue-Medium", size: 17)
        let font_regular = UIFont.init(name: "HelveticaNeue", size: 17)
        scFloors.setTitleTextAttributes([.foregroundColor: UIColor.init(hexString: "#333333"), NSAttributedString.Key.font: font_regular!], for: .normal)
        scFloors.setTitleTextAttributes([.foregroundColor: UIColor.init(hexString: "#FFFFFF"), NSAttributedString.Key.font: font_medium!], for: .selected)
        
 
         
        setupFloors()
        setupSegmentedControl()
        setupTables()
        init_notificationCenter()
//        timer_refresh = Timer.scheduledTimer(timeInterval:2, target: self, selector: #selector(timerRefresh), userInfo: nil, repeats: true)
//        timer_refresh?.fire()
        
        btnAutoArrange.isHidden = true
        
     }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scFloors.selectedSegmentIndex = 0
        scFloors.sendActions(for: .valueChanged)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        remove_notificationCenter()
        timer_refresh?.invalidate()
        timer_refresh = nil

    }
    func init_notificationCenter()
    {
        
        
        NotificationCenter.default.addObserver(self, selector: #selector( poll_update_order(notification:)), name: Notification.Name("poll_update_order"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( poll_update_order(notification:)), name: Notification.Name("poll_remove_order"), object: nil)
        
    }
    
    func remove_notificationCenter() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_update_order"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_remove_order"), object: nil)
        
    }
    @objc func poll_update_order(notification: Notification) {
        DispatchQueue.main.async {
            self.setupTables()
            self.updateTablesViews()
        }
        
    }
    

    @objc func timerRefresh(){
//        scFloors.sendActions(for: .valueChanged)
        setupTables()
        updateTablesViews()

    }
    // MARK: - Actions
    
    @IBAction func onCloseTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func clearView()
    {
        for view in floorView.subviews
        {
            
            view.removeFromSuperview()
        }
    }
    func updateCountForFloor(resturantTableView:ResturantTableView,table:restaurant_table_class){
        table.getCountOrder() { countTables in
            resturantTableView.countOrder = countTables
        }
    }
    func updateTablesViews(){
        clearView()
        if  self.floors.count <= 0{
            return
        }
        let floor = self.floors[scFloors.selectedSegmentIndex]
        guard  let floorID = floor?.id else {
            return
        }
        var floorTables = self.tables.filter({($0?.floor_id) == floorID})
        var avalibleNo = floorTables.count
        let userID = SharedManager.shared.activeUser().id

        var myOrderNo = 0
        var otherOrderNo = 0

        if  self.floors.count > 0{
            for table in floorTables {
                if let table = table {
                    if table.floor_id == floorID {
                        table.floor_name = floor?.name
                        //                tables.append(table)
                        
                        //                let tbl = tableView(nibName: "tableView", bundle: nil)
                        //                tbl.tabel = table
                        //                tbl.updateView()
                        let resturantTableView = ResturantTableView.getViewInstance(table: table)
                        self.updateCountForFloor(resturantTableView:resturantTableView,table:table)
                        resturantTableView.updateTitle()
                        let gesture = tableTapGesture(target: self, action:  #selector(self.checkAction))
                        gesture.table = table
                        gesture.countOrder = resturantTableView.countOrder
                        resturantTableView.addGestureRecognizer(gesture)
                        let gestureMove = tablePanGesture(target: self, action: #selector(self.wasDragged))
                        gestureMove.viewCurrent = resturantTableView
                        gestureMove.table = table
                        resturantTableView.addGestureRecognizer(gestureMove)
                        
                        floorView.addSubview(resturantTableView)
                        
                        if table.order_id != 0 && table.order_amount > 0
                        {
                            avalibleNo -= 1
                            if (table.create_user_id ?? 0) == userID{
                                myOrderNo += 1

                            }else{
                                otherOrderNo += 1

                            }
                        }
                        
                    }
                }
            }
        }
        lblAvalibleNo.text = "\(avalibleNo)"
        lblOtherOrderNo.text = "\(otherOrderNo)"
        lblOngooingNo.text = "\(myOrderNo)"
        
    }
    
    @objc func wasDragged(gesture: tablePanGesture) {
       
        if (btnEditPostion.isSelected)
        {
            gesture.viewCurrent.center = gesture.location(in: floorView)
            gesture.table!.position_h =  gesture.viewCurrent.frame.origin.x
            gesture.table!.position_v =  gesture.viewCurrent.frame.origin.y
//            gesture.table!.update_postion = true
//            gesture.table!.save()
        }

      

    }
    
    @objc func onSegmentedValueChanged(sender: UISegmentedControl, event: UIEvent) {
//        var tables = [restaurant_table_class]()
        updateTablesViews()
       /* clearView()
        
        for table in self.tables {
            if table.floor_id == self.floors[sender.selectedSegmentIndex].id {
                table.floor_name = self.floors[sender.selectedSegmentIndex].name
//                tables.append(table)
                
                let tbl = tableView(nibName: "tableView", bundle: nil)
                tbl.tabel = table
                tbl.updateView()
                
                let gesture = tableTapGesture(target: self, action:  #selector(self.checkAction))
                gesture.table = table
                tbl.view.addGestureRecognizer(gesture)
 
                floorView.addSubview(tbl.view)
            }
        }
        
        */
        
//        floorView.tables = tables
    }
    
    @objc func checkAction(sender : tableTapGesture) {
        // Do what you want
        
//        if sender.table?.order_id != 0
//        {
//            MessageView.show("This table is reservation .".arabic("هذه الطاوله محجوزه"))
//            return
//        }
        if sender.table?.order_id != 0 && rule == .browse_table_type && (sender.table?.order_amount ?? 0) != 0{
            guard let orderList = sender.table?.getOrderList() else { return }
            
            let vc = TableBillViewController(nibName: "TableBillViewController", bundle: nil)
          //  DispatchQueue.main.async {
                vc.orderSelected = orderList.first
                vc.modalPresentationStyle = .formSheet
                vc.preferredContentSize = CGSize(width: 800, height: 600)
                self.present(vc, animated: true)
           // }
            vc.editSelectedOrder = { [weak self] edit in
                if edit {
                    self?.editCurrentOrder(sender: sender)
                }
            }
        } else {
            if let table = sender.table , table.order_id != 0 {
                if rule == .change_table_type || rule == .new_order_table_type {
                    messages.showAlert( "You can not change or select this table because it is busy right now !".arabic("لايمكنك التبديل او اخيار هذه الطاولة لانها مشغوله الان"), title:"")
                    return
                }
            }
            didSelect?(sender.table!)
            dismiss(animated: true, completion: nil)
                
        }
    }
    
    func editCurrentOrder(sender: tableTapGesture) {
        if (sender.countOrder ?? 0) > 1 {
            let orderList = sender.table?.getOrderList() ?? []
            if orderList.count > 1 {
                let vc = SelectOrdersVC.createModule(sender.view, selectDataList: [],dataList:orderList )
                present(vc, animated: true, completion: nil)
                vc.completionBlock = { [weak self] selectDataList in
                    self?.dismiss(animated: true, completion: {
                        if let order =  selectDataList.first {
                            self?.didSelectOrder?(order)
                            self?.dismiss(animated: true)
                        }
                    })
                }
                return
            }
        }
        didSelect?(sender.table!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnEnableEditPostion(_ sender: Any) {
        
//        guard  rules.check_access_rule(rule_key.table_management_edit) else {
// 
//            return
//        }
        
        self.completeEnableEdit()

//        rules.check_access_rule(rule_key.table_management_edit,for: self) {
//            DispatchQueue.main.async {
//                self.completeEnableEdit()
//            }
//        }
                 
    }
    func completeEnableEdit(){
        btnEditPostion.isSelected = !btnEditPostion.isSelected
        btnAutoArrange.isHidden = !btnEditPostion.isSelected
        
        if !btnEditPostion.isSelected
        {
            savePostion()
        }
    }
    
    func savePostion() {
        for aView in floorView.subviews
        {
            if let tableView = aView as? ResturantTableView{
                 
                tableView.tabel!.position_h =  tableView.frame.origin.x
                tableView.tabel!.position_v =  tableView.frame.origin.y
                tableView.tabel!.update_postion = true
 
                tableView.tabel!.save()
             }
        }
        DispatchQueue.global(qos: .background).async {
            AppDelegate.shared.sync.send_updated_table_postion()
        }
    }
    
    @IBAction func btnAutoArrange(_ sender: Any) {
        
        var x = 0.0 ;
        var y = 0.0;
        
        let paddingX = 20.0;
        let paddingY = 20.0;

        var lastWidth = 0.0
        var maxHeight = 0.0
        
        for aView in floorView.subviews
        {
            if let tableView = aView as? ResturantTableView{
                
                x = x + lastWidth + paddingX  ;

                lastWidth = tableView.frame.size.width
                if tableView.frame.size.height > maxHeight
                {
                    maxHeight = tableView.frame.size.height
                }
                 
                if (x + lastWidth) > 1024
                {
                    x = paddingX
                    y = y + maxHeight + paddingY
                    maxHeight = 0
                }
                
                UIView.animate(withDuration: 0.3) {
                    tableView.frame.origin.x = x ;
                    tableView.frame.origin.y = y ;
                    
                }
       

//                tableView.tabel!.position_h =   x
//                tableView.tabel!.position_v =  y
//                gesture.table!.update_postion = true
//                tableView.tabel!.save()
             }
        }
        
    }
    
    // MARK: - Minions
    
    func setupFloors() {
        let results =  restaurant_floor_class.getAll() //api.get_last_cash_result(keyCash: api.RESTAURANT_FLOOR)
        
        for result in results {
//            if let dictionary = result as? [String:Any] {
//                guard let name = dictionary["name"] as? String,
//                    let id = dictionary["id"] as? Int else {
//                       SharedManager.shared.printLog("Something is not well")
//                        continue
//                }
//
//                let floor = FloorResult(id: id, tableIDS: [], posConfigID: [], name: name)
                
            let floor = restaurant_floor_class(fromDictionary: result)
            
                floors.append(floor)
            }
      
    }
    
    func setupSegmentedControl() {
        
        scFloors.removeAllSegments()

        
        guard !floors.isEmpty else { return }
        
        floors.forEach { floor in
            if let floor = floor {
                scFloors.insertSegment(withTitle: "Floor " + floor.name, at: scFloors.numberOfSegments, animated: true)
            }
            
        }
        
        scFloors.addTarget(self, action: #selector(onSegmentedValueChanged(sender:event:)), for: .valueChanged)
        scFloors.selectedSegmentIndex = 0
        
//        self.view.addSubview(scFloors)
        
        // Add constraints
//        scFloors.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            scFloors.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20.0),
//            scFloors.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
//        ])
        
        scView.layer.cornerRadius = 8
    }
    
    func setupTables() {
        let results = restaurant_table_class.getWithOrders() // api.get_last_cash_result(keyCash: api.RESTAURANT_TABLE)
       let resultsObjects = results.map {  restaurant_table_class(fromDictionary: $0)}
        tables.removeAll()
        tables.append(contentsOf: resultsObjects )
         
    }
}

 

 
class tableTapGesture: UITapGestureRecognizer {
     var table:restaurant_table_class?
    var countOrder:Int?
 
}

class tablePanGesture: UIPanGestureRecognizer {
     var table:restaurant_table_class?
    var viewCurrent:UIView!
 
}
