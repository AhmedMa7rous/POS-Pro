enum PostalAddress_ENUM:String {

   case StreetName = "StreetName"
    case BuildingNumber = "BuildingNumber"
    case PlotIdentification = "PlotIdentification"
    case CitySubdivisionName = "CitySubdivisionName"
    case CityName = "CityName"
    case PostalZone = "PostalZone"
    case CountrySubentity = "CountrySubentity"
    case CountrySubentityCode = "CountrySubentityCode"
    case IdentificationCode = "IdentificationCode"
    case Name = "Name"
    static func getFullTemplate()->String {
       
            let fullTemplate = """
    <cac:PostalAddress>
        #StreetName_value#
        <cbc:BuildingNumber>#BuildingNumber_value#</cbc:BuildingNumber>
        <cbc:PlotIdentification>#PlotIdentification_value#</cbc:PlotIdentification>
        <cbc:CitySubdivisionName>#CitySubdivisionName_value#</cbc:CitySubdivisionName>
        <cbc:CityName>#CityName_value#</cbc:CityName>
        <cbc:PostalZone>#PostalZone_value#</cbc:PostalZone>
        <cbc:CountrySubentity>#CountrySubentity_value#</cbc:CountrySubentity>
            <cac:Country>
                <cbc:IdentificationCode>#IdentificationCode_value#</cbc:IdentificationCode>
                <cbc:Name>#Name_value#</cbc:Name>
            </cac:Country>
    </cac:PostalAddress>
    """
            return fullTemplate
     
    }
    private func getValueTemplate()->String {
   
        let rawValue = self.rawValue
        
    return "<cbc:\(rawValue)>#VALUE#</cbc:\(rawValue)>"
    }

    static func getTemplate(from dic:[PostalAddress_ENUM:String]) -> String {
        var fullTemplate = PostalAddress_ENUM.getFullTemplate()
        var allString:[String] = []
        for (key,value) in dic {
            fullTemplate = fullTemplate.replacingOccurrences(of: "#\(key.rawValue)_value#", with: value)
//            if !value.isEmpty{
//           allString.append(key.getValueTemplate().replacingOccurrences(of:"#VALUE#",with:value))
//
//            }
        }
        return fullTemplate //allString.joined(separator: "\n   ")
    }
    static func getDictionary(company:res_company_class) -> [PostalAddress_ENUM:String]{
        var Dic:[PostalAddress_ENUM:String] = [:]
        Dic[.StreetName] = getTempValue(temp:"<cbc:StreetName>#StreetName_value#</cbc:StreetName>",keyString:"StreetName_value",valueString:company.street ?? "Riyadh")
        Dic[.BuildingNumber] = company.l10n_sa_edi_building_number ?? ""
        Dic[.PlotIdentification] = company.l10n_sa_edi_plot_identification ?? ""
        Dic[.CitySubdivisionName] = company.state_id_name ?? "Riyadh"
        Dic[.CityName] = company.city ?? "Riyadh"
        Dic[.PostalZone] = company.zip ?? "12345"
        Dic[.CountrySubentity] = company.state_id_name ?? "Riyadh"
        Dic[.CountrySubentityCode] = company.state_id_name ?? "Riyadh"
        Dic[.IdentificationCode] = company.country_code
        Dic[.Name] = company.country_name


        return Dic
    }
    static func getDictionary(customer:res_partner_class) -> [PostalAddress_ENUM:String]{
        var Dic:[PostalAddress_ENUM:String] = [:]
        Dic[.StreetName] = getTempValue(temp:"<cbc:StreetName>#StreetName_value#</cbc:StreetName>",keyString:"StreetName_value",valueString:customer.street)
        Dic[.BuildingNumber] = customer.l10n_sa_edi_building_number
        Dic[.PlotIdentification] = customer.l10n_sa_edi_plot_identification
        Dic[.CitySubdivisionName] = customer.state_id_name
        Dic[.CityName] = customer.city
        Dic[.PostalZone] = customer.zip
        Dic[.CountrySubentity] = customer.state_id_name
        Dic[.CountrySubentityCode] = customer.state_id_name
        Dic[.IdentificationCode] = "SA"
        Dic[.Name] = "Saudi Arabia"
        return Dic
    }
    static func getDefaultDictionary() -> [PostalAddress_ENUM:String]{
        var Dic:[PostalAddress_ENUM:String] = [:]
        Dic[.StreetName] = getTempValue(temp:"<cbc:StreetName>#StreetName_value#</cbc:StreetName>",keyString:"StreetName_value",valueString:"")
        Dic[.BuildingNumber] = "1"
        Dic[.PlotIdentification] = "1"
        Dic[.CitySubdivisionName] = "1"
        Dic[.CityName] = "Saudi Arabia"
        Dic[.PostalZone] = "12345"
        Dic[.CountrySubentity] = "Riyadh"
        Dic[.CountrySubentityCode] = "Riyadh"
        Dic[.IdentificationCode] = "SA"
        Dic[.Name] = "Saudi Arabia"
        return Dic
    }
    static func getTempValue(temp:String,keyString:String,valueString:String) -> String{
        if !valueString.isEmpty {
            return temp.replacingOccurrences(of: "#\(keyString)#", with: valueString)
        }
        return ""
    }

}
