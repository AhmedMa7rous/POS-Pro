enum CBC_TEMPLATE:String {
    
    case UBL = "UBLVersionID"
    case PROFILE_ID = "ProfileID"
    case ID = "ID"
    case UUID = "UUID"
    case IssueDate = "IssueDate"
    case IssueTime = "IssueTime"
    case InvoiceTypeCode = "InvoiceTypeCode"
    case DocumentCurrencyCode = "DocumentCurrencyCode"
    case TaxCurrencyCode = "TaxCurrencyCode"
    case BuyerReference = "BuyerReference"
    
    static func getAllTemplate()->String{
        return  """
            <cbc:ID>#VALUE_ID#</cbc:ID>
            <cbc:UUID>#VALUE_UUID#</cbc:UUID>
            <cbc:IssueDate>#VALUE_IssueDate#</cbc:IssueDate>
            <cbc:IssueTime>#VALUE_IssueTime#</cbc:IssueTime>
            <cbc:InvoiceTypeCode name=\"0200000\">#VALUE_InvoiceTypeCode#</cbc:InvoiceTypeCode>
            <cbc:DocumentCurrencyCode>#VALUE_DocumentCurrencyCode#</cbc:DocumentCurrencyCode>
            <cbc:TaxCurrencyCode>#VALUE_TaxCurrencyCode#</cbc:TaxCurrencyCode>
            <cbc:BuyerReference>#VALUE_BuyerReference#</cbc:BuyerReference>
          """
    }
    private func getValueTemplate()->String{
        if self == CBC_TEMPLATE.UBL{
            return "<cbc:UBLVersionID>2.1</cbc:UBLVersionID>"
        }
        if self == CBC_TEMPLATE.PROFILE_ID{
            return "<cbc:ProfileID>reporting:1.0</cbc:ProfileID>"
        }
        if self == CBC_TEMPLATE.InvoiceTypeCode{
            return "<cbc:InvoiceTypeCode name=\"0200000\">#VALUE#</cbc:InvoiceTypeCode>"
        }
        
        let rawValue = self.rawValue
      
        return "<cbc:\(rawValue)>#VALUE#</cbc:\(rawValue)>"
    }
    
    static func getTemplate(from dic:[CBC_TEMPLATE:String]) -> String {
//        var allString:[String] = []
        var fullTemplate = CBC_TEMPLATE.getAllTemplate()
        for (key,value) in dic {
            if !value.isEmpty{
                fullTemplate = fullTemplate.replacingOccurrences(of: "#VALUE_\(key.rawValue)#", with: value)
//                let keyValue = key.getValueTemplate().replacingOccurrences(of:"#VALUE#",with:"\(value )" )
//                allString.append(keyValue)
                
            }
        }
        return fullTemplate
//        return allString.joined(separator: "\n   ")
    }
    static func getDictionaryCBC(ID:String,UUID:String,
                                 IssueDate:String,IssueTime:String,InvoiceTypeCode:String,DocumentCurrencyCode:String,
                                 TaxCurrencyCode:String,BuyerReference:String
    ) -> [CBC_TEMPLATE:String]{
        var cbcDic:[CBC_TEMPLATE:String] = [:]
        cbcDic[.ID] = ID
        cbcDic[.UUID] = UUID
        cbcDic[.IssueDate] = IssueDate
        cbcDic[.IssueTime] = IssueTime
        cbcDic[.InvoiceTypeCode] = InvoiceTypeCode
        cbcDic[.DocumentCurrencyCode] = DocumentCurrencyCode

        cbcDic[.TaxCurrencyCode] = TaxCurrencyCode
        cbcDic[.BuyerReference] = BuyerReference

        return cbcDic
    }
    
    
}
