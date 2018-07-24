//
//  ViewController.swift
//  FirebaseSocialLogin
//
//  Created by Vasiliy Teplov on 23.07.2018.
//  Copyright © 2018 Vasiliy Teplov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import TwitterKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    /******
     ** Buttons on this controller are creating user account in Firebase
     ** through authentication by related social networks.
     ******/

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFacebookButtons()
        setupGoogleButtons()
        setupTwitterButton()
    }
    
    fileprivate func setupTwitterButton() {
        
        let twitterButton = TWTRLogInButton { (session, error) in
            if let error = error {
                print("Failed to login via Twitter: ", error)
                return
            }
            
            print("Successfully logged in Twitter.")
            
            guard let token = session?.authToken else { return }
            guard let secret = session?.authTokenSecret else { return }
            
            let credentials = TwitterAuthProvider.credential(withToken: token, secret: secret)
            
            Auth.auth().signInAndRetrieveData(with: credentials, completion: { (result, error) in
                if let error = error {
                    print("Failed to log in to Firebase with Twitter: ", error)
                    return
                }
                
                if let userUid = result?.user.uid {
                    print("Successfully created a Firebase-Twitter user: ", userUid)
                }
            })
        }
        
        view.addSubview(twitterButton)
        
        twitterButton.frame = CGRect(x: 16, y: 116 + 66 + 66 + 66, width: view.frame.width - 32, height: 50)
    }
    
    fileprivate func setupGoogleButtons() {
        
        // Add Google sign in button.
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        
        // Custom Google button.
        let customButton = UIButton(type: .system)
        customButton.frame = CGRect(x: 16, y: 116 + 66 + 66, width: view.frame.width - 32, height: 50)
        customButton.backgroundColor = .orange
        customButton.setTitleColor(.white, for: .normal)
        customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customButton.setTitle("Custom Google Sign In", for: .normal)
        customButton.addTarget(self, action: #selector(handleCustomGoogleSign), for: .touchUpInside)
        view.addSubview(customButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    fileprivate func setupFacebookButtons() {
        
        let loginButton = FBSDKLoginButton()
        loginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        view.addSubview(loginButton)
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        
        // Add custom FB login button.
        let customFBButton = UIButton(type: .system)
        customFBButton.backgroundColor = .blue
        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        customFBButton.setTitle("Custom Facebook login button", for: .normal)
        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customFBButton.setTitleColor(.white, for: .normal)
        view.addSubview(customFBButton)
        
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc func handleCustomGoogleSign() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @objc func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if let error = error {
                print("FB login failed: ", error)
                return
            }
            
            if let result = result {
                print(result.token.tokenString)
            }
            
            self.showEmailAddress()
        }
    }
    
    // MARK: - FBSDKLoginButtonDelegate
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        print("Successfully logged in with Facebook.")

        showEmailAddress()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of Facebook.")
    }
    
    func showEmailAddress() {
        
        let accessToken = FBSDKAccessToken.current()
        
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signInAndRetrieveData(with: credentials) { (result, error) in
            if let error = error {
                print("Something went wrong with our FB user: ", error)
                return
            }
            
            if let user = result?.user {
                print("Successfully logged in with our user: ", user)
            }
        }
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            
            if let error = error {
                print("Fail to start graph request: ", error)
                return
            }
            
            if let result = result {
                print(result)
            }
        }
    }
}

