//
//  MicrosoftAuthenticationDelegate.swift
//  MicrosoftAuthenticationDemo
//
//  Created by simon heij on 25-02-19.
//  Copyright © 2019 simon heij. All rights reserved.
//

import Foundation

protocol MicrosoftAuthenticationDelegate {
    func receivedUserInfo(userinfo : UserInformation)
}
