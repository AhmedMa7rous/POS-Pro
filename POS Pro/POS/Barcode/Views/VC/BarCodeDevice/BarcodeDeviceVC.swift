//
//  BarcodeDeviceVC.swift
//  pos
//
//  Created by M-Wageh on 15/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit


import CoreBluetooth
class BarcodeDeviceVC: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var statusStack: UIStackView!
    @IBOutlet weak var statusLbl: KLabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var AddRemoveBtn: KButton!
    
    
    @IBOutlet weak var exampleBtn: UIButton!
    var router:BarcodeDeviceRouter?
    var setting: settingClass?
    var barcodeDeviceInteractor:BarcodeDeviceInteractor?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        exampleBtn.isHidden = true
        setupTable()
        initalAddRemoveBtn()

    }

    @IBAction func tapOnExample(_ sender: UIButton) {
//        _ = CBCentralManager(delegate: nil, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:true])

        let storyboard = UIStoryboard(name: "ExampleBarCode", bundle: nil)

        if let vc = storyboard.instantiateInitialViewController(){
            self.present(vc, animated: true, completion: nil)
        }

        
    }
    @IBAction func tapOnAddRemoveBtn(_ sender: UIButton) {
        if sender.tag == 0 {
           
            if let vc =  router?.setupVC(){
            vc.delegate = self
            self.addChildViewControllerWithView(vc)
                vc.didMove(toParent: self)

            }

        }else{
            barcodeDeviceInteractor?.removeDevice()
            initalAddRemoveBtn()
            self.table.reloadData()
        }
    }
    func initalAddRemoveBtn(){
        if !(self.barcodeDeviceInteractor?.isBleDeviceConntect() ?? false){
            AddRemoveBtn.tag = 0
            AddRemoveBtn.setTitle("Add new Device".arabic("اضافة جهاز جديد"), for: .normal)
        }else{
            AddRemoveBtn.tag = 1
            AddRemoveBtn.setTitle("Remove Device".arabic("حذف الجهاز"), for: .normal)

        }
    }
    

}


extension BarcodeDeviceVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.barcodeDeviceInteractor?.getCountInfoRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: InfoDeviceCell! = tableView.dequeueReusableCell(withIdentifier: "InfoDeviceCell") as? InfoDeviceCell
        cell.bind(with : "", value: "")
        if let info_dic = self.barcodeDeviceInteractor?.getInfo(at: indexPath.row){
            cell.bind(with :info_dic.keys.first ?? "", value:info_dic.values.first ?? "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      return
    }
    func setupTable(){
        if !(self.barcodeDeviceInteractor?.isBleDeviceConntect() ?? false){
            table.isHidden = true
          return
        }
        table.isHidden = false
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
       //        refreshControl.addTarget(self, action: #selector(refreshStoredItemTable), for: .valueChanged)
       //        StoredItemTable.addSubview(refreshControl)
        table.register(UINib(nibName: "InfoDeviceCell", bundle: nil), forCellReuseIdentifier: "InfoDeviceCell")

    }
   
    
}
extension BarcodeDeviceVC:SetupBarcodeScannerVCDelegate{
    func setupDidFinish(_ vc: SetupBarcodeScannerVC) {
        self.barcodeDeviceInteractor?.saveDeviceConnect()
        UIView.transition(with: self.view, duration: 1, options: .transitionCrossDissolve, animations: {
          vc.view.removeFromSuperview()
          let viewControllerToBePresented = UIViewController()
          self.view.addSubview(viewControllerToBePresented.view)
        }, completion: nil)
    }
    
    
}

