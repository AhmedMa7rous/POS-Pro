//
//  MWHtmlConvertService.swift
//  pos
//
//  Created by M-Wageh on 02/11/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import PDFKit


class MWHtmlConvertService {
    static let shared = MWHtmlConvertService()
   private var newImage: UIImage?
    private var currentContext = UIGraphicsGetCurrentContext()
    private var html:String = ""
    private var textFontAttributes:NSAttributedString?

    private init(){}
    
    func getImageHtml() -> UIImage? {
        return newImage
    }
   
    func setHtml(_ html:String){
        self.resetService()
        self.html = html
        self.setAttributedString()
        self.setImageHtml()
    }
    func resetService(){
        html = ""
        newImage = nil
        textFontAttributes = nil
        if currentContext != nil {
            currentContext = nil
        }
    }
    private func setImageHtml(){
         guard let textFontAttributes = self.textFontAttributes else {return}
         let cgRect = self.getRectPage(for:textFontAttributes)
 //        let pdfData = self.getPDFData(for: html)
         newImage = createImage(for: textFontAttributes,with: cgRect)
 //        let imagePdf = self.imageForPDF(data: pdfData)
 //        self.createPDF(for: html, with: cgRect)
 //        return image
     }
    private func setAttributedString(){
        self.textFontAttributes = html.htmlToAttributedString(font: nil)
    }
    private func getRectPage(for att:NSAttributedString) -> CGRect{
       let width =  att.size().width
       let height =  att.size().height
       return CGRect(x: 0, y: 0, width: (width <= 1 ? 900 : width)  , height:(height <= 1 ? 2700 : height))
    }
    //MARK: - Create a Image file from an HTML string
    private func createImage(for textFontAttributes: NSAttributedString,with cgRect :CGRect = CGRect(x: 0, y: 0, width: 900, height: 2700)) -> UIImage? {
        return autoreleasepool { () -> UIImage? in
        let scale:CGFloat = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(cgRect.size, false, scale)
        textFontAttributes.draw(in: cgRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        guard let _ = UIGraphicsGetCurrentContext() else {
            SharedManager.shared.printLog("graphic context is not available so you can not create an image. \n  \(SharedManager.shared.reportMemory())")
            UIGraphicsEndImageContext()
           return newImage
        }
        UIGraphicsEndImageContext()
        return newImage
        }
    }
    //MARK: - Create a PDF file from an HTML string
    private func createPDF(for html:String,with cgRect:CGRect = CGRect(x: 0, y: 0, width: 900, height: 2700)){
//        let html = "<b>Hello <i>World!</i></b>"
        let fmt = UIMarkupTextPrintFormatter(markupText: html)

        // 2. Assign print formatter to UIPrintPageRenderer
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)

        // 3. Assign paperRect and printableRect
//        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        render.setValue(cgRect, forKey: "paperRect")
        render.setValue(cgRect, forKey: "printableRect")

        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)

        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage();
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext();
        // 5. Save PDF file
        guard let outputURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("output").appendingPathExtension("pdf")
            else { fatalError("Destination URL not created") }

        pdfData.write(to: outputURL, atomically: true)
        SharedManager.shared.printLog("open \(outputURL.path)")
    }
    //MARK: - Create a PDF file from an HTML string
    private func getPDFData(for html:String,with cgRect:CGRect = CGRect(x: 0, y: 0, width: 900, height: 2700)) ->Data{
//        let html = "<b>Hello <i>World!</i></b>"
        let fmt =  UIMarkupTextPrintFormatter(markupText: html)

        // 2. Assign print formatter to UIPrintPageRenderer
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)

        // 3. Assign paperRect and printableRect
//        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        render.setValue(cgRect, forKey: "paperRect")
        render.setValue(cgRect, forKey: "printableRect")

        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)

        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage();
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext();
        // 5. Save PDF file
        
        return  Data(pdfData as Data)
       

    }
//    func pdfThumbnail(url: URL, width: CGFloat = 240) -> UIImage? {
    func imageForPDF(data: Data) -> UIImage? {

//      guard let data = try? Data(contentsOf: url),
      guard let page = PDFDocument(data: data)?.page(at: 0) else {
        return nil
      }

      let pageSize = page.bounds(for: .mediaBox)
//      let pdfScale = width / pageSize.width
        let pdfScale = UIScreen.main.scale

      // Apply if you're displaying the thumbnail on screen
      let scale = UIScreen.main.scale * pdfScale
      let screenSize = CGSize(width: pageSize.width * scale,
                              height: pageSize.height * scale)

      return page.thumbnail(of: screenSize, for: .mediaBox)
    }
}
