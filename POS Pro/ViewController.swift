//
//  ViewController.swift
//  pos
//
//  Created by khaled on 7/22/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import WebKit


class ViewController: UIViewController,WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate,UIScrollViewDelegate ,
UIWebViewDelegate {
    
    @IBOutlet weak var OutWebViewContainer: UIView!
    @IBOutlet   var OutWebView: WKWebView!
    
    @IBOutlet var errorView: UIView!
    var  Epos  : Epos2Class?
    var activityIndicator: UIActivityIndicatorView!


  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
         initWeb()
        initPrinter()
        

       
 
    }
    
    func initPrinter()
    {
        let setting =  settingClass.getSetting()
        
        Epos = Epos2Class(IP: setting.ip)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        initSlideBar()
    }

   func initSlideBar()
   {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.MainView = self
    if (appDelegate.settingTheSideMenu == false)
    {
        appDelegate.settingTheSideMenu = true
 
 
    }
    

    
    }
    
    
    func initWeb()
    {
        let config = WKWebViewConfiguration()
        
        config.userContentController.add(self, name: "iosprint")
        
        
        self.OutWebView = WKWebView(frame: OutWebViewContainer.bounds, configuration: config)
        
  
        self.OutWebView.translatesAutoresizingMaskIntoConstraints = false
        self.OutWebView.uiDelegate = self
        self.OutWebView.navigationDelegate = self
        self.OutWebView.scrollView.delegate = self
       self.OutWebView.autoresizingMask = [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
//        self.OutWebView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
//        self.OutWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)

        
        OutWebViewContainer.addSubview(self.OutWebView)
        
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = OutWebViewContainer.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.color = UIColor(hexString: "#DB0AEA")
        
        self.view.addSubview(activityIndicator)
        
        
        
        
        loadWebView()
       
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
         self.OutWebView.scrollView.addSubview(refreshControl)
         self.OutWebView.scrollView.bounces = true
    }
    
    
    @IBAction func btnReload(_ sender: Any) {
        loadWebView()
    }
    
    func loadWebView()
    {
     //   if checkConnection(sender: self)
       // {
            let setting =  settingClass.getSetting()
            let fekraurl:URL=URL.init(string:setting.url!)!
            let url:URLRequest = URLRequest.init(url: fekraurl)
            
//            let isCacheLoad:Bool = true
//            let request = URLRequest(url: fekraurl, cachePolicy: (isCacheLoad ? .returnCacheDataElseLoad: .reloadRevalidatingCacheData), timeoutInterval: 50)

            OutWebView.load(url)
       // }
        
    }
    
    @objc
    func refreshWebView(_ sender: UIRefreshControl) {
//         self.OutWebView?.reload()
        
           loadWebView()
          initPrinter()
        
        sender.endRefreshing()
    }
    
    
    func checkConnection(sender:UIViewController)->Bool{
        if NetworkConnection.isConnectedToNetwork() == true {
            print("Connected to the internet")
            //  Do something
            // ConnectionGood = true
            // self.LblError.isHidden = true
            // self.LblError.text = ""
            return true
        } else {
            print("No internet connection")
            //  self.LblError.isHidden = false
            // self.LblError.text = " يرجى الإتصال بالإنترنت لتحميل إدارة الكتب"
            let alertController = UIAlertController(title:  "Rabeh", message: "Error in Internet Connection", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default){(result:UIAlertAction) -> Void in
                return
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            //  Do something
            // ConnectionGood = false
            return false
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url) {
            print("### URL:", self.OutWebView.url!)
        }
        
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            // When page load finishes. Should work on each page reload.
            if (self.OutWebView.estimatedProgress == 1) {
                print("### EP:", self.OutWebView.estimatedProgress)
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "iosprint"){
            print("\(message.body)")
            
           let html_Details = String(describing: message.body )
            
            _ = Epos?.runPrinterReceiptSequence(html_Details: html_Details)
           // PrintPage()
        }
    }
    
   
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if let response = navigationResponse.response as? HTTPURLResponse {
              print("response : \(response.statusCode )" )
            if response.statusCode == 404 {
                // ...
                errorView.isHidden = false
                OutWebViewContainer.isHidden = true
                
            }
            else
            {
                errorView.isHidden = true
                OutWebViewContainer.isHidden = false
            }
            
        }
        
        let url = webView.url!.absoluteString
        
        print("url : \(url)" )
        decisionHandler(.allow)
    }
    
 
    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
          activityIndicator.stopAnimating()
        }
    }
    
 
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(show: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }
 
  
}

