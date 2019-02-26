//
//  UserInformation.swift
//  MicrosoftAuthenticationDemo
//
//  Created by simon heij on 25-02-19.
//  Copyright © 2019 simon heij. All rights reserved.
//

import Foundation

struct UserInformation : Codable {
    var displayName : String?
    var givenName : String?
    var id : String?
    var jobTitle : String?
    var mail : String?
    var mobilePhone : String?
    var officeLocation : String?
    var preferredLanguage : String?
    var surname : String?
    var userPrincipalName : String?
}
