//
//  SignUpVC.swift
//  CarWash
//
//  Created by Himanshu Joshi on 04/01/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import SkyFloatingLabelTextField

class SignUpVC: UIViewController {
    
    var emailArray = [String]()
    var usersEmailArray = [String]()
    
    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.color = .black
        return spinner
    }()
    
    var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Create User"
        label.textColor = .black
        label.font = UIFont(name: "Noteworthy-Bold", size: 35.0)
        return label
    }()
    
    let nameTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "Full Name"
        textField.selectedTitleColor = .black
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    let ageTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "Age"
        textField.selectedTitleColor = .black
        return textField
    }()
    
    let cityTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "City"
        textField.selectedTitleColor = .black
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    let phoneTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "Phone"
        textField.selectedTitleColor = .black
        textField.keyboardType = .emailAddress
        return textField
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
    
    let confirmPasswordTextField: SkyFloatingLabelTextField = {
        let textField = SkyFloatingLabelTextField()
        textField.placeholder = "Confirm Password"
        textField.selectedTitleColor = .black
        textField.isSecureTextEntry = true
        return textField
    }()

    let signUpBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGNUP", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 25.0)
        button.layer.cornerRadius = 8.0
        button.layer.shadowColor = #colorLiteral(red: 1, green: 0.7764705882, blue: 0, alpha: 1)
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 1.0
        button.backgroundColor = #colorLiteral(red: 1, green: 0.7764705882, blue: 0, alpha: 1)
        button.tintColor = .black
        return button
    }()
    
    @objc func createUser(_ sender: UIButton) {
        
        spinner.startAnimating()
        
        guard let name = nameTextField.text, let age = ageTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text, let city = cityTextField.text, let phone = phoneTextField.text else { return }
        
        if name == "" || age == "" || email == "" || password == "" || confirmPassword == "" || city == "" || phone == "" {
            spinner.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "Please fill up all the mandatory fields to procedd.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        } else if password != confirmPassword {
            spinner.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "Entered password and confirm password are not same.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        } else if password.count <= 5 {
            spinner.stopAnimating()
            let alert = UIAlertController(title: "Error", message: "Password must be 6 letters or more than 6 letters long.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        } else {
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

                Firestore.firestore().collection("users").getDocuments { (snap, error) in
                    if let error = error {
                        self.spinner.stopAnimating()
                        print(error.localizedDescription)
                    }
                    let docs = snap?.documents
                    for doc in docs! {
                        let data = doc.data()
                        let usedEmail = data["email"] as? String ?? ""
                        self.usersEmailArray.append(usedEmail)
                    }
                    
                    if self.emailArray.contains(email) || self.usersEmailArray.contains(email) {
                        self.spinner.stopAnimating()
                        let alert = UIAlertController(title: "Error", message: "Email is already taken. Please try another one.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.saveData()
                    }
                    
                }
                    
            }
        }
    }
    
    func saveData() {

        guard let name = nameTextField.text, let age = ageTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let city = cityTextField.text, let phone = phoneTextField.text else { return }

        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.spinner.stopAnimating()
                debugPrint("Error while creating user, \(error.localizedDescription)")
            }
            
            guard let userId = user?.user.uid else { return }
            Firestore.firestore().collection("workers").document(userId).setData([
                "name" : name,
                "age" : age,
                "email" : email,
                "city" : city,
                "phone" : phone,
                "servicesDone" : 0,
                "location" : ""
                ], completion: { (error) in
                    if let error = error {
                        self.spinner.stopAnimating()
                        debugPrint(error.localizedDescription)
                        print("Error while creating user")
                    } else {
                        let currentUser = Auth.auth().currentUser
                        currentUser?.sendEmailVerification(completion: { (error) in
                            if let error = error {
                                self.spinner.stopAnimating()
                                print("Error while sending email verification, \(error.localizedDescription)")
                            }
                            self.spinner.stopAnimating()
                            let alert = UIAlertController(title: "Success", message: "Account created successfully. Check your Gmail to verify your account. An email verification link is sent there.", preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                                self.dismiss(animated: true, completion: nil)
                            })
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        })
                        
                    }
            })
            
        }

    }
    
    let signInlabel: UILabel = {
        let label = UILabel()
        label.text = "Already have an account? "
        label.font = UIFont(name: "Avenir", size: 18.0)
        label.textColor = .black
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let signInBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login here", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 18.0)
        button.tintColor = .systemBlue
        return button
    }()
    
    @objc func signUp() {
        self.dismiss(animated: true, completion: nil)
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
        label.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30.0).isActive = true
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0.0).isActive = true
        
        self.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: self.label.bottomAnchor, constant: 20.0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.scrollView.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.isUserInteractionEnabled = true
        nameTextField.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        nameTextField.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 20.0).isActive = true
        nameTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
        
        self.scrollView.addSubview(ageTextField)
        ageTextField.translatesAutoresizingMaskIntoConstraints = false
        ageTextField.isUserInteractionEnabled = true
        ageTextField.topAnchor.constraint(equalTo: self.nameTextField.bottomAnchor, constant: 10.0).isActive = true
        ageTextField.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 20.0).isActive = true
        ageTextField.trailingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -5.0).isActive = true
        
        self.scrollView.addSubview(phoneTextField)
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        phoneTextField.isUserInteractionEnabled = true
        phoneTextField.topAnchor.constraint(equalTo: self.nameTextField.bottomAnchor, constant: 10.0).isActive = true
        phoneTextField.leadingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 5.0).isActive = true
        phoneTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
        
        self.scrollView.addSubview(cityTextField)
        cityTextField.translatesAutoresizingMaskIntoConstraints = false
        cityTextField.isUserInteractionEnabled = true
        cityTextField.topAnchor.constraint(equalTo: self.ageTextField.bottomAnchor, constant: 10.0).isActive = true
        cityTextField.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 20.0).isActive = true
        cityTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
        
        self.scrollView.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.isUserInteractionEnabled = true
        emailTextField.topAnchor.constraint(equalTo: self.cityTextField.bottomAnchor, constant: 10.0).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 20.0).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
        
        self.scrollView.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.isUserInteractionEnabled = true
        passwordTextField.topAnchor.constraint(equalTo: self.emailTextField.bottomAnchor, constant: 10.0).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 20.0).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
        
        self.scrollView.addSubview(confirmPasswordTextField)
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.isUserInteractionEnabled = true
        confirmPasswordTextField.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant: 10.0).isActive = true
        confirmPasswordTextField.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 20.0).isActive = true
        confirmPasswordTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
        
        self.scrollView.addSubview(signUpBtn)
        signUpBtn.translatesAutoresizingMaskIntoConstraints = false
        signUpBtn.isUserInteractionEnabled = true
        signUpBtn.topAnchor.constraint(equalTo: self.confirmPasswordTextField.bottomAnchor, constant: 40.0).isActive = true
        signUpBtn.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 20.0).isActive = true
        signUpBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
        signUpBtn.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        signUpBtn.addTarget(self, action: #selector(createUser(_:)), for: .touchUpInside)
        
        self.scrollView.addSubview(signInlabel)
        signInlabel.translatesAutoresizingMaskIntoConstraints = false
        signInlabel.topAnchor.constraint(equalTo: self.signUpBtn.bottomAnchor, constant: 20.0).isActive = true
        signInlabel.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: -30.0).isActive = true
        signInlabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -60.0).isActive = true

        self.scrollView.addSubview(signInBtn)
        signInBtn.translatesAutoresizingMaskIntoConstraints = false
        signInBtn.centerYAnchor.constraint(equalTo: signInlabel.centerYAnchor, constant: 0.0).isActive = true
        signInBtn.leadingAnchor.constraint(equalTo: signInlabel.trailingAnchor, constant: 0.0).isActive = true
        signInBtn.addTarget(self, action: #selector(signUp), for: .touchUpInside)
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
