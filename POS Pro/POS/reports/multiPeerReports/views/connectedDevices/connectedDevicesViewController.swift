//
//  connectedDevicesViewController.swift
//  pos
//
//  Created by khaled on 04/04/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class connectedDevicesViewController: UIViewController  , UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tableview: UITableView!

    var connectedPeers: [MCPeerID] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.preferredContentSize = CGSize.init(width: 414, height: 700)
        
        let peer = SharedManager.shared.multipeerSession()
        if peer != nil
        {
            connectedPeers = peer!.mcSession.connectedPeers
            
        }
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  connectedPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell: devicesTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? devicesTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "devicesTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? devicesTableViewCell
        }
        
        
        let peer =  connectedPeers[indexPath.row]
        
        cell.lblTitle.text = peer.displayName
        
        
        
        
        
        return cell
    }
    

 
}
