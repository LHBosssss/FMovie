//
//  ViewController.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/19/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Style UI after load
        styleUI()
    }
    
    // MARK: - Style Login Page
    
    func styleUI() {
        let emailLine = CALayer()
        emailLine.frame = CGRect(x: emailTextField.frame.width*1/8, y: emailTextField.frame.height - 2, width: emailTextField.frame.width*3/4, height: 2)
        emailLine.backgroundColor = UIColor.label.cgColor
        emailTextField.layer.addSublayer(emailLine)
        
        let passwordLine = CALayer()
        passwordLine.frame = CGRect(x: passwordTextField.frame.width*1/8, y: passwordTextField.frame.height - 2, width: passwordTextField.frame.width*3/4, height: 2)
        passwordLine.backgroundColor = UIColor.label.cgColor
        passwordTextField.layer.addSublayer(passwordLine)
        
        loginButton.layer.cornerRadius = 25
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.label.cgColor
    }
    
    // MARK:- Login Button Pressed
    @IBAction func loginPressed(_ sender: UIButton) {
    }
    
}

