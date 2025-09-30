//
//  api + subscriptionOrders.swift
//  pos
//
//  Created by M-Wageh on 26/02/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation

extension api {
    func hitGetMemberShipOrdersAPI(with searchMemberShipParam:SearchMemberShipParam, completion: @escaping (_ result: api_Results) -> Void)  {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        let param:[String:Any] = searchMemberShipParam.getSearchParams()
        let Cookie = api.get_Cookie()
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: getUrl(),keyForCash: getCashKey(key:"get_memberShip_orders"),header: header, param: param, completion: completion);
    }
    
    func hitGetMemberShipOrderDetailsAPI(for order_id:Int?, completion: @escaping (_ result: api_Results) -> Void)  {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        let param:[String:Any] = getDetailsParams()
        let Cookie = api.get_Cookie()
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: getUrl(with:order_id),keyForCash: getCashKey(key:"get_memberShip_order_details"),header: header, param: param, completion: completion);
    }
    fileprivate func getDetailsParams() ->  [String:Any] {
        let posInfo = SharedManager.shared.posConfig()
        let runID = SharedManager.shared.getCashRunId()
        let dictionaryParam:[String:Any] = [
            "run_ID": runID == 0 ? false : runID,
            "pos_id": posInfo.id,
            "pos_name":posInfo.name ?? ""
        ]
        return dictionaryParam
    }
    fileprivate func getUrl(with id:Int? = nil) -> URL{
        var urlString  = "\(domain)/dgt_membership/orders"
        if let id = id {
            urlString += "/\(id)"
        }
       return  URL(string:urlString)!
    }
}
