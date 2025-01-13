//
//  LoginViewController.swift
//  HomePilotApp
//
//  Created by Helin Güler on 12.01.2025.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var appleLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Ensure GIDSignIn configuration is properly set
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Missing clientID in GoogleService-Info.plist")
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        googleLoginButton.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        
        // Check if user is already sign in
        checkUserSignInStatus()
    }
    
    
    @objc func signInWithGoogle() {
        print("Google sign in button tapped")
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
        
            guard let user = signInResult?.user, let idToken = user.idToken?.tokenString else {
                print("No user or idToken")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Error authenticating: \(error.localizedDescription)")
                    return
                }
                
                // User is signed in, transition to the HomeScreen
                print("User signed in: \(authResult?.user.uid ?? "")")
                self.showHomeScreen()
            }
        }
    }

    func checkUserSignInStatus() {
        if Auth.auth().currentUser != nil {
            // User is signed in, navigate to HomeScreen
            showHomeScreen()
        }
    }
    
    func showHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
