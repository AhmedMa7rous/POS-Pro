enum PartyLegalEntity_ENUM:String {

   case RegistrationName = "RegistrationName"
    case CompanyID = "CompanyID"
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
    static func getFullTemplate()->String{
        let fullTemplate = """
<cac:PartyLegalEntity>
    <cbc:RegistrationName>#RegistrationName_value#</cbc:RegistrationName>
    #CompanyID_value#
    <cac:RegistrationAddress>
        #StreetName_value#
        #BuildingNumber_value#
        #PlotIdentification_value#
        <cbc:CitySubdivisionName>#CitySubdivisionName_value#</cbc:CitySubdivisionName>
        <cbc:CityName>#CityName_value#</cbc:CityName>
        <cbc:PostalZone>#PostalZone_value#</cbc:PostalZone>
        <cbc:CountrySubentity>#CountrySubentity_value#</cbc:CountrySubentity>
        <cac:Country>
            <cbc:IdentificationCode>#IdentificationCode_value#</cbc:IdentificationCode>
            <cbc:Name>#Name_value#</cbc:Name>
        </cac:Country>
    </cac:RegistrationAddress>
</cac:PartyLegalEntity>
"""
        return fullTemplate
    }
    private func getValueTemplate()->String {
    let rawValue = self.rawValue
    return "<cbc:\(rawValue)>#VALUE#</cbc:\(rawValue)>"
    }

    static func getTemplate(from dic:[PartyLegalEntity_ENUM:String]) -> String {
        var fullTemplate = PartyLegalEntity_ENUM.getFullTemplate()
        for (key,value) in dic {
            fullTemplate = fullTemplate.replacingOccurrences(of: "#\(key.rawValue)_value#", with: value)
            }
        return fullTemplate //allString.joined(separator: "\n   ")
    }
    static func getDictionary(company:res_company_class) -> [PartyLegalEntity_ENUM:String]{
        var Dic:[PartyLegalEntity_ENUM:String] = [:]
        Dic[.RegistrationName] = company.name

        Dic[.CompanyID] = getTempValue(temp:"<cbc:CompanyID>#CompanyID_value#</cbc:CompanyID>",keyString:"CompanyID_value",valueString:"\(company.vat)")
        Dic[.StreetName] = getTempValue(temp:"<cbc:StreetName>#StreetName_value#</cbc:StreetName>",keyString:"StreetName_value",valueString:company.street ?? "Riyadh")
        
        Dic[.BuildingNumber] = getTempValue(temp:"<cbc:BuildingNumber>#BuildingNumber_value#</cbc:BuildingNumber>",keyString:"BuildingNumber_value",valueString:company.l10n_sa_edi_building_number ?? "")
        Dic[.PlotIdentification] =  getTempValue(temp:"<cbc:PlotIdentification>#PlotIdentification_value#</cbc:PlotIdentification>",keyString:"PlotIdentification_value",valueString:company.l10n_sa_edi_plot_identification ?? "")
        Dic[.CitySubdivisionName] = company.state_id_name ?? "Riyadh"
        Dic[.CityName] = company.city ?? "Riyadh"
        Dic[.PostalZone] = company.zip ?? "12345"
        Dic[.CountrySubentity] = company.state_id_name ?? "Riyadh"
        Dic[.CountrySubentityCode] = company.state_id_name ?? "Riyadh"
        Dic[.IdentificationCode] = company.country_code
        Dic[.Name] = company.country_name
        return Dic
    }
    static func getTempValue(temp:String,keyString:String,valueString:String) -> String{
        if !valueString.isEmpty {
            return temp.replacingOccurrences(of: "#\(keyString)#", with: valueString)
        }
        return ""
    }
    static func getDictionary(customer:res_partner_class) -> [PartyLegalEntity_ENUM:String]{
        var Dic:[PartyLegalEntity_ENUM:String] = [:]
        Dic[.RegistrationName] = customer.name

        Dic[.CompanyID] = getTempValue(temp:"<cbc:CompanyID>#CompanyID_value#</cbc:CompanyID>",keyString:"CompanyID_value",valueString:"\(customer.vat)")
        Dic[.StreetName] = getTempValue(temp:"<cbc:StreetName>#StreetName_value#</cbc:StreetName>",keyString:"StreetName_value",valueString:customer.street )
        Dic[.BuildingNumber] = getTempValue(temp:"<cbc:BuildingNumber>#BuildingNumber_value#</cbc:BuildingNumber>",keyString:"BuildingNumber_value",valueString:customer.l10n_sa_edi_building_number)
        Dic[.PlotIdentification] =  getTempValue(temp:"<cbc:PlotIdentification>#PlotIdentification_value#</cbc:PlotIdentification>",keyString:"PlotIdentification_value",valueString:customer.l10n_sa_edi_plot_identification)
        Dic[.CitySubdivisionName] = "Riyadh"//customer.state_id_name
        Dic[.CityName] = customer.city
        Dic[.PostalZone] = customer.zip
        Dic[.CountrySubentity] = customer.state_id_name
        Dic[.CountrySubentityCode] = customer.state_id_name
        Dic[.IdentificationCode] = "SA"
        Dic[.Name] = "Saudi Arabia"


        return Dic
    }
    static func getDefaultDictionary() -> [PartyLegalEntity_ENUM:String]{
        var Dic:[PartyLegalEntity_ENUM:String] = [:]
        Dic[.RegistrationName] = "عميل نقدي"

        Dic[.CompanyID] = getTempValue(temp:"<cbc:CompanyID>#CompanyID_value#</cbc:CompanyID>",keyString:"CompanyID_value",valueString:"")
        Dic[.StreetName] = getTempValue(temp:"<cbc:StreetName>#StreetName_value#</cbc:StreetName>",keyString:"StreetName_value",valueString:"" )
        Dic[.BuildingNumber] = getTempValue(temp:"<cbc:BuildingNumber>#BuildingNumber_value#</cbc:BuildingNumber>",keyString:"BuildingNumber_value",valueString:"")
        Dic[.PlotIdentification] =  getTempValue(temp:"<cbc:PlotIdentification>#PlotIdentification_value#</cbc:PlotIdentification>",keyString:"PlotIdentification_value",valueString:"")
        Dic[.CitySubdivisionName] = "Riyadh"
        Dic[.CityName] = "Saudi Arabia"
        Dic[.PostalZone] = "12345"
        Dic[.CountrySubentity] = "Saudi Arabia"
        Dic[.CountrySubentityCode] = "Saudi Arabia"
        Dic[.IdentificationCode] = "SA"
        Dic[.Name] = "Saudi Arabia"


        return Dic
    }
}
