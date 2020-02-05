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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Login ViewController opened")
        
        switch Int.random(in: 0...10) {
        case 3:
            backgroundStuff.image = UIImage(named: "CowboyBlonde")
        case 5:
            backgroundStuff.image = UIImage(named: "CowboyRed")
        case 7:
            backgroundStuff.image = UIImage(named: "DallasCowboys")
        case 9:
            backgroundStuff.image = UIImage(named: "SchamelessPlug")
            
        default:
            backgroundStuff.image = UIImage(named: "background")
        }
        
        
        
    }
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        print("register button tapped")
    }
    
}
