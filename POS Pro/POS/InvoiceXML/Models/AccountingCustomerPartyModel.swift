//
//  AccountingCustomerPartyModel.swift
//  pos
//
//  Created by M-Wageh on 01/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
class AccountingCustomerPartyModel{
    var CUSTOMER_ID:Int,CUSTOMER_NAME:String,
        postalAddressCus:[PostalAddress_ENUM:String],
        partyTaxSchemeCus:[PartyTaxScheme_ENUM:String],
        partyLegalEntityCus:[PartyLegalEntity_ENUM:String],
        contactCus:[Contact_ENUM:String]
    init(CUSTOMER_ID: Int, CUSTOMER_NAME: String, postalAddressCus: [PostalAddress_ENUM : String], partyTaxSchemeCus: [PartyTaxScheme_ENUM : String], partyLegalEntityCus: [PartyLegalEntity_ENUM : String], contactCus: [Contact_ENUM : String]) {
        self.CUSTOMER_ID = CUSTOMER_ID
        self.CUSTOMER_NAME = CUSTOMER_NAME
        self.postalAddressCus = postalAddressCus
        self.partyTaxSchemeCus = partyTaxSchemeCus
        self.partyLegalEntityCus = partyLegalEntityCus
        self.contactCus = contactCus
    }
}
