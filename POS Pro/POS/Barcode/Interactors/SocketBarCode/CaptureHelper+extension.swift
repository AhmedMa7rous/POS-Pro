//
//  CaptureHelper+extension.swift
//  pos
//
//  Created by M-Wageh on 16/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//
/*
import Foundation
import SKTCapture

extension CaptureHelper
{
    // this makes the scanner vibrate if vibrate mode is supported by the scanner
    func setDataConfirmationOkDevice(_ device: CaptureHelperDevice, withCompletionHandler completion: @escaping(_ result: SKTResult)->Void){
        // the Capture API requires to create a property object
        // that should be initialized accordingly to the property ID
        // that we are trying to set (or get)
        let property = SKTCaptureProperty()
        property.id = .dataConfirmationDevice
        property.type = .ulong
        property.uLongValue = UInt(SKTHelper.getDataComfirmation(withReserve: 0, withRumble: Int(SKTCaptureDataConfirmationRumble.good.rawValue), withBeep: Int(SKTCaptureDataConfirmationBeep.good.rawValue), withLed: Int(SKTCaptureDataConfirmationLed.green.rawValue)))
        
        // make sure we have a valid reference to the Capture API
        if let capture = captureApi {
            capture.setProperty(property, completionHandler: {(result, propertyResult)  in
                completion(result)
            })
        } else {
            // if the Capture API is not valid often because
            // capture hasn't be opened
            completion(SKTCaptureErrors.E_INVALIDHANDLE)
        }
    }
}
*/
