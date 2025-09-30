//
//  TableManagementViewController.swift
//  pos
//
//  Created by Alhaytham Alfeel on 4/15/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class TableManagementViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var scFloors: UISegmentedControl!
    @IBOutlet weak var floorView: FloorView!
    @IBOutlet weak var scView: UIView!
    private var floors = [restaurant_floor_class]()
    private var tables = [restaurant_table_class]()
    
    var selectedTable: restaurant_table_class?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFloors()
        setupSegmentedControl()
        setupTables()
        
        floorView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scFloors.selectedSegmentIndex = 0
        scFloors.sendActions(for: .valueChanged)
    }
    

    
    
    // MARK: - Actions
    
    @IBAction func onCloseTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onSegmentedValueChanged(sender: UISegmentedControl, event: UIEvent) {
        var tables = [restaurant_table_class]()
        
        for table in self.tables {
            if table.floor_id == self.floors[sender.selectedSegmentIndex].id {
                table.floor_name = self.floors[sender.selectedSegmentIndex].name
                tables.append(table)
            }
        }
        
        floorView.tables = tables
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
        guard !floors.isEmpty else { return }
        
        scFloors.removeAllSegments()
        floors.forEach {
            scFloors.insertSegment(withTitle: "Floor " + $0.name, at: scFloors.numberOfSegments, animated: true)
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
        let results = restaurant_table_class.getAll() // api.get_last_cash_result(keyCash: api.RESTAURANT_TABLE)
        
         for result in results {
         
            let table = restaurant_table_class(fromDictionary: result)
          tables.append(table)
        }
        
//        for result in results {
//            if let dictionary = result as? [String:Any] {
//                let id = dictionary["id"] as? Int ?? 0
//                let name = dictionary["name"] as? String ?? ""
//                let shape = dictionary["shape"] as? String ?? Shape.square.rawValue
//                let x = dictionary["position_h"] as? CGFloat ?? 0.0
//                let y = dictionary["position_v"] as? CGFloat ?? 0.0
//                let w = dictionary["width"] as? CGFloat ?? 0.0
//                let h = dictionary["height"] as? CGFloat ?? 0.0
//                let seats = dictionary["seats"] as? Int ?? 0
//                let isActive = dictionary["active"] as? Bool ?? true
//                let displayName = dictionary["display_name"] as? String ?? ""
//
//                var floorId = 0
//                var floorName = ""
//
//                if let floor = dictionary["floor_id"] as? [Any] {
//                    floorId = floor[0] as? Int ?? 0
//                    floorName = floor[1] as? String ?? ""
//                }
//
//                var r: CGFloat = 0.0
//                var g: CGFloat = 0.0
//                var b: CGFloat = 0.0
//
//                if let color = dictionary["color"] as? String,
//                    let end = color.firstIndex(of: ")"),
//                    let rgb = color.split(separator: "(").last?[..<end] {
//                    let values = rgb.split(separator: ",")
//
//                    if let v0 = Int(values[0].trimmingCharacters(in: .whitespaces)),
//                        let v1 = Int(values[1].trimmingCharacters(in: .whitespaces)),
//                        let v2 = Int(values[2].trimmingCharacters(in: .whitespaces)){
//                        r = CGFloat(v0) / 255.0
//                        g = CGFloat(v1) / 255.0
//                        b = CGFloat(v2) / 255.0
//                    }
//                }
//
//                let table = TableResult(id: id, name: name,
//                                        floor: FloorResult(id: floorId, tableIDS: [], posConfigID: [], name: floorName),
//                                        shape: Shape(rawValue: shape) ?? .square,
//                                        x: x, y: y, width: w, height: h,
//                                        seats: seats,
//                                        red: r, green: g, blue: b,
//                                        active: isActive,
//                                        createUid: [], createDate: "",
//                                        writeUid: [], writeDate: "",
//                                        displayName: displayName,
//                                        lastUpdate: "")
//
//                tables.append(table)
//            }
//        }
    }
}

extension UIButton {
    public func setBackgroundImage(named: String) {
        if let bgImage = resizedImage(at: named, for: self.frame.size) {
            self.backgroundColor = UIColor(patternImage: bgImage)
        }
    }
    
    func resizedImage(at named: String, for size: CGSize) -> UIImage? {
        guard let image = UIImage(name: named) else {
            return nil
        }
        
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: size)
            
            return renderer.image { (context) in
                      image.draw(in: CGRect(origin: .zero, size: size))
                  }
        } else {
            // Fallback on earlier versions
            
            return nil
        }
        
      
    }
}

extension TableManagementViewController: FloorViewDelegate {
    func onTableTapped(table: restaurant_table_class) {
        selectedTable = table
        performSegue(withIdentifier: "Unwind2Home", sender: self)
    }
}
