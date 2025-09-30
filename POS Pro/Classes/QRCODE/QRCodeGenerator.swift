//
//  QRCodeGenerator.swift
//  pos
//
//  Created by M-Wageh on 25/01/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import CoreImage.CIFilterBuiltins

class QRCodeGenerator {
    var data: Data?
    var context: CIContext?
    var filter: CIFilter?
    
    static let shared:QRCodeGenerator = QRCodeGenerator()
    private init(){
         context = CIContext()
        if #available(iOS 13.0, *) {
             filter = CIFilter.qrCodeGenerator()
        }else{
            filter = CIFilter(name: "CIQRCodeGenerator")
        }
    }
    func image(for string: String) -> UIImage? {
        guard let filter = filter else {
            return nil
        }
        guard let context = context else {
            return nil
        }
       let data = string.data(using: String.Encoding.ascii)
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        if let qrCodeImage = filter.outputImage?.transformed(by: transform) {
            if let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
                return UIImage(cgImage: qrCodeCGImage)
            }
        }
       return nil
   }
    
    func base64Data(for string:String)->String {
        return image(for: string)?.toBase64() ?? ""
    }


}
