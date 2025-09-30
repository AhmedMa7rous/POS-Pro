import UIKit

enum peerMessageType :Int{
    case none = 0,posInfo =  1 , order = 2
}


class peerMessage:NSObject  {
    
    var id = UUID()
    var  displayName: String?
    
    var data:[String:Any] = [:]
    
    var messageType:peerMessageType = .none
    
    var posInfo:peerConfig?
    var order:peerOrder?
    
   
    override init() {
        super.init()

    }
    
    init(_displayName:String,message:String) {
        super.init()
        
        displayName = _displayName
        data = message.toDictionary() ?? [:]
        
        
        let  type = data["messageType"] as? Int
        if (type != nil)
        {
            if(type == peerMessageType.posInfo.rawValue)
            {
                messageType = .posInfo
                self.readPosInfo(message)
                
            }
            else  if(type == peerMessageType.order.rawValue)
            {
                messageType = .order
                self.readOrder(message)
            }
            
            
        }
        
    }
    
    
    func readPosInfo(_ message:String)
    {
         if (!message.isEmpty)
        {
             posInfo = peerConfig.toClass(json: message) //peerConfigClass(fromDictionary: data)
        }
    }
    
    
    func readOrder(_ message:String )
    {
//        let order = peerOrder(fromDictionary: data)
//        let lines:[String] = data["lines"] as? [String] ?? []
//
//        order.customerName = data["customerName"] as? String ?? ""
//        order.customerPhone = data["customerPhone"] as? String ?? ""
//
//        for line in lines
//        {
//            let dic_line = line.toDictionary()
//            let pos_line = peerOrderLine(fromDictionary: dic_line!)
//            if pos_line.is_combo_line
//            {
//                let combo_lines = dic_line!["lines"] as? [String] ?? []
//                for combo in combo_lines
//                {
//                    pos_line.selected_products_in_combo.append( peerOrderLine(fromDictionary: combo.toDictionary()!))
//                }
//
//
//            }
//
//            //                order.section_ids.append(pos_line)
//
//            order.pos_order_lines.append(pos_line)
//
//        }
        
        if (!message.isEmpty)
       {
            order = peerOrder.toClass(json: message) //peerConfigClass(fromDictionary: data)
       }
        
    }
    
    
   
    
    
    
    
}
