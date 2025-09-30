//
//  MWQueueForFiles.swift
//  pos
//
//  Created by M-Wageh on 12/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
//MARK: - MWQueueForFiles
class MWQueueForFiles:NextQueueDelegate{
//    var status:MWQueue_Status
    var FilesQueue:[MWFileInQueue]
    var CurrentFilesQueue:MWFileInQueue?
    var delegate:NextQueueDelegate?

    init() {
        self.FilesQueue = []
//        status = .NONE
    }
    func getTargetPrinters() -> [restaurant_printer_class?]{
        return self.FilesQueue.map({$0.restaurantPrinter})
    }
    func splitFilesStuck(for ip:String) -> (splitQueueFiles:MWQueueForFiles?,originQueueFiles:MWQueueForFiles?){
        if !ip.isEmpty{
           let filesQueue =  FilesQueue.filter({($0.restaurantPrinter?.printer_ip ?? "") == ip })
            if filesQueue.count > 0{
                FilesQueue.removeAll(where: {($0.restaurantPrinter?.printer_ip ?? "") == ip })
                let queueFileSplit = MWQueueForFiles()
                queueFileSplit.addAll(filesQueue)
                if FilesQueue.count > 0 {
                    return (queueFileSplit,self )
                }
                return (queueFileSplit,nil )

            }
        }
        return (nil,self)
    }
    func deAllocate(){
        FilesQueue.forEach { filesQueue in
            filesQueue.deAllocate()
        }
        FilesQueue.removeAll()
        CurrentFilesQueue = nil
        delegate = nil
    }
    func addAll(_ files:[MWFileInQueue]){
        FilesQueue.append(contentsOf: files)
    }
    func add(_ file:MWFileInQueue){
        FilesQueue.append(file)
    }
   
    func start(){
//        if case MWQueue_Status.START = status {
//            return
//        }
        if FilesQueue.count > 0 {
//            status = .START
            CurrentFilesQueue = FilesQueue.first
            CurrentFilesQueue?.delegate = self
            CurrentFilesQueue?.start()
        }
    }
    func stopCurrent(with status:MWQueue_Status ){
        CurrentFilesQueue?.stop(with: status)
    }
    func stopAll(with status:MWQueue_Status ){
        FilesQueue.forEach { fileQueue in
            fileQueue.stop(with: status)
        }
    }
    func next(){
//        status = .NONE
     //   DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .milliseconds(200), execute: {
            if self.FilesQueue.count > 0{
                if self.FilesQueue.count == 1 {
                    self.FilesQueue.first?.deAllocate()
                    self.FilesQueue.removeAll()
                    self.delegate?.next()
            }else{
                self.FilesQueue.first?.deAllocate()
                self.FilesQueue.remove(at: 0)
                if self.FilesQueue.count > 0{
                    self.start()
            }else{
                self.delegate?.next()
            }
            }
        }else{
            self.delegate?.next()
        }
       // })
    }

    func getNextItem() -> MWFileInQueue? {
        if self.FilesQueue.count > 1{
            self.FilesQueue.first?.deAllocate()
            self.FilesQueue.remove(at: 0)
            if self.FilesQueue.count > 0{
                self.CurrentFilesQueue = self.FilesQueue.first
                CurrentFilesQueue?.delegate = self
                return self.CurrentFilesQueue
        }
        }
        return nil
    }

}
