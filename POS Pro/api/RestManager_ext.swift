//
//  RestManager_ext.swift
//  pos
//
//  Created by khaled on 8/8/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation


// MARK: - RestManager Custom Types

  extension RestManager {
    enum HttpMethod: String {
        case get
        case post
        case put
        case patch
        case delete
    }
    
    
    
    public  struct RestEntity {
        private var values: [String: String] = [:]
        
        mutating func add(value: String, forKey key: String) {
            values[key] = value
        }
        
        mutating func set(params: [String: String]) {
            for (commingKey,commingValue) in params {
                if let currentValue =  value(forKey:commingKey) {
                    if currentValue != commingValue{
                        values[commingKey] = commingValue
                    }
                }else{
                    values[commingKey] = commingValue
                }

            }
        }
        
        func value(forKey key: String) -> String? {
            return values[key]
        }
        
        func allValues() -> [String: String] {
            return values
        }
        
        func totalItems() -> Int {
            return values.count
        }
    }
    
    struct RestEntity_body {
        private var values: [String: Any] = [:]
        
        
        mutating func set(params: [String: Any]) {
            values = params;
        }
        
        mutating func add(value: String, forKey key: String) {
            values[key] = value
        }
        
        func value(forKey key: String) -> Any? {
            return values[key]
        }
        
        func allValues() -> [String: Any] {
            return values
        }
        
        func totalItems() -> Int {
            return values.count
        }
    }
    
    
  public  struct Response {
        var response: URLResponse?
        var httpStatusCode: Int = 0
        var headers = RestEntity()
        
        init(fromURLResponse response: URLResponse?) {
            guard let response = response else { return }
            self.response = response
            httpStatusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            
            if let headerFields = (response as? HTTPURLResponse)?.allHeaderFields {
                for (key, value) in headerFields {
                    headers.add(value: "\(value)", forKey: "\(key)")
                }
            }
        }
    }
    
    
    
    struct Results {
        var data: Data?
        var response: Response?
        var error: Error?
        var response_time:Int64?
        
        init(withData data: Data?, response: Response?, error: Error?,_interval:Int64?) {
            self.data = data
            self.response = response
            self.error = error
            self.response_time = _interval
        }
        
        init(withError error: Error) {
            self.error = error
        }
    }
    
    
    
    enum CustomError: Error {
        case failedToCreateRequest
    }
}


// MARK: - Custom Error Description
extension RestManager.CustomError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .failedToCreateRequest: return NSLocalizedString("Unable to create the URLRequest object", comment: "")
        }
    }
}
