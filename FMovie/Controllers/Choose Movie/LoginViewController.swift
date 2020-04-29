//
//  ViewController.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/19/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import UIKit
import RealmSwift

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginProcessing: UIActivityIndicatorView!
    
    var fshareManager: FshareManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        fshareManager?.delegate = self

        // Style UI after load
        styleUI()
        self.loginProcessing.startAnimating()
        self.loginProcessing.layer.cornerRadius = 10
        self.loginProcessing.backgroundColor = UIColor.gray
        self.loginProcessing.alpha = 0.7
        // Add Fshare Delegate
        
        // Load account data from Realm
        loadAccountData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loginProcessing.stopAnimating()
    }
    
    
    // MARK: - Load Account Data
    
    func loadAccountData() {
        print("Loading account data")
        let realm = try! Realm()
        let accountData = realm.objects(FshareAccount.self)
        print(accountData)
        let count = accountData.count
        if count > 0 {
            print("Checking Session")
            if let session = accountData.first?.sessionID, let token = accountData.first?.token {
                fshareManager = FshareManager(token: token, session: session)
                fshareManager?.delegate = self
                fshareManager!.checkSession()
            }
        } else {
            loginProcessing.stopAnimating()
        }
    }
    
    // MARK: - Style Login Page
    
    func styleUI() {
        let emailLine = CALayer()
        emailLine.frame = CGRect(x: emailTextField.frame.width*1/4, y: emailTextField.frame.height - 2, width: emailTextField.frame.width/2, height: 2)
        emailLine.backgroundColor = UIColor.label.cgColor
        emailTextField.layer.addSublayer(emailLine)
        
        let passwordLine = CALayer()
        passwordLine.frame = CGRect(x: passwordTextField.frame.width*1/4, y: passwordTextField.frame.height - 2, width: passwordTextField.frame.width/2, height: 2)
        passwordLine.backgroundColor = UIColor.label.cgColor
        passwordTextField.layer.addSublayer(passwordLine)
        
        loginButton.layer.cornerRadius = loginButton.frame.height/5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.label.cgColor
    }
    
    // MARK: - Button Press Animation
    func pressAnimation() {
        UIView.animate(withDuration: 0.1,
                       animations: {
                        self.loginButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            self.loginButton.transform = CGAffineTransform.identity}
        })
    }
    
    // MARK:- Login Button Pressed
    @IBAction func loginPressed(_ sender: UIButton) {
        loginProcessing.startAnimating()
        pressAnimation()
        if let email = emailTextField.text, let pass = passwordTextField.text {
            if email != "" && pass != "" {
                print("\(email) \n \(pass)")
                fshareManager = FshareManager(token: "", session: "")
                fshareManager?.delegate = self
                fshareManager?.login(email: email, pass: pass)
            }
        }
    }
    
}

    // MARK: - Fshare Manager Delegate

extension LoginViewController: FshareManagerDelegate {
    
    func loginSuccess(_ fshareManager: FshareManager, session: String, token: String) {
        print("Login Success Delegate")
        self.fshareManager?.sessionID = session
        self.fshareManager?.token = token
        let realm = try! Realm()
        let accountData = realm.objects(FshareAccount.self)
        if accountData.count == 0 {
            let data = FshareAccount()
            data.sessionID = session
            data.token = token
            do {
                try realm.write {
                    realm.add(data)
                }
            } catch {fatalError("Create Account Data Error")}
        } else {
            if let data = accountData.first {
                do {
                    try realm.write {
                        data.sessionID = session
                        data.token = token
                    }
                } catch {fatalError("Update Account Data Error")}
            }
        }
        performSegue(withIdentifier: "gotoMoviesListView", sender: nil)
    }
    
    func loginFailed(_ fshareManager: FshareManager) {
        print("Login Failed Delegate")
        let alert = UIAlertController(title: "Đăng nhập không thành công!", message: "Vui lòng kiểm tra lại email và mật khẩu.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
    func sessionIsAlive(_ fshareManager: FshareManager) {
        performSegue(withIdentifier: "gotoMoviesListView", sender: nil)
    }
    func sessionIsDead(_ fshareManager: FshareManager) {
        loginProcessing.stopAnimating()
        let alert = UIAlertController(title: "Lỗi đăng nhập", message: "Phiên đăng nhập đã hết hạn. Mời bạn đăng nhập lại.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
}

