//
//  LinesListRouter.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/30/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import UIKit
class LinesListRouter {
    weak var viewController: LinesListVC?
    static func createModule(delegate:LinesListDelegate,viewType:LINES_STORED_VIEW_TYPES,filterCategoryID:[Int]? = nil,productRequest:product_product_class? = nil) -> LinesListVC {
        let vc:LinesListVC = LinesListVC()
        let linesListVM = LinesListVM(viewType: viewType,filterCategoryID:filterCategoryID,productRequest: productRequest )
        let router = LinesListRouter()
        linesListVM.API = api()
        router.viewController = vc
        vc.linesListVM = linesListVM
        vc.linesListRouter = router
        linesListVM.delegate = delegate
    return vc
    }
   
}
