//
//  SentNoteViaPrintersVC.swift
//  pos
//
//  Created by M-Wageh on 18/11/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class SentNoteViaPrintersVC: UIViewController {

    
    @IBOutlet weak var noteTxtView: UITextView!
    private var selectedPrinters:[restaurant_printer_class] = []
    var orderLines:[pos_order_line_class]?
    override func viewDidLoad() {
        super.viewDidLoad()
        initalList()
        noteTxtView.layer.masksToBounds = true
        noteTxtView.layer.cornerRadius = 20
        
        if let orderLines = self.orderLines {
          let noteTxt =  orderLines.map({"◉ " + "[" + "\($0.qty)" + "] " +    $0.product.display_name}).joined(separator: "\n")
            self.noteTxtView.text = noteTxt
        }

    }
    func initalList(){
        selectedPrinters = []
        self.selectedPrinters.append(contentsOf: restaurant_printer_class.get(printer_type:DEVICES_TYPES_ENUM.KDS_PRINTER))
    }
    private func renderNote() -> String?{
        if var noteTxt = self.noteTxtView.text , !noteTxt.isEmpty{
            noteTxt = noteTxt.replacingOccurrences(of: "\n", with:"<br/>")
        var HTMLContent = HTMLTemplateGlobal.shared.getTemplateHtmlContent(.NOTE_PRINTER)
            let datePrint =  "Printed at: " + Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: false)

            HTMLContent = HTMLContent.replacingOccurrences(of: "#HEADER_NOTE#", with:"طلب من نقطه البيع")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#POS_NAME#", with:SharedManager.shared.posConfig().name ?? "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CASHIER_NAME#", with:SharedManager.shared.activeUser().name ?? "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#NOTE#", with:noteTxt)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ar_NOTE#", with:"")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINT_DATE#", with:datePrint)
            
        return  HTMLContent
        }
        return nil
    }
    func creatNotePrinterQueuePrinter(){
        if selectedPrinters.count > 0 {
        guard var noteHtml = self.renderNote() else {return}
        for selectedPrinter in selectedPrinters {
            noteHtml = noteHtml.replacingOccurrences(of: "#PRINTER_NAME#", with:selectedPrinter.display_name)
            SharedManager.shared.addToMWPrintersQueue(html: noteHtml,
                                         with: selectedPrinter,
                                                      fileType: .note_printer,
                                        openDeawer: false, queuePriority: .LOW)
        }
            MWRunQueuePrinter.shared.startMWQueue()
        }
    }
    
    @IBAction func tapOnSendBtn(_ sender: Any) {
        creatNotePrinterQueuePrinter()
        self.dismiss(animated: true)
    }
    @IBAction func tapSelectPrinterBtn(_ sender: UIButton) {
        let vc = SelectPrintersIPVC.createModule(sender, selectDataList:  selectedPrinters,printerType: DEVICES_TYPES_ENUM.KDS_PRINTER)
        vc.selectDataList = self.selectedPrinters
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { selectDataList in
            let value = selectDataList.map(){$0.name}.joined(separator: ", ")
            sender.setTitle("Selecte Printer :".arabic("تحديد الطابعة:") + " " + value, for: .normal)
            self.selectedPrinters = selectDataList
            
        }
    }
    
    @IBAction func tapOnCancelBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    static func  createModule(_ orderLines:[pos_order_line_class]) -> SentNoteViaPrintersVC{
        let vc = SentNoteViaPrintersVC()
        vc.orderLines = orderLines
        vc.modalPresentationStyle = .formSheet
        vc.preferredContentSize = CGSize(width: 900, height: 700)
        
//        vc.modalPresentationStyle = .popover
      //        vc.preferredContentSize = CGSize(width: 683, height: 700)
      //        let popover = vc.popoverPresentationController!
      //        popover.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
      //        popover.sourceView = sender
      //        popover.sourceRect =  (sender as AnyObject).bounds
        return vc
    }

}
