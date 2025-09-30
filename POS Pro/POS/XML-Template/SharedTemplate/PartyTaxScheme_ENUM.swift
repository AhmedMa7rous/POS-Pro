enum PartyTaxScheme_ENUM:String {

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
    case ID = "ID"
    static func getFullTemplate()->String{
        let fullTemplate = """
<cac:PartyTaxScheme>
    <cbc:RegistrationName>#RegistrationName_value#</cbc:RegistrationName>
    <cbc:CompanyID>#CompanyID_value#</cbc:CompanyID>
    <cac:RegistrationAddress>
        <cbc:StreetName>#StreetName_value#</cbc:StreetName>
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
    </cac:RegistrationAddress>
    <cac:TaxScheme>
        <cbc:ID>#ID_value#</cbc:ID>
    </cac:TaxScheme>
</cac:PartyTaxScheme>
"""
        return fullTemplate
    }
    private func getValueTemplate()->String {
    let rawValue = self.rawValue
    return "<cbc:\(rawValue)>#VALUE#</cbc:\(rawValue)>"
    }

    static func getTemplate(from dic:[PartyTaxScheme_ENUM:String]) -> String {
        var fullTemplate = PartyTaxScheme_ENUM.getFullTemplate()
        for (key,value) in dic {
            fullTemplate = fullTemplate.replacingOccurrences(of: "#\(key.rawValue)_value#", with: value)
            }
        return fullTemplate //allString.joined(separator: "\n   ")
    }
    static func getDictionary(company:res_company_class) -> [PartyTaxScheme_ENUM:String]{
        var Dic:[PartyTaxScheme_ENUM:String] = [:]
        Dic[.RegistrationName] = "\(company.name ?? "")"
        Dic[.CompanyID] = "\(company.vat)"
        Dic[.StreetName] = company.street ?? "Riyadh"
        Dic[.BuildingNumber] = company.l10n_sa_edi_building_number ?? ""
        Dic[.PlotIdentification] = company.l10n_sa_edi_plot_identification ?? ""
        Dic[.CitySubdivisionName] = company.state_id_name ?? "Riyadh"
        Dic[.CityName] = company.city ?? "Riyadh"
        Dic[.PostalZone] = company.zip ?? "12345"
        Dic[.CountrySubentity] = company.state_id_name ?? "Riyadh"
        Dic[.CountrySubentityCode] = company.state_id_name ?? "Riyadh"
        Dic[.IdentificationCode] = company.country_code
        Dic[.Name] = company.country_name
        Dic[.ID] = "VAT"


        return Dic
    }
    static func getDictionary(customer:res_partner_class) -> [PartyTaxScheme_ENUM:String]{
        var Dic:[PartyTaxScheme_ENUM:String] = [:]
//        Dic[.CompanyID] = "VAT"
//        Dic[.StreetName] = customer.street
//        Dic[.BuildingNumber] = customer.l10n_sa_edi_building_number
//        Dic[.PlotIdentification] = customer.l10n_sa_edi_plot_identification
//        Dic[.CitySubdivisionName] = customer.state_id_name
//        Dic[.CityName] = customer.city
//        Dic[.PostalZone] = customer.zip
//        Dic[.CountrySubentity] = customer.state_id_name
//        Dic[.CountrySubentityCode] = customer.state_id_name
//        Dic[.IdentificationCode] = "SA"
//        Dic[.Name] = "Saudi Arabia"
        Dic[.ID] = "VAT"


        return Dic
    }
}
