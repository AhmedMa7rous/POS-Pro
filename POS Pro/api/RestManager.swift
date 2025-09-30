//
//  RestManager.swift
//  RestManager
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation

class RestManager {
    
    // MARK: - Properties
    
    var requestHttpHeaders = RestEntity()
    
    var urlQueryParameters = RestEntity()
    
    var httpBodyParameters = RestEntity_body()
    
    var httpBody: Data?
 
    // MARK: - Public Methods
    
    func makeRequest(toURL url: URL,   withHttpMethod httpMethod: HttpMethod,timeout :TimeInterval ,  completion: @escaping (_ result: Results) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            let targetURL = self?.addURLQueryParameters(toURL: url)
            let httpBody = self?.getHttpBody()
            
            guard let request = self?.prepareRequest(withURL: targetURL, httpBody: httpBody, httpMethod: httpMethod,timeout: timeout) else
            {
                completion(Results(withError: CustomError.failedToCreateRequest))
                return
            }
            
            
            let session = URLSession.shared
            
         
//            if   timeout != 0
//            {
//                let sessionConfiguration = URLSessionConfiguration.default
//
//
//                sessionConfiguration.timeoutIntervalForRequest = TimeInterval( timeout)
//
//                // this code lake memory
////                sessionConfiguration.timeoutIntervalForResource = TimeInterval( timeout)
//                session = URLSession(configuration: sessionConfiguration)
//
//            }
 
 

            let time_start = Date.currentDateTimeMillis()

            let task = session.dataTask(with: request) { (data, response, error) in
                let time_end = Date.currentDateTimeMillis()

                let interval = time_end - time_start

                completion(Results(withData: data,
                                   response: Response(fromURLResponse: response),
                                   error: error,_interval:interval ))
            }
            task.resume()
        }
    }
    
    
    
    func getData(fromURL url: URL, completion: @escaping (_ data: Data?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let sessionConfiguration = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfiguration)
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                guard let data = data else { completion(nil); return }
                completion(data)
            })
            task.resume()
        }
    }
    
    
    
    // MARK: - Private Methods
    
    private func addURLQueryParameters(toURL url: URL) -> URL {
        if urlQueryParameters.totalItems() > 0 {
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
            var queryItems = [URLQueryItem]()
            for (key, value) in urlQueryParameters.allValues() {
                let item = URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                
                queryItems.append(item)
            }
            
            urlComponents.queryItems = queryItems
            
            guard let updatedURL = urlComponents.url else { return url }
            return updatedURL
        }
        
        return url
    }
    
    
    
    private func getHttpBody() -> Data? {
        guard let contentType = requestHttpHeaders.value(forKey: "Content-Type") else { return nil }
        
        if contentType.contains("application/json") {
//            return try? JSONSerialization.data(withJSONObject: httpBodyParameters.allValues(), options: [.prettyPrinted, .sortedKeys])
         return try? JSONSerialization.data(withJSONObject: httpBodyParameters.allValues(), options: [])
            
        } else if contentType.contains("application/x-www-form-urlencoded") {
            let bodyString = httpBodyParameters.allValues().map { "\($0)=\(String(describing: ($1 as AnyObject).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)))" }.joined(separator: "&")
            return bodyString.data(using: .utf8)
        } else {
            return httpBody
        }
    }
    
    
    
    private func prepareRequest(withURL url: URL?, httpBody: Data?, httpMethod: HttpMethod , timeout :TimeInterval ) -> URLRequest? {
        guard let url = url else { return nil }
        
 
        var request:URLRequest

        if timeout != 0
        {
            request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData ,timeoutInterval:  timeout)
        }
        else
        {
            request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData )
        }
        
        
        
        request.httpMethod = httpMethod.rawValue
        
        for (header, value) in requestHttpHeaders.allValues() {
            request.setValue(value, forHTTPHeaderField: header)
        }
        
        request.httpBody = httpBody
        return request
    }
}

