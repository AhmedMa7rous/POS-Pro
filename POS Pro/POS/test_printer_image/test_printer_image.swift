//
//  test_printer_image.swift
//  pos
//
//  Created by khaled on 11/8/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import WebKit

class test_printer_image: UIViewController , WKNavigationDelegate{

    @IBOutlet var photo: KSImageView!
    var webView: WKWebView!
    var webViewContentHeight:CGFloat? = 0.0
    @IBOutlet var viewWeb: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.navigationDelegate = self
        var frm = self.viewWeb.frame
 frm.size.width = 900
        webView.frame = frm
        //        view = webView
        
        
        //load HTML
        let bundle = Bundle.main
        var path = bundle.bundlePath
        path = bundle.path(forResource: "index", ofType: "html" )!
        var html = ""
        do {
            try html = String(contentsOfFile: path, encoding: .utf8)
        } catch {
            //ERROR
        }
//        let urlstr = "http://website.com"
        webView.loadHTMLString(html, baseURL: nil)
        
//        let url = URL(string: "https://www.hackingwithswift.com")!
//        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        viewWeb.addSubview(webView)

      
//        let receipt = #imageLiteral(resourceName: "receipt.jpg")
//        EposPrint.runPrinterReceipt(  logoData: receipt , openDeawer: false)

        

        
       
        
    }

   
 
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!){
       SharedManager.shared.printLog("loaded")
        
//         webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] (height, error) in
//                    self?.webViewContentHeight = (height as? CGFloat) ?? -1
//                })
//
//        let image = UIGraphicsImageRenderer(size: CGSize(width: webView.bounds.size.width, height: webViewContentHeight!)).image { [webView] context in
//            for offset in stride(from: 0, to: Int(webViewContentHeight!), by: Int(webView.bounds.size.height)) {
//                let drawPoint = CGPoint(x: 0, y: CGFloat(offset))
//                webView.scrollView.contentOffset = drawPoint
//                webView.drawHierarchy(in: CGRect.init(origin: drawPoint, size: webView.bounds.size), afterScreenUpdates: true)
//            }
//        }

//        let image = ta
//        photo.image = image
//         EposPrint.runPrinterReceipt(  logoData: image, openDeawer: false)
        
        
//        let snapshotConfiguration = WKSnapshotConfiguration()
//        snapshotConfiguration.snapshotWidth = 600
//
//
//        webView.takeSnapshot(with: snapshotConfiguration) { (image, error) in
//            //            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
//            self.photo.image = image
//            EposPrint.runPrinterReceipt(  logoData: self.photo.image , openDeawer: false)
//
//        }
//
//        webView.fullLengthScreenshot { (image) in
//             self.photo.image = image
////             EposPrint.runPrinterReceipt(  logoData: self.photo.image , openDeawer: false)
//        }
        
    }
    
    func takeScreenshot() -> UIImage? {
        let currentSize = webView.frame.size
        let currentOffset = webView.scrollView.contentOffset
        
        webView.frame.size = webView.scrollView.contentSize
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
