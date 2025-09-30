//
//  MessageIpErrorVC.swift
//  pos
//
//  Created by M-Wageh on 21/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class MessageIpErrorVC: UIViewController {

    @IBOutlet weak var messageTable: UITableView!
    var completeHandler:(()->Void)?
    var messageIpErrorVM:MessageIpErrorVM?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        self.messageIpErrorVM?.loadData {
            DispatchQueue.main.async {
                self.messageTable.reloadData()
            }
        }
    }

    
    @IBAction func tapOnClearAll(_ sender: Any) {
        messageIpErrorVM?.removeAllFailureMessage()
        self.dismiss(animated: true,completion: self.completeHandler)
    }
    static func createModule(_ sender:UIView?) -> MessageIpErrorVC {
        let vc:MessageIpErrorVC = MessageIpErrorVC()
        vc.messageIpErrorVM = MessageIpErrorVM()
        if let sender = sender{
            vc.modalPresentationStyle = .popover
            vc.preferredContentSize = CGSize(width: 800, height: 500)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }

}

extension MessageIpErrorVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
        messageTable.delegate = self
        messageTable.dataSource = self
        messageTable.rowHeight = UITableView.automaticDimension
        messageTable.estimatedRowHeight = 80
        messageTable.register(UINib(nibName: "MessageIpErrorCell", bundle: nil), forCellReuseIdentifier: "MessageIpErrorCell")
    }

    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return  messageIpErrorVM?.getCountFailureMessage() ?? 0
           
    }
    
   
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageIpErrorCell", for: indexPath) as! MessageIpErrorCell
        // Configure the cell...
         if  let failureMessage = messageIpErrorVM?.getFailureMessage(at: indexPath.row){
             cell.resendBtn.tag = indexPath.row
             cell.removeMessageBtn.tag = indexPath.row
             cell.resendBtn.addTarget(self, action: #selector(resendMessage(_:)), for: .touchUpInside)
             cell.removeMessageBtn.addTarget(self, action: #selector(removeFailureMessage(_:)), for: .touchUpInside)
             cell.resendBtn.isHidden = SharedManager.shared.appSetting().enable_resent_failure_ip_kds_order_automatic
             cell.titleMessageLbl.text = failureMessage.getBodyMessage()?.getTitleMessage() ?? ""

         }
        
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

    }
    
    @objc func resendMessage(_ sender:UIButton){
        messageIpErrorVM?.resendFailureMessage(at: sender.tag)
        messageIpErrorVM?.removeFailureMessage(at: sender.tag)
        self.messageTable.reloadData()
        self.dismiss(animated: true,completion: self.completeHandler)
    }
    @objc func removeFailureMessage(_ sender:UIButton){
        messageIpErrorVM?.removeFailureMessage(at: sender.tag)
        if (messageIpErrorVM?.getCountFailureMessage() ?? 0) <= 0 {
             self.dismiss(animated: true,completion: self.completeHandler)
        }else{
            self.messageTable.reloadData()
        }
    }

    
}

class MessageIpErrorVM{
    var failureMessages:[messages_ip_queue_class] = []
    let mwMessageQueueRun =  MWMessageQueueRun.shared
    init(){
        
    }
    func loadData(completeHandler:@escaping()->()){
        MWQueue.shared.mwfillFailureQueueMessages.async {
            let fetchData = messages_ip_queue_class.getAll(for: [.FALIURE],ipMessage: IP_MESSAGE_TYPES.workMessages())
            self.failureMessages.append(contentsOf: fetchData )
            completeHandler()
        }

    }
    func getFailureMessage(at index:Int) -> messages_ip_queue_class?{
        if failureMessages.count <= 0 {
            return nil
        }
        return failureMessages[index]
    }
    func removeFailureMessage(at index:Int){
        if getCountFailureMessage() > 0 {
            let messageQueuIpID = failureMessages[index].id
            MWQueue.shared.mwfillFailureQueueMessages.async {
                messages_ip_queue_class.setQueueType(with: .DELETED, for: [messageQueuIpID])
                SharedManager.shared.updateMessagesIpBadge()
            }
            failureMessages.remove(at: index)
        }
    }
    func removeAllFailureMessage(){
        if getCountFailureMessage() > 0 {
            MWQueue.shared.mwfillFailureQueueMessages.async {
                messages_ip_queue_class.updateQueueType(for: [.FALIURE], with: .DELETED)
                SharedManager.shared.updateMessagesIpBadge()
            }
            failureMessages.removeAll()
        }
    }
    func resendFailureMessage(at index:Int){
        if getCountFailureMessage() > 0 {
            mwMessageQueueRun.addToQueu( ipQueuMessages: [failureMessages[index]] )
            mwMessageQueueRun.startMWMessageQueue()
        }
    }
    func getCountFailureMessage() -> Int{
        return failureMessages.count
    }
}
