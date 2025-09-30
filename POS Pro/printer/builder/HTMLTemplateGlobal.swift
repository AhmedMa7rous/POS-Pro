//
//  HTMLTemplateGlobal.swift
//  pos
//
//  Created by M-Wageh on 24/01/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

class HTMLTemplateGlobal{
    enum TEMPLATES_TYPES{
        case BILL,KDS,INSURANCE,NOTE_PRINTER
    }
    private var invoiceTemplateHtmlContent:String?
    private var kdsTemplateHtmlContent:String?
    private var insuranceTemplateHtmlContent:String?
    private var noteTemplateHtmlContent:String?

    static let shared = HTMLTemplateGlobal()
    
    private init(){}
    func getTemplateHtmlContent(_ typeTemplate:TEMPLATES_TYPES) -> String{
        switch typeTemplate{
        case .BILL:
            if let invoiceTemplateHtmlContent = invoiceTemplateHtmlContent{
                return invoiceTemplateHtmlContent
            }
        case .KDS:
            if let kdsTemplateHtmlContent = kdsTemplateHtmlContent{
                return kdsTemplateHtmlContent
            }
        case .INSURANCE:
            if let insuranceTemplateHtmlContent = insuranceTemplateHtmlContent{
                return insuranceTemplateHtmlContent
            }
        case .NOTE_PRINTER:
            if let noteTemplateHtmlContent = noteTemplateHtmlContent{
                return noteTemplateHtmlContent
            }
        }
        
       
        intialTemplateHtmlContent(typeTemplate)
        return getTemplateHtmlContent(typeTemplate)
    }
    func intialTemplate(){
        intialTemplateHtmlContent(.BILL)
        intialTemplateHtmlContent(.KDS)
        intialTemplateHtmlContent(.INSURANCE)
        intialTemplateHtmlContent(.NOTE_PRINTER)


    }
    
    private func intialTemplateHtmlContent(_ typeTemplate:TEMPLATES_TYPES){
        if typeTemplate == .INSURANCE {
            if var HTMLContent = CashHtmlFiles.shared.invoice_html{
                    HTMLContent = HTMLContent.replacingOccurrences(of: "#FONT_SIZE_BORDER#", with: renderFontSizeBorder(typeTemplate))
                    HTMLContent = HTMLContent.replacingOccurrences(of: "#FONT_SIZE#", with: renderFontSize(typeTemplate))
                insuranceTemplateHtmlContent = HTMLContent
            }
        }else if typeTemplate == .NOTE_PRINTER {
            self.noteTemplateHtmlContent = FileMangerHelper.shared.getString(from :"note_printer")
        } else {
            setInvoiceHTMLContentFor(typeTemplate)
        }
       
    }
    private func setInvoiceHTMLContentFor(_ typeTemplate:TEMPLATES_TYPES){
        if var HTMLContent = CashHtmlFiles.shared.invoice_html{
                HTMLContent = HTMLContent.replacingOccurrences(of: "#FONT_SIZE_BORDER#", with: renderFontSizeBorder(typeTemplate))
                HTMLContent = HTMLContent.replacingOccurrences(of: "#FONT_SIZE#", with: renderFontSize(typeTemplate))
            if typeTemplate == .KDS {
                kdsTemplateHtmlContent = HTMLContent
            }
            if typeTemplate == .BILL {
                invoiceTemplateHtmlContent = HTMLContent
            }
           
            
            }
    }
    private func renderFontSize(_ typeTemplate:TEMPLATES_TYPES) -> String {
        let fonSize = SharedManager.shared.appSetting().font_size_for_kitchen_invoice
        if typeTemplate == .KDS {
          return "font-size:\(fonSize)px;"
        }
        return ""
    }
    private func renderFontSizeBorder(_ typeTemplate:TEMPLATES_TYPES) -> String {
        if typeTemplate == .KDS {
        let fonSize = SharedManager.shared.appSetting().font_size_for_kitchen_invoice + 30
        return "font-size:\(fonSize )px;"
        }
        return "font-size:\(60 )px;"

    }
}
