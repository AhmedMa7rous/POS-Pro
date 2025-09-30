//
//  StorableUOMInteractor.swift
//  pos
//
//  Created by M-Wageh on 27/02/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class StorableUOMInteractor {
    
    static let shared = StorableUOMInteractor()
    private var optionMenu:UIAlertController?
    private init(){}
    func getUOM(sender:UIView,productID:Int,defaultUOM:Int,action:@escaping (UOMStrobleProduct)->(),completion:@escaping (UIAlertController?)->()){
        self.getUOMStorableAPI(productID) { result in
            self.optionMenu = nil
            if let uomList = result {
                self.creatActionSheet(sender: sender,defaultUOM:defaultUOM, with: uomList, action: action)
            }
            completion(self.optionMenu)
        }
    }
    private func creatActionSheet(sender:UIView,defaultUOM:Int, with uomList:[UOMStrobleProduct],action:@escaping (UOMStrobleProduct)->() ){
        optionMenu = nil

        if uomList.count > 0 {
        optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        optionMenu?.view.tintColor =  #colorLiteral(red: 0.3650116324, green: 0.1732142568, blue: 0.5585888624, alpha: 1)
        uomList.forEach { uomItem in
            let option = createUIAlertAction(with:uomItem ,isSelet: (uomItem.id ?? 0) == defaultUOM, action:action )
            optionMenu?.addAction(option)

        }
//            let cancel = createUIAlertAction(with:"Cancel" ,style: .cancel,action:{
//
//            })
//            optionMenu?.addAction(cancel)
            guard let optionMenu = optionMenu else {return}
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad )
            {
                if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController{
                    currentPopoverpresentioncontroller.sourceView =  sender
                    currentPopoverpresentioncontroller.sourceRect =  sender.bounds
                    currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.up;
                }
            }

        }
        
        
    }
    private func getUOMStorableAPI(_ productID:Int,completion: @escaping (_ result: [UOMStrobleProduct]?) -> Void){
        SharedManager.shared.conAPI().hitGetUOMStorableAPI(for:productID) { result in
            if result.success
            {
                let response = result.response
                if let result:[[String:Any]]  = response?["result"] as? [[String:Any]] , result.count > 0, let dic = result.first {
                    var uomList:[UOMStrobleProduct] = []
                    if let uomID = dic["uom_id"] as? [Any]{
                        uomList.append(UOMStrobleProduct(from: uomID))
                    }
                    if let uomInvID = dic["inv_uom_id"] as? [Any]{
                        uomList.append(UOMStrobleProduct(from: uomInvID))
                    }
                    if  let uomPoID = dic["uom_po_id"] as? [Any]{
                        uomList.append(UOMStrobleProduct(from: uomPoID))
                    }
                    completion(uomList)
                    return
                }
            }
            completion(nil)
        }
    }
    private func createUIAlertAction(with uomStrobleProduct:UOMStrobleProduct,
                                     style: UIAlertAction.Style = .default,
                                     isSelet:Bool = false,
                                     action: @escaping ((UOMStrobleProduct)->())) -> UIAlertAction{
        let option = UIAlertAction(title: uomStrobleProduct.name ?? "-", style: style, handler: {
            (alert: UIAlertAction!) -> Void in
            action(uomStrobleProduct)
        })
        if style != .cancel {
        let colorSelect = #colorLiteral(red: 0.9988561273, green: 0.4232195616, blue: 0.2168394923, alpha: 1)
        let colorUnSelect = #colorLiteral(red: 0.3650116324, green: 0.1732142568, blue: 0.5585888624, alpha: 1)
        option.setValue( isSelet ? colorSelect:colorUnSelect , forKey: "titleTextColor")
        }
        return option
    }
}

struct UOMStrobleProduct: Codable{
    var id:Int?
    var name:String?
    
    init(from values: [Any])  {
        self.id = values.first as? Int
        self.name = values.last as? String
    }
}

extension api {
    func hitGetUOMStorableAPI(for productID:Int ,completion: @escaping (_ result: api_Results) -> Void)  {
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params":  [
                "model": "product.product",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [
                        "uom_id",
                        "inv_uom_id",
                        "uom_po_id"
                    ],
                    "domain": [
                        ["type", "=", "product"],
                        ["active", "=", "true"]
                        ,["id", "=", productID]
                    ]
                    ,
                    "offset": false,
                    "limit": false,
                    "context":  get_context(display_default_code: true)
                    
                ],
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"get_uom_storable_item"),header: header, param: param, completion: completion);
        
    }
}
