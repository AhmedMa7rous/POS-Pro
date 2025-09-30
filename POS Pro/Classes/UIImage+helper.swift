//
//  UIImage+helper.swift
//  pos
//
//  Created by khaled on 7/22/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation

 
extension UIImage {
        
    class  func generateQRCode(from string: String) -> UIImage? {
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

    convenience init?(name: String) {
        //            guard let image = #imageLiteral(resourceName: "TheImage"), nil != image.cgImage else {
        //               return nil
        //           }
        

        
        
        var ext = ""
        if !name.contains(".") {
            ext = ".png"
        }
        
        if let imagePath = Bundle.main.path(forResource: name, ofType: ext),
          let image = UIImage(contentsOfFile: imagePath) {
             //Your image has been loaded
            self.init(cgImage: image.cgImage!)

        }
        else{
            return nil
        }
        
//        let url = Bundle.main.url(forResource: name, withExtension: ext)
//
//        if url == nil
//        {
//            return nil
//        }
//
//
//        let imageData = try! Data(contentsOf: url!)
//        let image = UIImage(data: imageData)
//        self.init(cgImage: image!.cgImage!)

    }
    
    convenience init?(fileURLWithPath url: URL, scale: CGFloat = 1.0) {
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data, scale: scale)
        } catch {
           SharedManager.shared.printLog("-- Error: \(error)")
            return nil
        }
    }
    
    func toBase64() -> String? {
            guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters).replacingOccurrences(of: "\n\r", with: "")
        }
    
  class  func ConvertBase64StringToImage (imageBase64String:String) -> UIImage? {
 
    if imageBase64String == "" {
        return #imageLiteral(resourceName: "MWno_photo")
    }
    
        var imageBase64Stringx = imageBase64String.replacingOccurrences(of: "data:image/png;base64,", with: "")
       imageBase64Stringx = imageBase64String.replacingOccurrences(of: "\n", with: "")
        let imageData = Data.init(base64Encoded: imageBase64Stringx, options: .init(rawValue: 0))

    if imageData == nil
    {
       return #imageLiteral(resourceName: "MWno_photo")
    }
    
        let image = UIImage(data: imageData!)
        return image ??  #imageLiteral(resourceName: "MWno_photo")
    }
    
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
    
    
    func ResizeImage(targetSize: CGSize) -> UIImage {
        var rightValue = 0
        var leftValue = 0
        if (SharedManager.shared.appSetting().margin_invoice_right_value) != 25 {
            rightValue = Int((SharedManager.shared.appSetting().margin_invoice_right_value)/3)
        }
        if (SharedManager.shared.appSetting().margin_invoice_left_value) != 35 {
            leftValue = Int((SharedManager.shared.appSetting().margin_invoice_left_value)/3)
        }
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
       
        let rect = CGRect(x: CGFloat(leftValue), y: 0, width: newSize.width  - CGFloat(rightValue), height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func ResizeImage(targetWidth: CGFloat) -> UIImage {
        let size = self.size
        let widthRatio  = targetWidth / size.width
        let heightRatio = widthRatio //targetSize.height / size.height
        
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    func scaled(with scale: CGFloat) -> UIImage? {
        // size has to be integer, otherwise it could get white lines
        let size = CGSize(width: floor(self.size.width * scale), height: floor(self.size.height * scale))
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    
    func save(at directory: FileManager.SearchPathDirectory,
              pathAndImageName: String,
              createSubdirectoriesIfNeed: Bool = true,
              compressionQuality: CGFloat = 1.0)  -> URL? {
        do {
            let documentsDirectory = try FileManager.default.url(for: directory, in: .userDomainMask,
                                                                 appropriateFor: nil,
                                                                 create: false)
            return save(at: documentsDirectory.appendingPathComponent(pathAndImageName),
                        createSubdirectoriesIfNeed: createSubdirectoriesIfNeed,
                        compressionQuality: compressionQuality)
        } catch {
           SharedManager.shared.printLog("-- Error: \(error)")
            return nil
        }
    }
    
    func save(at url: URL,
              createSubdirectoriesIfNeed: Bool = true,
              compressionQuality: CGFloat = 1.0)  -> URL? {
        do {
            if createSubdirectoriesIfNeed {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            guard let data = jpegData(compressionQuality: compressionQuality) else { return nil }
            try data.write(to: url)
            return url
        } catch {
           SharedManager.shared.printLog("-- Error: \(error)")
            return nil
        }
    }
    
    
    
    
}
