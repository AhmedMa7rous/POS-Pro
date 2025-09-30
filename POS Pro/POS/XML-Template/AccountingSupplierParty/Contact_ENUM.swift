enum Contact_ENUM:String {

   case ID = "ID"
    case Name = "Name"
    case Telephone = "Telephone"
    case ElectronicMail = "ElectronicMail"
    static func getFullTemplate()->String{
        let fullTemplate = """
<cac:Contact>
    <cbc:ID>#ID_value#</cbc:ID>
    <cbc:Name>#Name_value#</cbc:Name>
    <cbc:Telephone>#Telephone_value#</cbc:Telephone>
    <cbc:ElectronicMail>#ElectronicMail_value#</cbc:ElectronicMail>
</cac:Contact>
"""
        return fullTemplate
    }

    private func getValueTemplate()->String {
    let rawValue = self.rawValue
    return "<cbc:\(rawValue)>#VALUE#</cbc:\(rawValue)>"
    }

    static func getTemplate(from dic:[Contact_ENUM:String]) -> String {
        var fullTemplate = Contact_ENUM.getFullTemplate()
        for (key,value) in dic {
            fullTemplate = fullTemplate.replacingOccurrences(of: "#\(key.rawValue)_value#", with: value)
            }
        return fullTemplate //allString.joined(separator: "\n   ")
    }
    static func getDictionary(company:res_company_class) -> [Contact_ENUM:String]{
        var Dic:[Contact_ENUM:String] = [:]
        Dic[.ID] = "\(company.vat)"
        Dic[.Name] = company.name
        Dic[.Telephone] = company.phone
        Dic[.ElectronicMail] = company.email
        return Dic
    }
    static func getDictionary(customer:res_partner_class) -> [Contact_ENUM:String]{
        var Dic:[Contact_ENUM:String] = [:]
        Dic[.ID] = "\(customer.id)"
        Dic[.Name] = customer.name
        Dic[.Telephone] = customer.phone
        Dic[.ElectronicMail] = customer.email
        return Dic
    }
    static func getDefaultDictionary() -> [Contact_ENUM:String]{
        var Dic:[Contact_ENUM:String] = [:]
        Dic[.ID] = ""
        Dic[.Name] = "عميل نقدي"
        Dic[.Telephone] = ""
        Dic[.ElectronicMail] = ""
        return Dic
    }
}
