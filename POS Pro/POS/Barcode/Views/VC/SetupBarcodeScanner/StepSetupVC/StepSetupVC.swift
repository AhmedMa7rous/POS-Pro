//
//  StepSetupVC.swift
//  pos
//
//  Created by M-Wageh on 16/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class StepSetupVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var stepTitleLbl: UILabel!
    @IBOutlet weak var stepDescLbl: UILabel!
    @IBOutlet weak var viewStep: UIView!
    lazy var mainTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .singleLine
        table.allowsSelection = true
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 80
        table.rowHeight = UITableView.automaticDimension

//        table.tableFooterView = UIView()
        return table
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: stepModel.icon ))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView

    }()

    
    let stepModel:StepSetupModel
    var barcodeDeviceInteractor:BarcodeDeviceInteractor?

    init(model: StepSetupModel,
         barcodeDeviceInteractor:BarcodeDeviceInteractor?,
         nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?) {
      self.stepModel = model
    self.barcodeDeviceInteractor = barcodeDeviceInteractor
      super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if self.stepModel.type == .table{
            fetchAvaliableDevices()
        }
    }
    func setupUI() {
        if  self.stepModel.type == .table {
            addConstraints(for:mainTableView)
        }
        if  self.stepModel.type == .image {
            imageAdjust()
        }
        self.stepTitleLbl.text = self.stepModel.title
        self.stepDescLbl.text = self.stepModel.subtitle

    }
    func addConstraints(for view:UIView){
        viewStep.addSubview(view)
        let constraints = [
            view.topAnchor.constraint(equalTo: viewStep.topAnchor,constant:50),
            view.leadingAnchor.constraint(equalTo: viewStep.leadingAnchor,constant:50),
            view.trailingAnchor.constraint(equalTo: viewStep.trailingAnchor,constant:-50),
            view.bottomAnchor.constraint(equalTo: viewStep.bottomAnchor,constant:50),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    func imageAdjust(){
        if stepModel.icon.contains("MFI-socket-barcode"){
            viewStep.addSubview(imageView)
            imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 400).isActive = true
            imageView.centerXAnchor.constraint(equalTo:viewStep.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo:viewStep.centerYAnchor).isActive = true
        }else{
            addConstraints(for:imageView)
        }

    }
    
    func fetchAvaliableDevices(){
        
    }


}
extension StepSetupVC : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return barcodeDeviceInteractor?.getCountDiscoverDevices() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

            if cell == nil {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Cell")
            }
        cell?.textLabel?.font = UIFont(name: (cell?.textLabel?.font.fontName)!, size: 26)
        cell?.textLabel?.text = self.barcodeDeviceInteractor?.getDeviceNameFor(indexPath) ?? ""
        cell?.selectionStyle = .blue

        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        barcodeDeviceInteractor?.didSelectDeviceAt(index: indexPath )

    }
}

