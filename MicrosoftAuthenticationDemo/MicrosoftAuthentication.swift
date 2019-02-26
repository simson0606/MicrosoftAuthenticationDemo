//
//  MicrosoftAuthentication.swift
//  MicrosoftAuthenticationDemo
//
//  Created by simon heij on 25-02-19.
//  Copyright © 2019 simon heij. All rights reserved.
//

import Foundation
import MSAL

class MicrosoftAuthentication: NSObject, URLSessionDelegate {
    
    private var accessToken = String()
    private var applicationContext : MSALPublicClientApplication?
    
    var authenticationDelegate : MicrosoftAuthenticationDelegate?
    
    public func signIn() {
        let contextResult = createContext()
        if contextResult.result {
            callGraph()
        } else {
            print(contextResult.description)
        }
    }
    
    public func signOut() {
        guard let applicationContext = self.applicationContext else { return }
        
        guard let account = self.currentAccount() else { return }
        
        do {
            
            /**
             Removes all tokens from the cache for this application for the provided account
             
             - account:    The account to remove from the cache
             */
            
            try applicationContext.remove(account)
            
        } catch let error as NSError {
            
            print("Received error signing account out: \(error)")
        }
    }
    
    private func createContext() -> (result: Bool, description: String) {
        do {
            
            /**
             
             Initialize a MSALPublicClientApplication with a given clientID and authority
             
             - clientId:            The clientID of your application, you should get this from the app portal.
             - authority:           A URL indicating a directory that MSAL can use to obtain tokens. In Azure AD
             it is of the form https://<instance/<tenant>, where <instance> is the
             directory host (e.g. https://login.microsoftonline.com) and <tenant> is a
             identifier within the directory itself (e.g. a domain associated to the
             tenant, such as contoso.onmicrosoft.com, or the GUID representing the
             TenantID property of the directory)
             - error                The error that occurred creating the application object, if any, if you're
             not interested in the specific error pass in nil.
             */
            
            guard let authorityURL = URL(string: Constants.kAuthority) else {
                return (false, "Unable to create authority URL")
            }
            
            let authority = try MSALAuthority(url: authorityURL)
            self.applicationContext = try MSALPublicClientApplication(clientId: Constants.kClientID, authority: authority)
            
        } catch let error {
            return (false, "Unable to create Application Context \(error)")
        }
        return (true, "Success")
    }
    
    private func callGraph() {
        if self.currentAccount() == nil {
            // We check to see if we have a current logged in account.
            // If we don't, then we need to sign someone in.
            self.acquireTokenInteractively()
        } else {
            self.acquireTokenSilently()
        }
    }
    
    private func acquireTokenInteractively() {
        
        guard let applicationContext = self.applicationContext else { return }
        
        applicationContext.acquireToken(forScopes: Constants.kScopes) { (result, error) in
            
            if let error = error {
                
                print("Could not acquire token: \(error)")
                return
            }
            
            guard let result = result else {
                print("Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            print("Access token is \(self.accessToken)")
            self.getContentWithToken()
        }
    }
    
    private func acquireTokenSilently() {
        
        guard let applicationContext = self.applicationContext else { return }
        
        /**
         
         Acquire a token for an existing account silently
         
         - forScopes:           Permissions you want included in the access token received
         in the result in the completionBlock. Not all scopes are
         guaranteed to be included in the access token returned.
         - account:             An account object that we retrieved from the application object before that the
         authentication flow will be locked down to.
         - completionBlock:     The completion block that will be called when the authentication
         flow completes, or encounters an error.
         */
        
        applicationContext.acquireTokenSilent(forScopes: Constants.kScopes, account: self.currentAccount()!) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                
                if (nsError.domain == MSALErrorDomain
                    && nsError.code == MSALErrorCode.interactionRequired.rawValue) {
                    
                    DispatchQueue.main.async {
                        self.acquireTokenInteractively()
                    }
                    
                } else {
                    print("Could not acquire token silently: \(error)")
                }
                
                return
            }
            
            guard let result = result else {
                print("Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            print("Refreshed Access token is \(self.accessToken)")
            self.getContentWithToken()
        }
    }
    
    private func currentAccount() -> MSALAccount? {
        
        guard let applicationContext = self.applicationContext else { return nil }
        
        // We retrieve our current account by getting the first account from cache
        // In multi-account applications, account should be retrieved by home account identifier or username instead
        
        do {
            
            let cachedAccounts = try applicationContext.allAccounts()
            
            if !cachedAccounts.isEmpty {
                return cachedAccounts.first
            }
            
        } catch let error as NSError {
            print("Didn't find any accounts in cache: \(error)")
        }
        
        return nil
    }
    
    private func getContentWithToken() {
        
        // Specify the Graph API endpoint
        let url = URL(string: Constants.kGraphURI)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Couldn't get graph result: \(error)")
                return
            }
            
            guard (try? JSONSerialization.jsonObject(with: data!, options: [])) != nil else {
                print("Couldn't deserialize result JSON")
                return
            }
            let decoder = JSONDecoder()
            let poso = try! decoder.decode(UserInformation.self, from: data!)
            
            self.authenticationDelegate?.receivedUserInfo(userinfo: poso)
            
            }.resume()
    }
    
}
