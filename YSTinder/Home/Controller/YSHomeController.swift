//
//  HomeController.swift
//  YSTinder
//
//  Created by jozen on 2019/1/9.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class YSHomeController : UIViewController, SettingsControllerDelegate, LoginControllerDelegate {

    //MARK:- Properties
    let topStackView = YSTopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomStackView = YSBottomControlsStackView()
    var cardViewModels = [YSCardViewModel]()
    
    var currentUser: YSUser?
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUsers_setupCards()
        setupLayout()
        setupButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //如果没有登录，跳转到注册页面
        if Auth.auth().currentUser == nil {
            navToLoginController()
        }
    }
    
    fileprivate func navToLoginController() {
        let loginController = YSLoginController()
        loginController.delegate = self
        let navController = UINavigationController(rootViewController: loginController)
        present(navController, animated: true, completion: nil)
    }

    //MARK:- UI
    fileprivate func setupCards(){
        for (_,cardVM) in cardViewModels.enumerated() {
            let cardView = YSCardView(frame: .zero)
            cardView.cardViewModel = cardVM
            cardsDeckView.insertSubview(cardView, at: 0)
            cardView.fillSuperview()
        }
    }
    
    fileprivate func setupLayout(){
        
        view.backgroundColor = .white
        
        //stackView
        let stackView = UIStackView(arrangedSubviews: [topStackView,cardsDeckView,bottomStackView])
        stackView.axis = .vertical
        
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 0, left: 6, bottom: 0, right: 6)
        
        stackView.bringSubviewToFront(cardsDeckView)
    }

    //MARK:- Button
    fileprivate func setupButtons() {
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomStackView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    }
    
    @objc fileprivate func handleSettings(){
        let settingsVC = YSSettingsController()
        settingsVC.currentUser = currentUser
        settingsVC.delegate = self
        present(UINavigationController(rootViewController: settingsVC), animated: true, completion: nil)
    }
    
    @objc fileprivate func handleRefresh(){
        fetchUsers_setupCards()
    }
    
    // 代理方法：当设置完成后，刷新页面获取用户
    func didSaveSettings() {
        fetchUsers_setupCards()
    }
    
    //MARK:- 网络
    //获取currentUser，获取其他卡片，刷新页面
    fileprivate func fetchUsers_setupCards(){
        let refreshingHUD = showWaitingHUD(title: "刷新中", detail: "正在获取新用户", view: view)
        
        fetchCurrentUser { (user) in
            self.currentUser = user
            fetchUsersFromFirestore(currentUser: user) { [weak self] (viewModels) in
                self?.cardViewModels = viewModels
                self?.setupCards()
                refreshingHUD.dismiss(animated: true)
            }
        }
    }
    
    // 完成login后，fetch用户fetch卡片
    func didFinishLogin(){
        fetchUsers_setupCards()
    }
}
