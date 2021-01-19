//
//  LoginVC.swift
//  CarWash
//
//  Created by Himanshu Joshi on 04/01/21.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField
import FirebaseFirestore

class LoginVC: UIViewController {
    
    var emailArray = [String]()
    
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.color = .black
        return spinner
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Socio"
        label.textColor = .black
        label.font = UIFont(name: "Noteworthy-Bold", size: 35.0)
        return label
    }()
    
    let emailTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "Email"
        textField.selectedTitleColor = .black
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    let passwordTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "Password"
        textField.selectedTitleColor = .black
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let loginBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("LOGIN", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 25.0)
        button.layer.cornerRadius = 8.0
        button.layer.shadowColor = #colorLiteral(red: 1, green: 0.7764705882, blue: 0, alpha: 1)
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 1.0
        button.backgroundColor = #colorLiteral(red: 1, green: 0.7764705882, blue: 0, alpha: 1)
        button.tintColor = .black
        return button
    }()
    
    @objc func login() {
        
        spinner.startAnimating()
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            spinner.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "Please fill all the fields to continue login.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let email = emailTextField.text , let password = passwordTextField.text else { return }
        
        Firestore.firestore().collection("workers").getDocuments { (snapshot, error) in
            if let error = error {
                self.spinner.stopAnimating()
                print(error.localizedDescription)
            }
            let documents = snapshot?.documents
            for document in documents! {
                let data = document.data()
                let usedEmail = data["email"] as? String ?? ""
                self.emailArray.append(usedEmail)
            }
                
            if self.emailArray.contains(email) {
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if (user != nil) {
                        let currentUser = Auth.auth().currentUser
                        switch currentUser?.isEmailVerified {
                        case true:
                            self.spinner.stopAnimating()
                            Firestore.firestore().collection("workers").document((currentUser?.uid)!).getDocument { (snapshot, error) in
                                    if let error = error {
                                        print("Error while logging in, \(error.localizedDescription)")
                                    }
                                    if snapshot?.data()!["location"] as! String == "" {
                                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NavigationController")
                                        UIApplication.shared.keyWindow?.rootViewController = nextViewController
                                        UIApplication.shared.keyWindow?.makeKeyAndVisible()
                                    } else {
                                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NavigationController2")
                                        UIApplication.shared.keyWindow?.rootViewController = nextViewController
                                        UIApplication.shared.keyWindow?.makeKeyAndVisible()
                                    }
                                }

                        case false:
                            currentUser?.sendEmailVerification(completion: { (error) in
                                if let error = error {
                                    self.spinner.stopAnimating()
                                    print("Error while sending email verification, \(error.localizedDescription)")
                                }
                                self.spinner.stopAnimating()
                                let alert = UIAlertController(title: "Error", message: "Please verify your email first. We have sent an email verification link in your Gmail account.", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                                return
                            })
                        default:
                            self.spinner.stopAnimating()
                            print("verified")
                        }
                    } else {
                        self.spinner.stopAnimating()
                        let alert = UIAlertController(title: "Error", message: "Incorrect Password. Please try again.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
            } else {
                self.spinner.stopAnimating()
                let alert = UIAlertController(title: "Error", message: "This email do not corresponds to our database. Please check your email and try again.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
            
    let forgotPassBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir", size: 18.0)
        button.tintColor = .systemBlue
        return button
    }()
    
    @objc func forgotPass() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ForgotPasswordVC") as? ForgotPasswordVC
        self.present(nextViewController!, animated:true, completion:nil)
    }
    
    let signUplabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account? "
        label.font = UIFont(name: "Avenir", size: 18.0)
        label.textColor = .black
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let signUpBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Signup here", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 18.0)
        button.tintColor = .systemBlue
        return button
    }()
    
    @objc func signUp() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignUpVC") as? SignUpVC
        self.present(nextViewController!, animated:true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        self.view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100.0).isActive = true
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0.0).isActive = true
        
        self.view.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20.0).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
      
        self.view.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20.0).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
        
        self.view.addSubview(forgotPassBtn)
        forgotPassBtn.translatesAutoresizingMaskIntoConstraints = false
        forgotPassBtn.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20.0).isActive = true
        forgotPassBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0).isActive = true
        forgotPassBtn.addTarget(self, action: #selector(forgotPass), for: .touchUpInside)

        self.view.addSubview(loginBtn)
        loginBtn.translatesAutoresizingMaskIntoConstraints = false
        loginBtn.topAnchor.constraint(equalTo: forgotPassBtn.bottomAnchor, constant: 20.0).isActive = true
        loginBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0).isActive = true
        loginBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
        loginBtn.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        loginBtn.addTarget(self, action: #selector(login), for: .touchUpInside)

        self.view.addSubview(signUplabel)
        signUplabel.translatesAutoresizingMaskIntoConstraints = false
        signUplabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30.0).isActive = true
        signUplabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -60.0).isActive = true

        self.view.addSubview(signUpBtn)
        signUpBtn.translatesAutoresizingMaskIntoConstraints = false
        signUpBtn.centerYAnchor.constraint(equalTo: signUplabel.centerYAnchor, constant: 0.0).isActive = true
        signUpBtn.leadingAnchor.constraint(equalTo: signUplabel.trailingAnchor, constant: 0.0).isActive = true
        signUpBtn.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(disissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func disissKeyboard() {
        view.endEditing(true)
    }

}
