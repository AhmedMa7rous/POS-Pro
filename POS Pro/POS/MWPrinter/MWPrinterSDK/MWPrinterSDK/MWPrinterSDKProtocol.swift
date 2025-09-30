//
//  MWPrinterSDKProtocol.swift
//  pos
//
//  Created by M-Wageh on 07/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
protocol MWPrinterSDKProtocol{
    func connect(with ip:String,
                 success:@escaping () -> Void,
                 failure:@escaping (String) -> Void,
                 receiveData:@escaping (Data?) -> Void
    )
    func statusPrinter(success:@escaping () -> Void,
                       failure:@escaping (String) -> Void)
    func startPrint(image:UIImage?,openDrawer:Bool,sendFailure: ((String) -> Void)? )
    func handlerSendToPrinter(sendSuccess:@escaping () -> Void,
                              sendFailure:@escaping (String) -> Void,
                              sendProgressUpdate:((Double?) -> Void)?,
                              receiveData:((Data?) -> Void)?,
                              printSuccess:@escaping () -> Void)
    
    func disConnect()
    func openDrawer(completeHandler: @escaping (Bool) -> Void)

}
