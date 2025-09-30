//
//  AccountingSupplierPartyModel.swift
//  pos
//
//  Created by M-Wageh on 01/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
class AccountingSupplierPartyModel{
    var CRN:String,COMPANY_NAME:String,CRN_ID:String,
        postalAddress:[PostalAddress_ENUM:String],
        partyTaxScheme:[PartyTaxScheme_ENUM:String],
        partyLegalEntity:[PartyLegalEntity_ENUM:String],
        contact_temp:[Contact_ENUM:String]
    init(CRN: String,CRN_ID: String, COMPANY_NAME: String, postalAddress: [PostalAddress_ENUM : String], partyTaxScheme: [PartyTaxScheme_ENUM : String], partyLegalEntity: [PartyLegalEntity_ENUM : String], contact_temp: [Contact_ENUM : String]) {
        self.CRN = CRN
        self.CRN_ID = CRN_ID
        self.COMPANY_NAME = COMPANY_NAME
        self.postalAddress = postalAddress
        self.partyTaxScheme = partyTaxScheme
        self.partyLegalEntity = partyLegalEntity
        self.contact_temp = contact_temp
    }
}
