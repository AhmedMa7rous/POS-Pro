//
//  STC_QRBuilder.swift
//  pos
//
//  Created by Khaled on 2/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit
import zlib
 

enum CRCType {
      case MODBUS
      case ARC
  }

class STC_QRBuilder: NSObject {
    
   
    let payload_Format_Indicator = "000201"
    let point_of_Initiation_Method = "010212"
    let Merchant_Category_Code = "52045812"
    let Transaction_Currency = "5303682"
    let Country_Code = "5802SA"


    
    
    var Transaction_Amount = "0.00"

//
//    var merchant_Identifier:String = "rabeh.io"
//    var Acquirer_ID:String = "STCPAY"
//    var Merchant_ID:String = "61263756001"
//    var Merchant_teller_ID:String = "0"

    var merchant_Identifier:String = "sa.merchant.haseel"
    var Acquirer_ID:String = "STCPAY"
    var Merchant_ID:String = "61273953454"
    var Merchant_teller_ID:String = "Riyadh"
    
    var Merchant_Name = "Haseel"
    var Merchant_City = "Riyadh"
    
    
    // Merchant Data
    var Bill_Number = "merchant"
    var Reference_Label = "ggffgt"
    var Store_Label = "dsds"
    var Terminal_Labe = "12345"
    
    
    func bulid() -> UIImage?
    {
        let qr:NSMutableString = NSMutableString()
        qr.append(payload_Format_Indicator)
        qr.append("\n")
        qr.append(point_of_Initiation_Method)
        qr.append("\n")
        qr.append(bulid_merchant())
        qr.append("\n")
        qr.append(Merchant_Category_Code)
        qr.append("\n")
        qr.append(Transaction_Currency)
        qr.append("\n")
        qr.append(bulid_withCode(code: "54", value: Transaction_Amount))
        qr.append("\n")
        qr.append(Country_Code)
        qr.append("\n")
        qr.append(bulid_withCode(code: "59", value: Merchant_Name))
        qr.append("\n")
        qr.append(bulid_withCode(code: "60", value: Merchant_City))
        qr.append("\n")
        qr.append(bulid_merchant_data())
        
//        test()
        
        
        var allText = qr.replacingOccurrences(of: "\n", with: "")
        allText = allText.replacingOccurrences(of: " ", with: "")
        allText = allText + "6304"
//        let data: [UInt8] = Array(allText.utf8)
//        let arcValue = crc16(data, type: .ARC)
//        let arcStr = String(format: "0x%4X", arcValue!)

//        qr.append(get_CRC(str: String(arcStr)))

//        let crc = get_CRC(str: String(arcStr))
         let crc = getCRC(str: allText)
        
        allText = allText + crc.crc_ARC
//        let string_qr = String(qr.replacingOccurrences(of: "\n", with: ""))
        
       SharedManager.shared.printLog("https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=\(allText)")
        
        let image = generateQRCode(from: allText)
        
        return image

    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    
    
    func bulid_withCode(code:String,value:String) ->String
    {
         let arr =  bulidString(str:value)
         let str = arr[1] as? String ?? ""
               
          return String(format: "%@%@", code   ,str )
    }
    
       func bulid_merchant_data() ->String
       {
            let arr_Bill_Number:[Any] =  bulidString(str:  Bill_Number) // 01
            let arr_Reference_Label:[Any] =   bulidString(str: Reference_Label) // 05
            let arr_Store_Label:[Any] =   bulidString(str:Store_Label) // 03
            let arr_Terminal_Labe:[Any] = bulidString(str:Terminal_Labe) // 07
      
           
           var len = 0
           var merchant = ""
           
           len = len + (arr_Bill_Number[0] as? Int ?? 0)
           merchant = String(format: "%@\n  %@%@", merchant ,"01", (arr_Bill_Number[1] as? String ?? ""))
           
           len = len + (arr_Reference_Label[0] as? Int ?? 0)
           merchant = String(format: "%@\n  %@%@", merchant ,"05", (arr_Reference_Label[1] as? String ?? ""))
           
           len = len + (arr_Store_Label[0] as? Int ?? 0)
           merchant = String(format: "%@\n  %@%@", merchant ,"03", (arr_Store_Label[1] as? String ?? ""))
           
           len = len + (arr_Terminal_Labe[0] as? Int ?? 0)
           merchant = String(format: "%@\n  %@%@", merchant ,"07", (arr_Terminal_Labe[1] as? String ?? ""))
            
           
           len = len + 16
          let  merchant_Account_Information =  String(format: "%@%@%@", "62" ,  IntToString(val:len) ,merchant )
           
           return merchant_Account_Information
    
       }
    
     
    func bulid_merchant() ->String
    {
          let arr_merchant_Identifier:[Any] =  bulidString(str:  merchant_Identifier) // 00 Merchant_Identifier
         let arr_Acquirer_ID:[Any] =   bulidString(str: Acquirer_ID) // 01 Acquirer_ID
         let arr_Merchant_ID:[Any] =   bulidString(str:Merchant_ID) // 02 Merchant_ID
         let arr_Merchant_teller_ID:[Any] = bulidString(str:Merchant_teller_ID) // 03 Merchant_teller_ID
   
        
        var len = 0
        var merchant = ""
        
        len = len + (arr_merchant_Identifier[0] as? Int ?? 0)
        merchant = String(format: "%@\n %@%@", merchant ,"00", (arr_merchant_Identifier[1] as? String ?? ""))
        
        len = len + (arr_Acquirer_ID[0] as? Int ?? 0)
        merchant = String(format: "%@\n %@%@", merchant ,"01", (arr_Acquirer_ID[1] as? String ?? ""))
        
        len = len + (arr_Merchant_ID[0] as? Int ?? 0)
        merchant = String(format: "%@\n %@%@", merchant ,"02", (arr_Merchant_ID[1] as? String ?? ""))
        
        len = len + (arr_Merchant_teller_ID[0] as? Int ?? 0)
        merchant = String(format: "%@\n %@%@", merchant ,"03", (arr_Merchant_teller_ID[1] as? String ?? ""))
         
        
        len = len + 16
       let  merchant_Account_Information =  String(format: "%@%@%@", "44" ,  IntToString(val:len) ,merchant )
        
        return merchant_Account_Information
 
    }


    func bulidString(str:String) -> [Any]
    {
        var new_str = str
        let len = new_str.count
        
        new_str = String(format: "%@%@", IntToString(val: len ) ,new_str)
        
        return [len,new_str]
    }
    
    
    func IntToString(val:Int) -> String
    {
        var len_str = String(val)
        if len_str.count == 1
        {
            len_str = String(format: "0%@", len_str)
        }
        
        return len_str
    }
    
    
  
    func get_CRC(str:String) -> String
    {
      let txt = String(format: "%@%@", str , "6304"   )
//           let str = "00020101021226270012hk.com.hkicl0207000000152040000530334454075000.005802HK5902NA6002HK62680104000202081234567803040003040400040504ABCD0604000507040006080400076304"
 
     let datas = Data(txt.utf8)
      let hexString = datas.map{ String(format:"%02x", $0) }.joined()
            
       let crc = CRC16(hexStr: hexString)
        
        return String(format: "%@%@",  "6304" , crc   )
    }

  

    func crc16(_ data: [UInt8], type: CRCType) -> UInt16? {
        if data.isEmpty {
            return nil
        }
        let polynomial: UInt16 = 0xA001 // A001 is the bit reverse of 8005
        var accumulator: UInt16
        // set the accumulator initial value based on CRC type
        if type == .ARC {
            accumulator = 0
        }
        else {
            // default to MODBUS
            accumulator = 0xFFFF
        }
        // main computation loop
        for byte in data {
            var tempByte = UInt16(byte)
            for _ in 0 ..< 8 {
                let temp1 = accumulator & 0x0001
                accumulator = accumulator >> 1
                let temp2 = tempByte & 0x0001
                tempByte = tempByte >> 1
                if (temp1 ^ temp2) == 1 {
                    accumulator = accumulator ^ polynomial
                }
            }
        }
        return accumulator
    }
    
    func getCRC(str:String) -> (crc:String,crc_ARC:String,crc_MODBUS:String)
    {
 
     
     let datas = Data(str.utf8)
     let hexString = datas.map{ String(format:"%02x", $0) }.joined()
     
     let crc = CRC16(hexStr: hexString)
 //
 
     let data: [UInt8] = Array(str.utf8)
    
 
       let arcValue = crc16(data, type: .ARC)

        let modbusValue = crc16(data, type: .MODBUS)

//        if arcValue != nil && modbusValue != nil {

//            let arcStr = String(format: "0x%4X", arcValue!)
//            let modbusStr = String(format: "0x%4X", modbusValue!)

        let arcStr = String(format: "%4X", arcValue!)
        let modbusStr = String(format: "%4X", modbusValue!)
           SharedManager.shared.printLog("CRCs: ARC = " + arcStr + " MODBUS = " + modbusStr)
//        }
 
   
        return (crc,arcStr,modbusStr)
     
    }
    
    

   func test()
   {
    // try it out...
     
    let str = "00020101021244570018sa.merchant.hasfff0106STCPAY0211612739534540306Riyadh520458125303682540537.205802SA5906Haseel6006Riyadh62390108merchant0506ggffgt0304dsds0705123456304"
    
//    str = "1"

 
    
    let datas = Data(str.utf8)
    let hexString = datas.map{ String(format:"%02x", $0) }.joined()
    
    let crc = CRC16(hexStr: hexString)
//
//    let test = dataWithHexString(hex: hexString)
    
    let data: [UInt8] = Array(str.utf8)
   
//       let data = [UInt8]([0x31])

      let arcValue = crc16(data, type: .ARC)

       let modbusValue = crc16(data, type: .MODBUS)

       if arcValue != nil && modbusValue != nil {

           let arcStr = String(format: "0x%4X", arcValue!)
           let modbusStr = String(format: "0x%4X", modbusValue!)

          SharedManager.shared.printLog("CRCs: ARC = " + arcStr + " MODBUS = " + modbusStr)
       }
//
 
//    let test = data.crc16()
//    let check = String(format: "0x%4X", test)

  
    
   }
    
 func dataWithHexString(hex: String) -> Data {
     var hex = hex
     var data = Data()
     while(hex.count > 0) {
         let subIndex = hex.index(hex.startIndex, offsetBy: 2)
         let c = String(hex[..<subIndex])
         hex = String(hex[subIndex...])
         var ch: UInt32 = 0
         Scanner(string: c).scanHexInt32(&ch)
         var char = UInt8(ch)
         data.append(&char, count: 1)
     }
     return data
 }
    
    func CRC16(hexStr : String)->String{
        let data = dataWithHexString(hex: hexStr  )
        let final: UInt32 = 0xffff
        var crc = final
        data.forEach { (byte) in
            crc ^= UInt32(byte) << 8
            (0..<8).forEach({ _ in
                crc = (crc & UInt32(0x8000)) != 0 ? (crc << 1) ^ 0x1021 : crc << 1
            })
        }
        let crcNew = UInt16(UInt32(crc & final))
        return String(format:"%2X", crcNew)
    }
}
