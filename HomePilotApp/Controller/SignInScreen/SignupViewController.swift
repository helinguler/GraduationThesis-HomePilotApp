//
//  SignupViewController.swift
//  HomePilotApp
//
//  Created by Helin Güler on 12.01.2025.
//

import UIKit
import Firebase
import FirebaseAuth

class SignupViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            // User already logged in.
        }
    }
    
    func showHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // UITabBarController'ı oluştur ve içindeki viewController'ları ekle
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
                
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
            }
    }
     
    
    @IBAction func signUpPressed(_ sender: Any) {
        guard let password = passwordField.text, let confirmPassword = confirmPasswordField.text else { return }

                if password != confirmPassword {
                    showAlert(title: "Error", message: "Passwords do not match.")
                    return
                }

                if !isPasswordValid(password) {
                    showAlert(title: "Error", message: "Password must be at least 6 characters long, contain one uppercase letter, and one number.")
                    return
                }

                Auth.auth().createUser(withEmail: emailField.text!, password: password) { authResult, error in
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                        return
                    }

                    guard let uid = authResult?.user.uid else { return }
                    print("User signed up with UID: \(uid)")
                    // AppDelegate üzerinden Core Data'ya kullanıcıyı kaydet
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.saveUserToCoreData(uid: uid)
                    }
                    self.showHomeScreen()
                }
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func isPasswordValid(_ password: String) -> Bool {
            let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])[A-Za-z\\d@$!%*?&]{8,}$"
            return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
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
