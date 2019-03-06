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

class YSHomeController : UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate {
    
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
        setupBottomButtons()
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
        var prevCardView: YSCardView?
        
        for (_,cardVM) in cardViewModels.enumerated() {
            let cardView = YSCardView(frame: .zero)
            cardView.delegate = self
            cardView.cardViewModel = cardVM
            cardsDeckView.insertSubview(cardView, at: 0)
            cardView.fillSuperview()
            
            //给每个卡都赋值给上一张卡的nextCardView属性
            prevCardView?.nextCardView = cardView
            prevCardView = cardView
            if self.topCardView == nil {
                self.topCardView = cardView
            }
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
    fileprivate func setupBottomButtons() {
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomStackView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomStackView.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomStackView.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
    }
    
    var topCardView: YSCardView?
    
    //点击不喜欢按钮
    @objc fileprivate func handleDislike(){
        saveSwipeToFirestore(WithCardView: topCardView, like: false)
        animateRemoveCard(toLike: false)
    }
    //点击喜欢按钮
    @objc fileprivate func handleLike(){
        saveSwipeToFirestore(WithCardView: topCardView, like: true)
        animateRemoveCard(toLike: true)
    }
    
    fileprivate func animateRemoveCard(toLike like: Bool){
        let duration = 0.5
        let delta : CGFloat = like ? 1 : -1 //决定向左或右边
        
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = delta * 700
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = delta * 15 * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        //在点击（还未开始动画时就已经）把下一张卡赋值到最上卡
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            //动画完成后移除此卡
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
    }
    
    //左右滑动移除卡片，下一张卡赋值到最上卡
    func didRemoveCard(cardView: YSCardView,like: Bool) {
        topCardView?.removeFromSuperview()
        saveSwipeToFirestore(WithCardView: topCardView, like: like)
        topCardView = topCardView?.nextCardView
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
    
    // 更多信息页面
    func didTapMoreInfoBtn(cardViewModel: YSCardViewModel) {
        let userDetailController = YSUserDetailsViewController()
        userDetailController.cardViewModel = cardViewModel
        present(userDetailController, animated: true, completion: nil)
    }
    
    // 代理方法：当设置完成后，刷新页面获取用户
    func didSaveSettings() {
        fetchUsers_setupCards()
    }
    
    //MARK:- 网络
    //获取currentUser，获取其他卡片，刷新页面
    fileprivate func fetchUsers_setupCards(){
        let refreshingHUD = showWaitingHUD(title: "刷新中", detail: "正在获取新用户", view: view)
        
        topCardView = nil; //当重新从网络下载卡片，顶卡清空以便赋值给下一张新卡。
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
