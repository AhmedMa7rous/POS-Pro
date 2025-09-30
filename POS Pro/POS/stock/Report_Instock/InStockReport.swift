//
//  InStockReport.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/24/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
class InStockReport: NSObject {
    enum InfoInStockEnum:String{
        case MOVEMENT_NUMBER = "Inventory Number"
        case MOVEMENT_DATE = "Date"
        case MOVEMENT_FROM = "From"
        case MOVEMENT_ORGIN = "Source"
        case POS_NUMBER = ""
        case CASHIER = "CASHIER"

        func getArabicValue() -> String{
            switch self {
            case .MOVEMENT_NUMBER:
                return "رقم المخزون";
            case .MOVEMENT_DATE:
                return "التاريخ";
            case .MOVEMENT_FROM:
                return "من";
            case .MOVEMENT_ORGIN:
                return "المصدر";
            case .POS_NUMBER:
                return "";
//                return "نقطة البيع";
            case .CASHIER:
                return "الكاشير";
            }
        }

    }
    private var pos = pos_config_class.getDefault()
    private let setting = settingClass.getSettingClass()
    var inStockMoveModel: InStockMoveModel!
    var operationLinesData:[OperationLineModel] = []

    init(inStockMoveModel: InStockMoveModel) {
        self.inStockMoveModel = inStockMoveModel
    }
    func setOperationLinesData(with data:[OperationLineModel]){
        self.operationLinesData.removeAll()
        self.operationLinesData.append(contentsOf: data)
    }
    func renderInStock() -> String {
       
        let pathToInvoice = Bundle.main.path(forResource: "in_stock_report", ofType:"html")
        do {
            var HTMLContent = try String(contentsOfFile: pathToInvoice!)
            // The logo image.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LOGO#", with: renderLogo())
            // Oddo Header.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ODOO_HEADER#", with: renderOdooHeader())
            // MOVEMENT NUMBER.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#MOVEMENT_NUMBER#", with: rendeInfoInStock(for: .MOVEMENT_NUMBER,with:self.inStockMoveModel.name ?? ""))
            // MOVEMENT DATE.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#MOVEMENT_DATE#", with: rendeInfoInStock(for: .MOVEMENT_DATE,with:self.inStockMoveModel.scheduled_date ?? ""))
            // MOVEMENT FROM.
            if let partnerName = self.inStockMoveModel.partner_id.last , !partnerName.isEmpty  {
                HTMLContent = HTMLContent.replacingOccurrences(of: "#MOVEMENT_FROM#", with: rendeInfoInStock(for: .MOVEMENT_FROM,with:partnerName))
            }else{
                if let partnerName = self.inStockMoveModel.location_id.last , !partnerName.isEmpty {
                    HTMLContent = HTMLContent.replacingOccurrences(of: "#MOVEMENT_FROM#", with: rendeInfoInStock(for: .MOVEMENT_FROM,with:partnerName))
                }else{
                    HTMLContent = HTMLContent.replacingOccurrences(of: "#MOVEMENT_FROM#", with: "")
                }
            }
            // MOVEMENT origin.
            if let originName = self.inStockMoveModel.origin , !originName.isEmpty  {
                HTMLContent = HTMLContent.replacingOccurrences(of: "#MOVEMENT_ORGIN#", with: rendeInfoInStock(for: .MOVEMENT_ORGIN,with:originName))
            }else{
                HTMLContent = HTMLContent.replacingOccurrences(of: "#MOVEMENT_ORGIN#", with: "")
            }
            //POS NUMBER.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#POS_NUMBER#", with: rendeInfoInStock(for: .POS_NUMBER,with:self.getPOS()))
            //CASHIER.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CASHIER#", with: rendeInfoInStock(for: .CASHIER,with:self.getChasherName()))
            // QTY ITEM PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#QTY_ITEM_PRICE#", with: renderQtyItemPrice())
            // ITEMS .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: renderItems())
            
            return HTMLContent
            
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- The logo image.
    private func renderLogo() -> String {
        let width = setting.receipt_logo_width <= 0 ? 100 :  setting.receipt_logo_width
//        let logoImageURL = FileMangerHelper.shared.getLogoBase64()
//        if logoImageURL.isEmpty {
//            return ""
//        }
        let logoPath = FileMangerHelper.shared.getLogoPathString()
        if (logoPath.isEmpty) {
            return ""
        }
        guard let pathLogoCompany = Bundle.main.path(forResource: "logo_company", ofType:"html") else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathLogoCompany)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#WIDTH#", with: "\(width)")
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: logoPath)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- The Oddo Header.
    private func renderOdooHeader() -> String {
        let header =  pos.receipt_header ?? ""
        if header.isEmpty {
            return ""
        }
        guard let pathOdooHeader = Bundle.main.path(forResource: "odoo_header", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathOdooHeader)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: header)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- The INFO IN-STOCK.
    private func rendeInfoInStock(for info:InfoInStockEnum,with value:String) -> String {
        guard let pathOdooHeader = Bundle.main.path(forResource: "info_locatize_html", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathOdooHeader)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EN#", with: info.rawValue)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#AR#", with: info.getArabicValue())
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: value)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- POS NAME.
    private func getPOS() -> String {
        return self.pos.name ?? ""
       
    }
    //MARK:- casher NAME.
    private func getChasherName() -> String {
        return res_users_class.getDefault().name ?? ""
       
    }
    //MARK:- QTY Item Price .
    private func renderQtyItemPrice() -> String {
        let path =  Bundle.main.path(forResource: "qty_item_price_inStock", ofType:"html") ?? ""
        do {
            return try String(contentsOfFile: path)
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
            return ""
        }
    }
    //MARK:- Render items.
    func renderItems() -> String {
        let rowsItems:NSMutableString = NSMutableString()
        self.operationLinesData.forEach { (line) in
            rowsItems.append( renderOperationLine(line) )

        }
        
        return String(rowsItems)
    }
    private func renderOperationLine(_  line: OperationLineModel ) -> String {
        
       let path = Bundle.main.path(forResource: "single_item_inStock", ofType:"html") ?? ""
        
        do {
            var HTMLContent = try String(contentsOfFile: path)
            let qty = ("\(line.product_uom_qty ?? 0)") + " " + (line.product_uom.last ?? "")
            let desc = line.product_id.last ?? ""
            HTMLContent = HTMLContent.replacingOccurrences(of: "#COMBO_ITEM#", with: "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#QTY#", with: qty )
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEM_DESC#", with: desc)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
            return ""
        }

    }
}
