////
////  ClientAPI.swift
////  pos
////
////  Created by khaled on 8/6/19.
////  Copyright © 2019 khaled. All rights reserved.
////
//
//import Foundation
//
//
//class ClientAPI {
//
//    func login(email: String, password: String, completion: (_ success: Bool, _ message: String?) -> ()) {
//        let loginObject = ["email": email, "password": password]
//
//        post(request: clientURLRequest(path: "auth/local", params: loginObject as Dictionary<String, AnyObject>)) { (success, object) -> () in
//
////            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                if success {
//                    completion( true, nil)
//                } else {
//                    var message = "there was an error"
//                    if let object = object, let passedMessage = object["message"] as? String {
//                        message = passedMessage
//                    }
//                    completion(true, message)
//                }
////            })
//        }
//    }
//
//    // MARK: private composition methods
//
//    private func post(request: NSMutableURLRequest, completion: (_ success: Bool, _ object: AnyObject?) -> ()) {
//        dataTask(request: request, method: "POST", completion: completion)
//    }
//
//    private func put(request: NSMutableURLRequest, completion: (_ success: Bool, _ object: AnyObject?) -> ()) {
//        dataTask(request: request, method: "PUT", completion: completion)
//    }
//
//    private func get(request: NSMutableURLRequest, completion: (_ success: Bool, _ object: AnyObject?) -> ()) {
//        dataTask(request: request, method: "GET", completion: completion)
//    }
//
//    private func dataTask(request: NSMutableURLRequest, method: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
//        request.httpMethod = method
//
//        let session = URLSession(configuration: URLSessionConfiguration.default)
//
//        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
//            if let data = data {
//                let json = try? JSONSerialization.JSONObjectWithData(data, options: [])
//                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
//                    completion(success: true, object: json)
//                } else {
//                    completion(success: false, object: json)
//                }
//            }
//            }.resume()
//    }
//
//    private func clientURLRequest(path: String, params: Dictionary<String, AnyObject>? = nil) -> NSMutableURLRequest {
//        let request = NSMutableURLRequest(url: NSURL(string: "http://api.example.com/"+path)! as URL)
//        if let params = params {
//            var paramString = ""
//            for (key, value) in params {
//                let escapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
//                let escapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
//                paramString += "\(escapedKey)=\(escapedValue)&"
//            }
//
//            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//            request.HTTPBody = paramString.data(usingEncoding: NSUTF8StringEncoding)
//        }
//
//        return request
//    }
//}
//
////let client = ClientAPI()
////client.login("name@example.com", password: "password") { (success, message) -> () in
////    if success {
////       SharedManager.shared.printLog("logged in successfully!")
////    } else {
////       SharedManager.shared.printLog("there was an error:", message)
////    }
////
////}
