//
//  webViewController.swift
//  pos
//
//  Created by khaled on 10/1/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
//import WebKit

class webViewController: UIViewController {

//    var webView: WKWebView!

 
    var  title_top: String? = ""
    var  url: String? = ""
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    @IBOutlet var nav: ShadowView!
    @IBOutlet var wb: UIWebView!
    
   
    @IBOutlet var lblTitle: KLabel!
    
    
//    let cookie = HTTPCookie(properties: [
//        .domain: "gofekra.com",
//        .path: "/",
//        .name: "session_id",
//        .value: "6cc85b2ed66a0083252fba5f30494c1ed76ae996",
//        .expires: NSDate(timeIntervalSinceNow: 1579614561)
//        ])!
    
//    let cookieProperties: [HTTPCookiePropertyKey : Any] = [
//        .name : "session_id",
//        .value : "6cc85b2ed66a0083252fba5f30494c1ed76ae996",
//        .domain : "gofekra.com",
//        .path : "/",
//        .expires : Date().addingTimeInterval(1579614561)
//    ]
    
    
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
//        checkCookie();
        
  
        
        nav.isHidden = true
 
        lblTitle.text = title_top
 
        load_url()
        
    }
    
//    func checkCookie()
//    {
//        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url!)
//        HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: url)
//
//        if let cookie = HTTPCookie(properties: cookieProperties) {
//            HTTPCookieStorage.shared.setCookie(cookie)
//        }
//
//    }
    
    
    
    public func load_url()
    {
        let url_serv = URL (string: url!)
        
         let Cookie = api.get_Cookie()
         let cookieHeaderField = ["Set-Cookie": Cookie]
        
        
//        let cookieHeaderField = ["Set-Cookie": "session_id=6cc85b2ed66a0083252fba5f30494c1ed76ae996; path=/; domain=gofekra.com; HttpOnly; Expires=Tue, 21 Jan 2020 18:04:45 GMT;"] // Or ["Set-Cookie": "key=value, key2=value2"] for multiple cookies
//
        
        
        var requestObj = URLRequest(url: url_serv!)
        requestObj.httpShouldHandleCookies = true
        requestObj.allHTTPHeaderFields = cookieHeaderField
        
         wb.loadRequest(requestObj)
    }
    
 
 
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
