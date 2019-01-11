//
//  RegisterationController.swift
//  YSTinder
//
//  Created by jozen on 2019/1/11.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

class YSRegisterationController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientLayer()
        setupLayout()
        setupNotificationObservers()
        setupTapGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //在整个view设置好，开始布置subviews之前
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //这时设置layer的frame可以让它布满整个view(包括水平方向)
        gradientLayer.frame = view.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.verticalSizeClass == .compact {
            overallStackView.axis = .horizontal
        } else {
            overallStackView.axis = .vertical
        }
    }

    //MARK:- UI components
    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("选择照片", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 275).isActive = true
        button.widthAnchor.constraint(equalToConstant: 275).isActive = true
        button.layer.cornerRadius = 16
        return button
    }()
    
    
    let fullNameTextField: YSCustomTextField = {
        let tf = YSCustomTextField(padding: 16)
        tf.placeholder = "输入名字"
        return tf
    }()
    
    let emailTextField: YSCustomTextField = {
        let tf = YSCustomTextField(padding: 16)
        tf.placeholder = "输入邮箱"
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    let passwordTextField: YSCustomTextField = {
        let tf = YSCustomTextField(padding: 16)
        tf.placeholder = "输入密码"
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 25
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("注册", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.8132490516, green: 0.09731306881, blue: 0.3328936398, alpha: 1)
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return btn
    }()
    
    lazy var overallStackView = UIStackView(arrangedSubviews: [
        selectPhotoButton,
        verticalStackView
        ])
    
    lazy var verticalStackView: UIStackView = {
        let vsv = UIStackView(arrangedSubviews: [
        fullNameTextField,
        emailTextField,
        passwordTextField,
        registerButton
        ])
        vsv.axis = .vertical
        vsv.distribution = .fillEqually
        vsv.spacing = 8
        return vsv
    }()
    
    fileprivate func setupLayout() {
        view.addSubview(overallStackView)
        overallStackView.axis = .vertical
        overallStackView.spacing = 8
        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
    }
    
    let gradientLayer = CAGradientLayer()
    
    fileprivate func setupGradientLayer(){
        let topColor = #colorLiteral(red: 0.9927458167, green: 0.3810226917, blue: 0.3745030165, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8867512941, green: 0.1122735515, blue: 0.4637197256, alpha: 1)
        gradientLayer.colors = [topColor.cgColor,bottomColor.cgColor]
        gradientLayer.locations = [0,1]
        view.layer.addSublayer(gradientLayer)
    }

    //MARK:- Keyboard management
    fileprivate func setupNotificationObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc fileprivate func handleKeyboardShow(notification: Notification){
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = value.cgRectValue
        
        // 从注册按钮到屏幕底的距离 = 屏幕高 - 屏幕顶部到stackView的顶点的距离 - stackView的高
        let bottomSpace = view.frame.height - overallStackView.frame.origin.y - overallStackView.frame.height
        // 屏幕需要抬高的距离 = 键盘的高 - 注册按钮到屏幕底的距离 （键盘刚好到注册按钮的底部）
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 10)
    }
    
    fileprivate func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismissKeyboard)))
    }
    
    @objc fileprivate func handleTapDismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc fileprivate func handleKeyboardHide(notification: Notification){
        self.view.transform = CGAffineTransform(translationX: 0, y: 0)
    }
}
