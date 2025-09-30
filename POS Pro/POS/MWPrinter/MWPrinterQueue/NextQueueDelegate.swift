//
//  NextQueueDelegate.swift
//  pos
//
//  Created by M-Wageh on 12/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
 protocol NextQueueDelegate{
   func next()
 func getNextItem() -> MWFileInQueue?
}
protocol NextMessageQueueDelegate{
    func next(with previousSucess:Bool)
}
extension NextQueueDelegate {
    func getNextItem() -> MWFileInQueue?{
        return nil
    }
}
