//
//  Constants.swift
//  MicrosoftAuthenticationDemo
//
//  Created by simon heij on 25-02-19.
//  Copyright © 2019 simon heij. All rights reserved.
//

import Foundation

struct Constants {
    // Update the below to your client ID you received in the portal.
    static let kClientID = "b58325a2-613b-4cdf-b0e0-5bc625084437"
    
    // These settings you don't need to edit unless you wish to attempt deeper scenarios with the app.
    static let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
    static let kScopes: [String] = ["https://graph.microsoft.com/user.read"]
    static let kAuthority = "https://login.microsoftonline.com/common"
}
