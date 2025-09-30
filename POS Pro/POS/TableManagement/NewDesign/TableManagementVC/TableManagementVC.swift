//
//  TableManagementVC.swift
//  pos
//
//  Created by Muhammed Elsayed on 04/02/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class TableManagementVC: baseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var lblAvalibleNo: UILabel!
    @IBOutlet weak var lblOngooingNo: UILabel!
    @IBOutlet weak var scFloors: UISegmentedControl!
    @IBOutlet weak var floorCollectionView: UICollectionView!
    @IBOutlet weak var scView: UIView!
    @IBOutlet weak var btnEditPostion: KButton!
    @IBOutlet weak var btnAutoArrange: KButton!
    // MARK: - Properties
    private var floors = [restaurant_floor_class?]()
    private var tables = [restaurant_table_class?]()
    var selectedTable: restaurant_table_class?
    var timer_refresh: Timer?
    private var filteredAndSortedTables: [restaurant_table_class] = []
    // MARK: - Closures
    var didSelect : ((restaurant_table_class) -> Void)?
    var didSelectOrder : ((pos_order_class) -> Void)?
    var dataResUserList:[res_users_class]?
    var changeTable:Bool?
    var isSplitOrMove:Bool?
    // MARK: - UIViewController
    var rule: rule_tables_key?

    override func viewDidLoad() {
        stop_zoom = true
        blurView(alpha: 1, style: .light)

        super.viewDidLoad()
        DispatchQueue.global(qos: .background).async {
            self.dataResUserList = res_users_class.getAll().map({res_users_class(fromDictionary: $0)})
        }
        
        scFloors.backgroundColor = UIColor.white
        scFloors.removeBorders(tintColor: UIColor(hexFromString: "#A2A2A2"))
        scFloors.frame.size.height = 47

        let font_medium = UIFont.init(name: "HelveticaNeue-Medium", size: 17)
        let font_regular = UIFont.init(name: "HelveticaNeue", size: 17)
        scFloors.setTitleTextAttributes([.foregroundColor: UIColor.init(hexString: "#333333"), NSAttributedString.Key.font: font_regular!], for: .normal)
        scFloors.setTitleTextAttributes([.foregroundColor: UIColor.init(hexString: "#FFFFFF"), NSAttributedString.Key.font: font_medium!], for: .selected)
        
 
        setupCollectionView()
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
    func setupCollectionView() {
        floorCollectionView.register(UINib(nibName: "RestaurantTableViewCell", bundle: nil), forCellWithReuseIdentifier: "RestaurantTableViewCell")
        floorCollectionView.delegate = self
        floorCollectionView.dataSource = self
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
//        for view in floorView.subviews
//        {
//            
//            view.removeFromSuperview()
//        }
    }
    func updateTablesViews() {
        filteredAndSortedTables = tables.compactMap { $0 }
                                             .filter { $0.floor_id == floors[scFloors.selectedSegmentIndex]?.id }
                                             .sorted(by: { ($0.id ?? 0) < ($1.id ?? 0) })
        floorCollectionView.reloadData()

        let availableTables = filteredAndSortedTables.filter { $0.order_id == 0 }
        let ongoingTables = filteredAndSortedTables.filter { $0.order_id != 0 }

        lblAvalibleNo.text = "\(availableTables.count)"
        lblOngooingNo.text = "\(ongoingTables.count)"
    }
//    func updateTablesViews(){
//        clearView()
//        
//        var avalibleNo = self.tables.count
//        var ongoogingNo = 0
//        
//        for table in self.tables {
//            if let table = table {
//            if table.floor_id == self.floors[scFloors.selectedSegmentIndex]?.id {
//                table.floor_name = self.floors[scFloors.selectedSegmentIndex]?.name
////                tables.append(table)
//                
////                let tbl = tableView(nibName: "tableView", bundle: nil)
////                tbl.tabel = table
////                tbl.updateView()
//                let resturantTableView = ResturantTableView.getViewInstance(table: table)
//                resturantTableView.countOrder = table.getCountOrder()
//                resturantTableView.updateTitle()
//                let gesture = tableTapGesture(target: self, action:  #selector(self.checkAction))
//                gesture.table = table
//                resturantTableView.addGestureRecognizer(gesture)
//                let gestureMove = tablePanGesture(target: self, action: #selector(self.wasDragged))
//                gestureMove.viewCurrent = resturantTableView
//                gestureMove.table = table
//                resturantTableView.addGestureRecognizer(gestureMove)
//
//                floorView.addSubview(resturantTableView)
//                
//                if table.order_id != 0
//                {
//                    avalibleNo -= 1
//                    ongoogingNo += 1
//                }
//                
//            }
//            }
//        }
//        
//        lblAvalibleNo.text = "\(avalibleNo)"
//        lblOngooingNo.text = "\(ongoogingNo)"
//        
//    }
//    
    @objc func wasDragged(gesture: tablePanGesture) {
       
        if (btnEditPostion.isSelected)
        {
//            gesture.viewCurrent.center = gesture.location(in: floorView)
            gesture.table!.position_h =  gesture.viewCurrent.frame.origin.x
            gesture.table!.position_v =  gesture.viewCurrent.frame.origin.y
//            gesture.table!.update_postion = true
//            gesture.table!.save()
        }

      

    }
    
    @objc func onSegmentedValueChanged(sender: UISegmentedControl, event: UIEvent) {
//        var tables = [restaurant_table_class]()
        updateTablesViews()
    }
    
    @objc func checkAction(sender : tableTapGesture) {
        // Do what you want
        
//        if sender.table?.order_id != 0
//        {
//            MessageView.show("This table is reservation .".arabic("هذه الطاوله محجوزه"))
//            return
//        }
        

        if (sender.countOrder ?? 0) > 1 {
            let orderList = sender.table?.getOrderList() ?? []
            if orderList.count > 1 {
                let vc = SelectOrdersVC.createModule(sender.view, selectDataList: [],dataList:orderList )
                self.present(vc, animated: true, completion: nil)
                vc.completionBlock = { selectDataList in
                    self.dismiss(animated: true, completion: {
                        if let order =  selectDataList.first {
                            self.didSelectOrder?(order)
                        }
                    })

                }
                return
            }
            
        }

            self.didSelect!(sender.table!)
            dismiss(animated: true, completion: nil)
        
       

        
    }
    
    @IBAction func btnEnableEditPostion(_ sender: Any) {
        
        guard  rules.check_access_rule_table() else {
 
            return
        }
        
        
        btnEditPostion.isSelected = !btnEditPostion.isSelected
        btnAutoArrange.isHidden = !btnEditPostion.isSelected
        
        if !btnEditPostion.isSelected
        {
            savePostion()
        }
         
    }
    
    func savePostion() {
//        for aView in floorView.subviews
//        {
//            if let tableView = aView as? ResturantTableView{
//                 
//                tableView.tabel!.position_h =  tableView.frame.origin.x
//                tableView.tabel!.position_v =  tableView.frame.origin.y
//                tableView.tabel!.update_postion = true
// 
//                tableView.tabel!.save()
//             }
//        }
//        DispatchQueue.global(qos: .background).async {
//            AppDelegate.shared.sync.send_updated_table_postion()
//        }
    }
    
    @IBAction func btnAutoArrange(_ sender: Any) {
        
        var x = 0.0 ;
        var y = 0.0;
        
        let paddingX = 20.0;
        let paddingY = 20.0;

        var lastWidth = 0.0
        var maxHeight = 0.0
        
//        for aView in floorView.subviews
//        {
//            if let tableView = aView as? ResturantTableView{
//                
//                x = x + lastWidth + paddingX  ;
//
//                lastWidth = tableView.frame.size.width
//                if tableView.frame.size.height > maxHeight
//                {
//                    maxHeight = tableView.frame.size.height
//                }
//                 
//                if (x + lastWidth) > 1024
//                {
//                    x = paddingX
//                    y = y + maxHeight + paddingY
//                    maxHeight = 0
//                }
//                
//                UIView.animate(withDuration: 0.3) {
//                    tableView.frame.origin.x = x ;
//                    tableView.frame.origin.y = y ;
//                    
//                }
//       
//
////                tableView.tabel!.position_h =   x
////                tableView.tabel!.position_v =  y
////                gesture.table!.update_postion = true
////                tableView.tabel!.save()
//             }
//        }
//        
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
        tables = resultsObjects.sorted(by: { $0.id < $1.id })

//        tables.removeAll()
//        tables.append(contentsOf: resultsObjects )
         
    }
}
extension TableManagementVC: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredAndSortedTables.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantTableViewCell", for: indexPath) as? RestaurantTableViewCell else {
            return UICollectionViewCell()
        }
        
        let table = filteredAndSortedTables[indexPath.row]
