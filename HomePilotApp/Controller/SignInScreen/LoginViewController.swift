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
   
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
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
    
    // Login with GoogleSignIn
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
                guard let uid = authResult?.user.uid else { return }
                print("User logged in with Google UID: \(uid)")
                // AppDelegate üzerinden Core Data'ya kullanıcıyı kaydet
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.saveUserToCoreData(uid: uid)
                }
                //print("User signed in: \(authResult?.user.uid ?? "")")
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
        let navigationController = UINavigationController(rootViewController: homeViewController)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first {
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
    }
    
    // Login with Email
    @IBAction func loginPressed(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text else {
                return
            }

            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let error = error as NSError? {
                    if let errorCode = AuthErrorCode(rawValue: error.code) {
                        switch errorCode {
                        case .userNotFound:
                            self?.showAlert(title: "Error", message: "No account found for this email address. Please register.")
                        case .wrongPassword:
                            self?.showAlert(title: "Error", message: "Incorrect password. Please try again.")
                        default:
                            self?.showAlert(title: "Error", message: "An error occurred: \(error.localizedDescription)")
                        }
                    } else {
                        self?.showAlert(title: "Error", message: "An unexpected error occurred.")
                    }
                    return
                }

                // Successful login.
                guard let uid = authResult?.user.uid else { return }
                print("User logged in with UID: \(uid)")
                // AppDelegate üzerinden Core Data'ya kullanıcıyı kaydet
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.saveUserToCoreData(uid: uid)
                }

                self?.showHomeScreen()
            }
    }
    
    
    @IBAction func registerPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "fromLoginToSignUp", sender: self)
    }
    
    func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
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
