//
//  options_listVC.swift
//  pos
//
//  Created by Khaled on 4/8/20.
//  Copyright © 2020 khaled. All rights reserved.
//
/**

 list.didSelect = { [weak self] data in
     let dic = data
     
     SharedManager.shared.printLog("%@" ,dic)
 }
 
 list.didSelect_func = {    fnc in
           
          fnc()
          
          
      }
 
 */

import UIKit

class options_listVC: baseViewController , UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    
   static let title_prefex = "title_options_listVC"
   static let cell_style = style_normal
   static let  style_arrow = "arrow"
    static let  style_normal = ""
    static let  style_disable = "disable"
    static let  style_check = "check"


    var list_items:[[String:Any]] = []
    
     var didSelect : (([String:Any]) -> Void)?
    var didSelect_object : ((Any) -> Void)?

    
     var didSelect_func : ( ( ()->() ) -> Void)?

    var clear: (() -> Void)?

 
    @IBOutlet var title_option: UILabel!
    @IBOutlet var btn_clear: UIButton!
    
    var sourceRect:CGRect?
    @IBOutlet var popup_view: UIView!
    
    var parent_viewController:UIViewController?
    var list_count = 0
    var hideClearBtnFlag:Bool?
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        stop_zoom = true
        super.viewDidDisappear(animated)
        
        tableview = nil
        list_items.removeAll()
        popup_view = nil
        sourceRect = nil
        
    }
    
    
   
    
    func add(title:String,data:Any?)  {
       
        
          var dic:[String:Any] = [:]
          dic[options_listVC.title_prefex] = title
        
        if data != nil
        {
            dic["data"] = data!

        }

        self.list_items.append(dic)
    }
    func addAction(title: String, action: @escaping () -> Void) {
        var dic: [String: Any] = [:]
        dic[options_listVC.title_prefex] = title
        dic["data"] = action
        self.list_items.append(dic)
    }

    
   static func show_option(list:options_listVC,viewController:UIViewController,sender:Any?)
    {
        DispatchQueue.main.async {
         if sender != nil
         {
            let view = (sender as? UIView)
                let buttonAbsoluteFrame = view!.convert(view!.bounds, to: viewController.view)

                list.sourceRect = buttonAbsoluteFrame
         }
       
  
 
    
        viewController.present(list, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
 
        super.viewDidLoad()
        
                blurView(alpha:1,style: .dark)

        
        tableview.reloadData()
        
        
        let screenRect = UIScreen.main.bounds

        if sourceRect != nil
        {
            
//            popup_view.frame.origin.x = sourceRect!.origin.x
//            popup_view.frame.origin.y = sourceRect!.origin.y
            let newX = max(sourceRect!.origin.x - popup_view.frame.width, 0)
            
            // Update the popup_view's frame
            popup_view.frame.origin.x = newX
            popup_view.frame.origin.y = sourceRect!.origin.y

        }
        

        self.view.frame = screenRect
        
        title_option.text = self.title
        
        
        if parent_viewController != nil
        {
            tableview.isHidden = true
            parent_viewController?.view.frame = CGRect.init(x: 20, y: 69, width: 355, height: 323)
            popup_view.addSubview(parent_viewController!.view!)
            if list_count != 0
            {
                check_height()
            }
        }
        else
        {
            check_height()

        }
        
        
        if sourceRect == nil && popup_view != nil
        {
 
            var rect = popup_view.frame
            
            rect.origin.x = (screenRect.size.width  ) / 2
            
            if screenRect.size.height  < rect.size.height
            {
                popup_view.frame.size.height = screenRect.size.height - 20
                rect.origin.y = 20
            }
            else
            {
                rect.origin.y = (screenRect.size.height  - rect.size.height ) / 2
            }
            
            popup_view.frame = rect
        }
        
        btn_clear.isHidden = self.hideClearBtnFlag ?? false

        
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
     @IBAction func btnClear(_ sender: Any) {
            clear?()

              self.dismiss(animated: true, completion: nil)
          }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let itme:[String:Any] =  list_items[indexPath.row]
       
        
        self.dismiss(animated: true, completion: {
            
            
            self.didSelect?(itme)
             
            
             let fnc = itme["data"]
             
            
             if fnc != nil
             {
                self.didSelect_func?(fnc as! () -> ()  )
                self.didSelect_object?(fnc)

             }
            
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Cell"
        var cell: options_listTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? options_listTableViewCell
               if cell == nil {
                tableView.register(UINib(nibName: "options_listTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? options_listTableViewCell
               }

        let itme:[String:Any] =  list_items[indexPath.row]
        let title = itme[options_listVC.title_prefex] as? String ?? ""
        
        cell.lblTtile.text = title
        
        let style = itme[options_listVC.cell_style] as? String ?? ""
        cell.img_arrow.isHidden = true

        if style == options_listVC.style_arrow
        {
            cell.lblTtile.textAlignment = .left
            cell.img_arrow.isHidden = false
        }
        else if style == options_listVC.style_disable
        {
            cell.img_arrow.isHidden = true
            cell.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        }
        else if style == options_listVC.style_check
        {
            cell.img_arrow.isHidden = false
            cell.img_arrow.image = UIImage(name: "icon_done.png")
         }
        else
        {
            cell.lblTtile.textAlignment = .center
           cell.img_arrow.isHidden = true
        }
        
        
    
        
        
        return cell
    }
    
    func close()
    {
        self.dismiss(animated: true, completion: nil)

    }
    @IBAction func btnCancel(_ sender: Any) {
        close()
        
    }
    
    
    func check_height()
       {
 
      
 
           if popup_view != nil
           {
            
            var h = 0
            
            if parent_viewController == nil
            {
                h =  self.list_items.count * 60
            }
            else
            {
                h =  self.list_count * 60
            }
           
            h += 70
            
            if h > 900
            {
                h = 900
            }
            popup_view.frame.size.height = CGFloat(h)

        }
           

       }
    
    
}
