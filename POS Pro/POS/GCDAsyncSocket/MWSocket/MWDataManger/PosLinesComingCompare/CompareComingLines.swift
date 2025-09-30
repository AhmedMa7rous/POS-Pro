//
//  CompareComingLines.swift
//  pos
//
//  Created by M-Wageh on 19/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class CompareComingLines{
    static let shared = CompareComingLines()
    private var ipMessageType: IP_MESSAGE_TYPES?
    private var order_uid:String?
    private var order_id:Int?
    private var compareLineHelper:CompareLineHelper?

    private init(){
        compareLineHelper = CompareLineHelper.shaed
    }
    
    func startCompare(ipMessageType: IP_MESSAGE_TYPES?,order_uid:String,order_id:Int,comingLines:[pos_order_line_class],
                exsitsLines:[pos_order_line_class]) -> Int{
        self.ipMessageType = ipMessageType
        self.order_uid = order_uid
        self.order_id = order_id
        var neComingLines:[pos_order_line_class] = []
        if ipMessageType == .SPLIT_ORDER || ipMessageType == .MOVE_ORDER{
            if exsitsLines.count > 0{
                let exsitsLinesUIDS = exsitsLines.map { $0.uid }
                let comingLinesUIDS = comingLines.map { $0.uid }
                
                let differenceUIDS = exsitsLinesUIDS.filter { !comingLinesUIDS.contains($0) }
                for uidLine in differenceUIDS {
                    if let lineExistSplit = exsitsLines.filter({$0.uid == uidLine}).first {
                        lineExistSplit.is_void = true
                        if lineExistSplit.printed != .printed{
                            lineExistSplit.void_status = .after_sent_to_kitchen
                        }else{
                            lineExistSplit.void_status = ipMessageType == .SPLIT_ORDER ? .split_order : .move_line
                        }
                        lineExistSplit.save(write_info: true)
                    }
                }
                if ipMessageType == .MOVE_ORDER {
                    comingLines.forEach { comingLine in
                        comingLine.printed = .printed
                        comingLine.last_qty =  comingLine.qty
                        neComingLines.append(comingLine)
                    }
                }
            }else{
                comingLines.forEach { comingLine in
                    comingLine.printed = .printed
                    comingLine.last_qty =  comingLine.qty
                    neComingLines.append(comingLine)
                }
            }

        }
        return saveDifferenceLines(comingLines:neComingLines.count > 0 ? neComingLines :comingLines,exsitsLines:exsitsLines)
    }

    //MARK: - 1- saveDifferenceLines
    private func saveDifferenceLines(line_id:Int? = nil,
                                     comingLines:[pos_order_line_class],
                                     exsitsLines:[pos_order_line_class]) -> Int{
        guard let order_id = order_id , let order_uid = order_uid else {return 0}
        
        var differentCount = 0
        if exsitsLines.count == 0 {
            //MARK: - coming_lines are All New
            if ipMessageType != .SPLIT_ORDER {
                compareLineHelper?.saveNewLines(comingLines, with: order_uid, order_id: order_id, line_id:line_id)
                return comingLines.count
            }
        }
        if comingLines.count > exsitsLines.count {
            //coming added
        }
        for comingLine in comingLines {
//            let isSelectCategory = SharedManager.shared.isContaineCategory(comingLine.product.pos_categ_id ?? 0)
            if comingLine.pos_promotion_id != 0 {
                continue
            }
            //MARK: - coming_line is New Added
            if !(exsitsLines.contains(where: {$0.uid == comingLine.uid}) ) {
                differentCount += 1
                compareLineHelper?.saveNewLines([comingLine], with: order_uid, order_id: order_id,line_id:line_id)
                continue
            }else{
                //MARK: - coming_line is Exist line
                for existLine in exsitsLines {
                    //MARK: - check is coming_line exist in KDS
                    if comingLine.uid == existLine.uid  {
                        differentCount += self.compareAndSave(line_id: line_id,
                                                              comingLine: comingLine,
                                                              existLine: existLine)
                    }
                    
                }
            }
        }
        return differentCount
    }
  
    private func compareAndSave(line_id:Int? = nil,comingLine:pos_order_line_class,existLine:pos_order_line_class) -> Int{
        var differentCount = 0
        guard  let order_uid = order_uid else {return differentCount}
        let existQty = existLine.qty

        //MARK: - check is coming_line is returned_line
        if ipMessageType == .RETURNED_ORDER {
            let comingQty = abs(comingLine.qty)
            let newQty = existQty - comingQty
            if newQty <= 0 {
                existLine.qty = 0
                existLine.is_void = true
            }else{
                existLine.qty = newQty
                existLine.last_qty = existQty
            }
            differentCount +=  1
            compareLineHelper?.saveEditLines([existLine], with: order_uid )
            //                    break
        }
        else{
            SharedManager.shared.printLog("comingLine = \(comingLine.is_void) = qty =\(comingLine.qty) = last_qty =\(comingLine.last_qty)")
            SharedManager.shared.printLog("existLine = \(existLine.is_void) = qty =\(existLine.qty) = last_qty =\(existLine.last_qty)")
            //MARK: - check is coming_line is void_line
            if comingLine.is_void ?? false{
                let isExistVoid = (existLine.is_void ?? false)
                let isNotSameQty = (comingLine.last_qty != existLine.last_qty) || (comingLine.last_qty == existLine.last_qty)

                let needToUpdate = (!isExistVoid && isNotSameQty)
                SharedManager.shared.printLog("needToUpdate = \(needToUpdate)")

                if needToUpdate{
                    existLine.printed = .none
                    let newQty =  existQty - (comingLine.qty)
                    if newQty < 0 {
                        existLine.qty = 0
                        existLine.is_void = true
                    }else{
                        existLine.qty = newQty
                        existLine.last_qty = existQty
                    }
                    differentCount +=  1
                    compareLineHelper?.saveEditLines([existLine], with: order_uid,isVoid:true )
                }else{
                    existLine.printed = .printed
                    comingLine.printed = .printed
                    existLine.save()
                }
                //                    break
            }
            else{
                //MARK: - check is coming_line is edit_line
                if (compareLineHelper?.checkLineDifferent(comingLine,existLine)) ?? false {
                    differentCount +=  1
                    comingLine.last_qty = existQty
                    compareLineHelper?.saveEditLines([comingLine], with: order_uid)
                }
                else{
                //MARK: - coming_line is as same Exist_line
                        //                                break
                    existLine.printed = .printed
                    comingLine.printed = .printed
                    existLine.save()
                }
            }
        }
        if line_id == nil && ((comingLine.selected_products_in_combo.count) > 0 || (existLine.selected_products_in_combo.count) > 0) {
            
            differentCount +=  self.saveDifferenceLines(line_id: existLine.id, comingLines:comingLine.selected_products_in_combo , exsitsLines: existLine.selected_products_in_combo)
        }
        return differentCount
    }
    
   

}
