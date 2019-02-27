//
//  RegisterationController.swift
//  YSTinder
//
//  Created by jozen on 2019/1/11.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD


class YSRegisterationController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientLayer()
        setupLayout()
        setupTapGesture()
        setupRegisterationViewModelBindables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNotificationObservers()
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
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    
    let nameTextField: YSCustomTextField = {
        let tf = YSCustomTextField(padding: 16)
        tf.placeholder = "输入名字"
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let emailTextField: YSCustomTextField = {
        let tf = YSCustomTextField(padding: 16)
        tf.placeholder = "输入邮箱"
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)

        return tf
    }()
    
    let passwordTextField: YSCustomTextField = {
        let tf = YSCustomTextField(padding: 16)
        tf.placeholder = "输入密码"
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 25
        btn.setTitle("注册", for: .normal)
        btn.backgroundColor = .lightGray
        btn.setTitleColor(.gray, for: .disabled)
        btn.isEnabled = false
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return btn
    }()
    
    lazy var overallStackView = UIStackView(arrangedSubviews: [
        selectPhotoButton,
        verticalStackView
        ])
    
    lazy var verticalStackView: UIStackView = {
        let vsv = UIStackView(arrangedSubviews: [
        nameTextField,
        emailTextField,
        passwordTextField,
        registerButton
        ])
        vsv.axis = .vertical
        vsv.distribution = .fillEqually
        vsv.spacing = 8
        return vsv
    }()
    
    let goToLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("我有账号了，去登陆", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.addTarget(self, action: #selector(handleGoToLogin), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleGoToLogin(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func handleSelectPhoto(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    //每次在textfield输入，都将text传给viewModel
    @objc fileprivate func handleTextChange(textField: UITextField){
        if textField == nameTextField{
            registeraionViewModel.name = textField.text
        } else if textField == emailTextField {
            registeraionViewModel.email = textField.text
        } else if textField == passwordTextField {
            registeraionViewModel.password = textField.text
        }
    }
    
    fileprivate func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        
        view.addSubview(overallStackView)
        overallStackView.axis = .vertical
        overallStackView.spacing = 8
        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        
        view.addSubview(goToLoginButton)
        goToLoginButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    let gradientLayer = CAGradientLayer()
    
    fileprivate func setupGradientLayer(){
        gradientLayer.colors = [Constants.gradientTopColor.cgColor,Constants.gradientBottomColor.cgColor]
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
    
    //MARK:- Registeration
    var registeringHUD = JGProgressHUD(style: .dark)
    
    @objc fileprivate func handleRegister(){
        //收键盘
        self.view.endEditing(true)
        
        // register to firebase
        registeraionViewModel.performRegisteration { (err) in
            if let err = err {
                showErrorHUD(title: "注册失败", detail: err.localizedDescription, view: self.view)
                return
            }
            
            self.registeringHUD.dismiss()
            self.dismiss(animated: true)
        }
    }
    
    let registeraionViewModel = RegisterationViewModel()
    
    // 在启动时设置好的bindable在之后变量的didSet中调用到时都会启用bind方法
    fileprivate func setupRegisterationViewModelBindables(){
        
        // 使用bind方法中的闭包获得isFormValid，以决定UI显示
        registeraionViewModel.bindableIsFormValid.bind(observer: { [weak self] (isFormValid) in
            guard let isFormValid = isFormValid else {return}
            self?.registerButton.isEnabled = isFormValid
            self?.registerButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.8132490516, green: 0.09731306881, blue: 0.3328936398, alpha: 1) : .lightGray
            if isFormValid {
                self?.registerButton.setTitleColor(.white, for: .normal)
            } else {
                self?.registerButton.setTitleColor(.gray, for: .disabled)
            }
        })
    
        registeraionViewModel.bindableImage.bind(observer: { [weak self] (image) in
            self?.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        })
        
        registeraionViewModel.bindableIsRegistering.bind { [unowned self] (isRegistering) in
            if isRegistering == true {
                self.registeringHUD = showWaitingHUD(title: "注册中", detail: "", view: self.view)
            } else {
                self.registeringHUD.dismiss(animated: true)
            }
        }
    }
}

extension YSRegisterationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        registeraionViewModel.bindableImage.value = info[.originalImage] as? UIImage
        registeraionViewModel.checkIsFormValid()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
