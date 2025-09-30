//
//  Bundle+ext.swift
//  pos
//
//  Created by Khaled on 10/1/20.
//  Copyright © 2020 khaled. All rights reserved.
//
 // Bundle.main.fullVersion
import Foundation

extension Bundle {

 public var shortVersion: String {
        if let result = infoDictionary?["CFBundleShortVersionString"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }

    public var buildVersion: String {
        if let result = infoDictionary?["CFBundleVersion"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }

    public var fullVersion: String {
        return "V\(shortVersion)(\(buildVersion))"
    }
}
