//
//  FloorView.swift
//  pos
//
//  Created by Alhaytham Alfeel on 4/16/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation

class FloorView: UIView {
    
    // MARK: - Properties
    
    private var btnTables = [UIButton]()
    private var viewTables = [ShadowView]()
    private var maxX: Double = 0.0, maxY: Double = 0.0
    
    var delegate: FloorViewDelegate?
    var tables = [restaurant_table_class]() {
        didSet {
            maxX = 0.0
            maxY = 0.0
            
            for table in tables {
                if maxX < table.position_h! + table.width! {
                    maxX = table.position_h! + table.width!
                }
                
                if maxY < table.position_v! + table.height! {
                    maxY = table.position_v! + table.height!
                }
            }
            
            setupTableViews()
        }
    }
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTableViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupTableViews()
    }
    
    // MARK: - Actions
    
    @objc func onTableTapped(sender: UIButton) {
        guard let index = btnTables.firstIndex(of: sender) else {
            fatalError("The button, \(sender), is not in the ratingButtons array: \(btnTables)")
        }
        delegate?.onTableTapped(table: tables[index])
    }
    
    // MARK: - Minions
    
    func scale() -> Double {
        // Calculate scale of drawing tables
        
        //        var scale = frame.width / maxX
        //        let yScale = frame.height / maxY
        
        //        if yScale < scale {
        //            scale = yScale
        //        }
        //
        return 1
    }
    
    func imageWithColor(_ color: UIColor, shape: Shape, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        color.setFill()
        
        if shape == .round {
            if let context = UIGraphicsGetCurrentContext() {
                context.fillEllipse(in: rect)
            }
        } else {
            UIRectFill(rect)
        }
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func viewWithColor(_ color: UIColor, shape: Shape, frame: CGRect) -> ShadowView {
        let view = ShadowView(frame: CGRect(x: frame.minX, y: frame.minY, width: frame.size.width, height: frame.size.height))
                
        view.borderColor = color
        view.borderWidth = 2
        view.backgroundColor = .white
       
        
        if shape == .round {
            view.cornerRadius = (frame.size.width) / 2
        } else {
        }
        
        return view
    }
    
    func chairView(_ color: UIColor, transform: CGAffineTransform, frame: CGRect) -> ShadowView {
        let view = ShadowView(frame: CGRect(x: frame.minX, y: frame.minY, width: frame.size.width, height: frame.size.height))
                
        view.borderWidth = 5
        view.backgroundColor = color

        view.cornerRadius = 2

        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 100, y: 100), radius: CGFloat(20), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        // Change the fill color
        shapeLayer.fillColor = UIColor.clear.cgColor
        // You can change the stroke color
        shapeLayer.strokeColor = UIColor.red.cgColor
        // You can change the line width
        shapeLayer.lineWidth = 3.0
        
        return view
    }
    
    //    func setupTableViews() {
    //        // Clear any existing buttons
    //        btnTables.forEach { $0.removeFromSuperview() }
    //        btnTables.removeAll()
    //
    //        guard !tables.isEmpty else { return }
    //
    //        //        let ratio = scale()
    //
    //        for table in tables {
    //            let button = UIButton()
    //            button.frame = CGRect.init(x: table.position_h!, y: table.position_v!, width: table.width!, height: table.height!)
    //
    //
    //            let image = imageWithColor(table.color!,
    //                                       shape: table.shape,
    //                                       size: button.frame.size)
    //
    //            button.setTitle(table.display_name, for: .normal)
    //            button.setBackgroundImage(image, for: .normal)
    //
    //            // Setup the button action
    //            button.addTarget(self, action: #selector(onTableTapped(sender:)), for: .touchUpInside)
    //
    //
    //            self.addSubview(button)
    //
    //            //            // Add constraints
    //            //            button.translatesAutoresizingMaskIntoConstraints = false
    //            //            NSLayoutConstraint.activate([
    //            //                button.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(table.position_v! * ratio)),
    //            //                button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: CGFloat(table.position_h! * ratio)),
    //            //                button.widthAnchor.constraint(equalToConstant: CGFloat(table.width! * ratio)),
    //            //                button.heightAnchor.constraint(equalToConstant: CGFloat(table.height! * ratio))
    //            //            ])
    //            //
    //            btnTables.append(button)
    //        }
    //    }
    
    func setupTableViews() {
        // Clear any existing buttons
        btnTables.forEach { $0.removeFromSuperview() }
        btnTables.removeAll()
        viewTables.forEach { $0.removeFromSuperview() }
        viewTables.removeAll()
        
        guard !tables.isEmpty else { return }
        
        for table in tables {
            
            let button = UIButton()
            let frame = CGRect.init(x: table.position_h!, y: table.position_v!, width: table.width!, height: table.height!)
            button.frame = frame
            button.setTitleColor(.black, for: .normal)
            
            let view = viewWithColor(table.color!,
                                     shape: table.shape,
                                     frame: frame)
            
//            var seats_lenth:Int = Int( table.width! + table.height!) * 2
//            seats_lenth = seats_lenth / table.seats!
            
            
            // charis
//            let yourViewBorder = CAShapeLayer()
//            yourViewBorder.strokeColor = UIColor.black.cgColor
//            yourViewBorder.lineWidth = 5
//            yourViewBorder.lineDashPattern = [NSNumber(value: seats_lenth), NSNumber(value: seats_lenth / 5  ) ]
//            yourViewBorder.frame = view.bounds
//            yourViewBorder.fillColor = nil
//            yourViewBorder.path = UIBezierPath(rect: view.bounds).cgPath
//            view.layer.addSublayer(yourViewBorder)
            
            
            button.setTitle(table.display_name, for: .normal)
            //            button.setBackgroundImage(image, for: .normal)
            
            // Setup the button action
            button.addTarget(self, action: #selector(onTableTapped(sender:)), for: .touchUpInside)
            button.setTitleColor(UIColor.init(hexString: "#7E7E7E"), for: .normal)
            
            self.addSubview(view)
            self.addSubview(button)
            
            viewTables.append(view)
            btnTables.append(button)
            
            
   
            
            ///draw seats
//            let seats = Double(table.seats!)
//
//            let circumference = table.width! * Double.pi
//            let chairWidth = Double(10)
//            let chairHeight = Double(5)
//            let chairMinX = Double(7)
//            let spacing = circumference - seats * chairWidth
//
//            var seatsViews = [ShadowView]()
//            for _ in 0...table.seats! {
//                let seatFrame = CGRect.init(x: Double(frame.midX) - chairWidth / 2 - chairMinX, y: Double(frame.minY), width: chairWidth, height: chairHeight)
////                let seatView = chairView(table.color!, transform: <#T##CGAffineTransform#>, frame: seatFrame)
//                seatsViews.append(seatView)
//                self.addSubview(seatView)
//            }
        }
    }
}

protocol FloorViewDelegate {
    func onTableTapped(table: restaurant_table_class)
}
