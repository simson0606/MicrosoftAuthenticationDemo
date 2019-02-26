//
//  ViewController.swift
//  MicrosoftAuthenticationDemo
//
//  Created by simon heij on 25-02-19.
//  Copyright © 2019 simon heij. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MicrosoftAuthenticationDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    private let authentication = MicrosoftAuthentication()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authentication.authenticationDelegate = self
    }

    @IBAction func loginTapped(_ sender: Any) {
        authentication.signIn()
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        authentication.signOut()
        self.nameLabel.text = "Name: Logged out"
        self.emailLabel.text = "Email: "
    }
    
    func receivedUserInfo(userinfo: UserInformation) {
        DispatchQueue.main.async {
            self.nameLabel.text = "Name: \(userinfo.displayName ?? "Unknown")"
            self.emailLabel.text = "Email: \(userinfo.userPrincipalName ?? "Unknown")"
        }
    }
}