//        if table.order_id != 0 {
//            cell.order = table.getTableOrder()
//        }
        cell.tabel = table
        if table.order_id != 0 {
            cell.countOrder = table.countOrders ?? 0
        }
//        SharedManager.shared.printLog("Table at indexPath \(indexPath.row) has ID: \(table.id)")

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let table = filteredAndSortedTables[indexPath.row]
        dismisWithSelectTable(table,cell: collectionView.cellForItem(at: indexPath) ?? collectionView)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 150)
    }
    func dismisWithSelectTable(_ table:restaurant_table_class,cell:UIView){
        if SharedManager.shared.mwIPnetwork{
            if SharedManager.shared.appSetting().enable_make_user_resposiblity_for_order{
            let cellView =  cell as? RestaurantTableViewCell
        if self.isSplitOrMove ?? false {
            dismissComplete(table:table)
            return
        }
            if SharedManager.shared.posConfig().isMasterTCP(){
                showActions(for:table,at: cell)
            }else{
                if let ownerID = table.create_user_id {
                    let currentUserID = SharedManager.shared.activeUser().id
                    if ownerID == currentUserID {
                        dismissComplete(table:table)
                    }else{
                        messages.showAlert( "Order can select only by master or create user".arabic("يمكن تحديد الطلب فقط بواسطة المستخدم الرئيسي أو المستخدم المُنشئ"),vc: self)
                        
                    }
                }else{
                    dismissComplete(table:table)
                }
                    
                }
            }else{
                dismissComplete(table:table)

            }

        }else{
            dismissComplete(table:table)
        }
        
    }
    func dismissComplete(table:restaurant_table_class){
        dismiss(animated: true, completion: {
            self.didSelect?(table)
        })
    }
    func showActions(for table:restaurant_table_class,at cell:UIView){
        if table.order_id == 0  {
            dismissComplete(table:table)
           return
        }
        if (self.changeTable ?? false) {
            if table.order_id == 0 {
                dismissComplete(table:table)
            return
            }
        }
        
        let actionSheet = UIAlertController(title: nil, message: "Choose an action", preferredStyle: .actionSheet)
        let titleOpen = "Open order".arabic("عرض الطلب")
        // Add actions
        //(self.changeTable ?? false) ? "Change table".arabic("تغير الطاوله") :
        actionSheet.addAction(UIAlertAction(title: titleOpen, style: .default, handler: { _ in
            self.dismissComplete(table:table)
        }))
        //                           actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
        //                               print("Delete tapped")
        //                           }))
        actionSheet.addAction(UIAlertAction(title: "Print bill".arabic("طباعه الفاتوره"), style: .default, handler: { _ in
            guard let order = table.getTableOrder() else { return }
            order.creatBillQueuePrinter(rowType.bill,openDrawer: false)
            MWRunQueuePrinter.shared.startMWQueue()
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Change user".arabic("تغيير مسؤول الطاولة"), style: .default, handler: { _ in
            let cellView =  cell as? RestaurantTableViewCell
            guard let userID =   table.create_user_id else { return }
            guard let userSelected = res_users_class.get(id: userID) else { return }
            let selectUservc:SelectResUserVC = SelectResUserVC.createModule(cell,selectDataList:  [userSelected],dataList:self.dataResUserList ?? [])
                selectUservc.completionBlock = { selectDataList in
                    if  selectDataList.count > 0{
                        if (selectDataList.first?.id ?? 0) != -1{
                            if let userSelected = selectDataList.first,let userNameSelected = userSelected.name{
                                let userIDSelected = userSelected.id
                                table.create_user_id = userIDSelected
                                table.create_user_name = userNameSelected
                                table.setUserResponse(with :userIDSelected, name:userNameSelected)
                                self.dismissComplete(table:table)
                            }

                        }
                    }
                }
                self.present(selectUservc, animated: true, completion: nil)
        }))
        
        // Add cancel action
        //                           actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the action sheet
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}
