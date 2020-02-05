//
//  LoginViewController.swift
//  BSVBattleRoyale
//
//  Created by John Pitts on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerLoginButton: UIButton!
    @IBOutlet weak var backgroundStuff: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var signInType: SignInType = .login
    
    enum SignInType {
        case register
        case login
    }
    
    var loginController = LoginController()
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        print("register button tapped")
        
        if segmentedControl.selectedSegmentIndex == 0 {
            signInType = .register
            registerLoginButton.setTitle("Register", for: .normal)
            
        } else {
            signInType = .login
            registerLoginButton.setTitle("Login", for: .normal)
            
        }
        
        
        
    }
    
    
    func registerUser() {
        
        guard let username = usernameTextField.text,
            let password = passwordTextField.text else { return }
        
                switch signInType {
                    
                case .register:
                    
                    print("not using signUp right now")
                    
                    loginController?.signUp(with: username, password: password, completion: { (error) in
        
                        if let error = error {
                            NSLog("Error signing up: \(error)")
                        } else {
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "Sign Up Successful", message: "Now please log in.", preferredStyle: .alert)
                                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(alertAction)
                                self.present(alertController, animated: true, completion: {
                                    self.signInType = .logIn
                                    self.loginTypeSegmentedControl.selectedSegmentIndex = 1
                                    self.signInButton.setTitle("Sign In", for: .normal)
                                })
                            }
                        }
                    })
                    
                case .login:
                    
                    LoginController.automatedLoginSuccess()
                    

                        navigationController?.popViewController(animated: true)
                    
        //            jokeController.logIn(with: username, password: password, completion: { (error) in
        //                if let error = error {
        //                    NSLog("Error logging in: \(error)")
        //                } else {
        //                    DispatchQueue.main.async {
        //                        self.dismiss(animated: true, completion: nil)
        //                    }
        //                }
        //            })
                }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Login ViewController opened")
        
        switch Int.random(in: 0...10) {
        case 3:
            backgroundStuff.image = UIImage(named: "CowboyBlonde")
            print("cb")
        case 5:
            backgroundStuff.image = UIImage(named: "CowboyRed")
            print("cr")
        case 7:
            backgroundStuff.image = UIImage(named: "DallasCowboys")
            print("DC")
        case 9:
            backgroundStuff.image = UIImage(named: "SchamelessPlug")
            print("shamelessly")
            
        default:
            backgroundStuff.image = UIImage(named: "background")
            print("background")
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
