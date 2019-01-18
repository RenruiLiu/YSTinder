//
//  YSLoginController.swift
//  YSTinder
//
//  Created by jozen on 2019/1/18.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit
import JGProgressHUD

protocol LoginControllerDelegate {
    func didFinishLogin()
}

class YSLoginController: UIViewController {

    //MARK:- properties
    var delegate: LoginControllerDelegate?
    
    let emailTextField: YSCustomTextField = {
        let tf = YSCustomTextField(padding: 24)
        tf.placeholder = "输入邮箱地址"
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    let passwordTextField: YSCustomTextField = {
        let tf = YSCustomTextField(padding: 24)
        tf.placeholder = "输入密码"
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登陆", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.backgroundColor = .lightGray
        button.setTitleColor(.gray, for: .disabled)
        button.isEnabled = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton
            ])
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()
    
    fileprivate let goToRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("我要注册一个账号", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleGoToRegister), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleTextChange(textField: UITextField) {
        if textField == emailTextField {
            loginViewModel.email = textField.text
        } else {
            loginViewModel.password = textField.text
        }
    }
    
    @objc fileprivate func handleLogin() {
        //收键盘
        self.view.endEditing(true)
        
        loginViewModel.performLogin { (err) in
            if let err = err {
                self.hud.hudShowError(title: "登陆失败", detail: err.localizedDescription)
                print("Failed to log in:", err)
                return
            }
            
            print("Logged in successfully")
            self.hud.dismiss()
            self.dismiss(animated: true, completion: {
                self.delegate?.didFinishLogin()
            })
        }
    }
    
    @objc fileprivate func handleGoToRegister() {
        let registerController = YSRegisterationController()
        navigationController?.pushViewController(registerController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapGesture()
        setupGradientLayer()
        setupLayout()
        setupBindables()
    }
    
    //MARK:- setups
    fileprivate func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        view.addSubview(verticalStackView)
        verticalStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30).isActive = true
        
        view.addSubview(goToRegisterButton)
        goToRegisterButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    fileprivate func setupTapGesture(){
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
    }
    
    @objc fileprivate func handleTapGesture(){
        view.endEditing(true)
    }
    
    fileprivate let loginViewModel = LoginViewModel()
    fileprivate var hud = JGProgressHUD(style: .dark)
    
    fileprivate func setupBindables() {
        loginViewModel.isFormValid.bind { [unowned self] (isFormValid) in
            guard let isFormValid = isFormValid else { return }
            self.loginButton.isEnabled = isFormValid
            self.loginButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.8235294118, green: 0, blue: 0.3254901961, alpha: 1) : .lightGray
            self.loginButton.setTitleColor(isFormValid ? .white : .gray, for: .normal)
        }
        loginViewModel.isLoggingIn.bind { [unowned self] (isRegistering) in
            if isRegistering == true {
                self.hud = showWaitingHUD(title: "登录中", detail: "", view: self.view)
            } else {
                self.hud.dismiss()
            }
        }
    }
    
    //MARK:- gradient layer
    let gradientLayer = CAGradientLayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 0.9921568627, green: 0.3568627451, blue: 0.3725490196, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8980392157, green: 0, blue: 0.4470588235, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
}
