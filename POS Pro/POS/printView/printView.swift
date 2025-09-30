//
//  test_printer_image.swift
//  pos
//
//  Created by khaled on 11/8/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import WebKit

class printView: baseViewController //, WKNavigationDelegate
{

    @IBOutlet var photo: KSImageView?
    
    weak var delegatePrintView:printView_delegate?
    var webView: WKWebView!
    var webViewContentHeight:CGFloat? = 0.0
    @IBOutlet var viewWeb: UIView!
    
    var html:String = ""
    var order:pos_order_class?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        webView = WKWebView()
        webView.navigationDelegate = self
        let frm = self.viewWeb.bounds
 
        webView.frame = frm
 
        
         
        webView.loadHTMLString(html, baseURL: nil)
 
        webView.allowsBackForwardNavigationGestures = true
        
        viewWeb.addSubview(webView)

        NSLog("START PRINT ")
      
      */
 
    }

    
 
//    func webView(_ webView: WKWebView,
//                 didFinish navigation: WKNavigation!){
////       SharedManager.shared.printLog("loaded")
//
////         webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] (height, error) in
////                    self?.webViewContentHeight = (height as? CGFloat) ?? -1
////                })
////
////        let image = UIGraphicsImageRenderer(size: CGSize(width: webView.bounds.size.width, height: webViewContentHeight!)).image { [webView] context in
////            for offset in stride(from: 0, to: Int(webViewContentHeight!), by: Int(webView.bounds.size.height)) {
////                let drawPoint = CGPoint(x: 0, y: CGFloat(offset))
////                webView.scrollView.contentOffset = drawPoint
////                webView.drawHierarchy(in: CGRect.init(origin: drawPoint, size: webView.bounds.size), afterScreenUpdates: true)
////            }
////        }
//
////        let image = ta
////        photo.image = image
////         EposPrint.runPrinterReceipt(  logoData: image, openDeawer: false)
//
//
////        let snapshotConfiguration = WKSnapshotConfiguration()
////        snapshotConfiguration.snapshotWidth = 600
////
////
////        webView.takeSnapshot(with: snapshotConfiguration) { (image, error) in
////            //            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
////            self.photo.image = image
////            EposPrint.runPrinterReceipt(  logoData: self.photo.image , openDeawer: false)
////
////        }
////
//        if delegatePrintView != nil
//        {
//            delegatePrintView?.webpageLoaded()
//        }
//    }
    
    public func openDrawer()
    {
//        EposPrint.openDrawer_background()

    }
    
    @objc public func print()
    {
        
 
        DispatchQueue.global(qos: .background).async {
             
//                             EposPrint.runPrinterReceipt_image(  html: self.html, openDeawer: false)
                             
                         }
        
     }
    
    @objc public func print_openDrawer()
    {
//        webView.fullLengthScreenshot { (image) in
//            //            self.photo?.image = image
//            if image != nil
//            {
//                EposPrint.runPrinterReceipt(  logoData: image , openDeawer: true)
//                NSLog("END PRINT ")
//
//            }
//        }
        
                DispatchQueue.global(qos: .background).async {
             
//                             EposPrint.runPrinterReceipt_image(  html: self.html, openDeawer: true)
                             
                         }
        
        
    }
    
    func takeScreenshot() -> UIImage? {
        let currentSize = webView.frame.size
        let currentOffset = webView.scrollView.contentOffset
        let scrollSize =  webView.scrollView.contentSize
        
        webView.frame.size = scrollSize
        webView.scrollView.setContentOffset(CGPoint.zero, animated: false)
        
        let rect = CGRect(x: 0, y: 0, width: webView.bounds.size.width, height: webView.bounds.size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        webView.drawHierarchy(in: rect, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        webView.frame.size = currentSize
        webView.scrollView.setContentOffset(currentOffset, animated: false)
        
        return image
    }
    
}

protocol printView_delegate:class {
    func webpageLoaded()
    func screenShotLoaded()
}
