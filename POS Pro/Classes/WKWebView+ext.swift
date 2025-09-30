//
//  WKWebView+ext.swift
//  pos
//
//  Created by khaled on 11/9/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView{
    
    private func stageWebViewForScreenshot() {
        let _scrollView = self.scrollView
        let pageSize = _scrollView.contentSize;
        let currentOffset = _scrollView.contentOffset
        let horizontalLimit = CGFloat(ceil(pageSize.width/_scrollView.frame.size.width))
        let verticalLimit = CGFloat(ceil(pageSize.height/_scrollView.frame.size.height))
        
        for i in stride(from: 0, to: verticalLimit, by: 1.0) {
            for j in stride(from: 0, to: horizontalLimit, by: 1.0) {
                _scrollView.scrollRectToVisible(CGRect(x: _scrollView.frame.size.width * j, y: _scrollView.frame.size.height * i, width: _scrollView.frame.size.width, height: _scrollView.frame.size.height), animated: true)
                RunLoop.main.run(until: Date.init(timeIntervalSinceNow: 1.0))
            }
        }
        _scrollView.setContentOffset(currentOffset, animated: false)
    }
    
    func fullLengthScreenshot_old(_ completionBlock: ((UIImage?) -> Void)?) {
        // First stage the web view so that all resources are downloaded.
//        stageWebViewForScreenshot()
        
        let _scrollView = self.scrollView
        
        // Save the current bounds
        let tmp = self.bounds
        let tmpFrame = self.frame
        let currentOffset = _scrollView.contentOffset
        
        // Leave main thread alone for some time to let WKWebview render its contents / run its JS to load stuffs.
        //        mainDispatchAfter(2.0) {
        // Re evaluate the size of the webview
        let pageSize = _scrollView.contentSize
        UIGraphicsBeginImageContext(pageSize)
        
        self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: pageSize.width, height: pageSize.height)
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: pageSize.width, height: pageSize.height)
        
        // Wait few seconds until the resources are loaded
        RunLoop.main.run(until: Date.init(timeIntervalSinceNow: 0.5))
        
        var  image: UIImage? = nil
        let gr =   UIGraphicsGetCurrentContext()
        if gr != nil
        {
            self.layer.render(in: gr!)
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
       
        
        // reset Frame of view to origin
        self.bounds = tmp
        self.frame = tmpFrame
        _scrollView.setContentOffset(currentOffset, animated: false)
        
        completionBlock?(image)
        //        }
    }
    
    
    public func fullLengthScreenshot(_ completion: @escaping ((UIImage?) -> Void)) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            let renderer = WebViewPrintPageRenderer.init(formatter: self.viewPrintFormatter(), contentSize: self.scrollView.contentSize)
            let image = renderer.printContentToImage()
            completion(image)
        }
    }
}



internal final class WebViewPrintPageRenderer: UIPrintPageRenderer {
    
    private var formatter: UIPrintFormatter
    
    private var contentSize: CGSize
    
    /// Generate PrintPageRenderer instance
    ///
    /// - Parameters:
    ///- formatter: ViewPrintFormatter of WebView
    ///- contentSize: ContentSize of WebView
    required init(formatter: UIPrintFormatter, contentSize: CGSize) {
        self.formatter = formatter
        self.contentSize = contentSize
        super.init()
        self.addPrintFormatter(formatter, startingAtPageAt: 0)
    }
    
    override var paperRect: CGRect {
        return CGRect.init(origin: .zero, size: contentSize)
    }
    
    override var printableRect: CGRect {
        return CGRect.init(origin: .zero, size: contentSize)
    }
    
    private func printContentToPDFPage() -> CGPDFPage? {
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, self.paperRect, nil)
        self.prepare(forDrawingPages: NSMakeRange(0, 1))
        let bounds = UIGraphicsGetPDFContextBounds()
        UIGraphicsBeginPDFPage()
        self.drawPage(at: 0, in: bounds)
        UIGraphicsEndPDFContext()
        
        let cfData = data as CFData
        guard let provider = CGDataProvider.init(data: cfData) else {
            return nil
        }
        let pdfDocument = CGPDFDocument.init(provider)
        let pdfPage = pdfDocument?.page(at: 1)
        
        
        guard let outputURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("print").appendingPathExtension("pdf")
                           else { fatalError("Destination URL not created") }
        
        try? data.write(to: outputURL)
           
        
        return pdfPage
    }
    
    private func covertPDFPageToImage(_ pdfPage: CGPDFPage) -> UIImage? {
        let pageRect = pdfPage.getBoxRect(.trimBox)
        let contentSize = CGSize.init(width: floor(pageRect.size.width), height: floor(pageRect.size.height))
        
        // usually you want UIGraphicsBeginImageContextWithOptions last parameter to be 0.0 as this will us the device's scale
        UIGraphicsBeginImageContextWithOptions(contentSize, true, 2.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.fill(pageRect)
        
        context.saveGState()
        context.translateBy(x: 0, y: contentSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.interpolationQuality = .low
        context.setRenderingIntent(.defaultIntent)
        context.drawPDFPage(pdfPage)
        context.restoreGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// print the full content of webview into one image
    ///
    /// - Important: if the size of content is very large, then the size of image will be also very large
    /// - Returns: UIImage?
    internal func printContentToImage() -> UIImage? {
        guard let pdfPage = self.printContentToPDFPage() else {
            return nil
        }
         
        
        let image = self.covertPDFPageToImage(pdfPage)
        
        
        guard let outputURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("print").appendingPathExtension("png")
                    else { fatalError("Destination URL not created") }
                
        if image != nil
        {
            if let data = image?.pngData() {
                    
                    try? data.write(to: outputURL)
                }
        }

        
        
        return image
    }
}

extension UIWebView {
    public func takeScreenshotOfFullContent(_ completion: @escaping ((UIImage?) -> Void)) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            let renderer = WebViewPrintPageRenderer.init(formatter: self.viewPrintFormatter(), contentSize: self.scrollView.contentSize)
            let image = renderer.printContentToImage()
            completion(image)
        }
    }
}

