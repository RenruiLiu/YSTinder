//
//  YSUserDetailsViewController.swift
//  YSTinder
//
//  Created by jozen on 2019/1/21.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

class YSUserDetailsViewController: UIViewController, UIScrollViewDelegate {

    var cardViewModel: YSCardViewModel!{
        didSet{
            infoLabel.attributedText = cardViewModel.attributedString
            swipingPhotosController.cardViewModel = cardViewModel
        }
    }
    
    //MARK:- 控件
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.alwaysBounceVertical = true
        // bounce会把图片下推到safe area的下面，设置下一行代码可以把图片重新推回到status bar上
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    let swipingPhotosController = YSSwipingPhotoController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "dismiss_down_arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleTapDismiss), for: .touchUpInside)
        return btn
    }()
    
    lazy var dislikeButton = self.createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDislike))
    lazy var superLikeButton = self.createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleSuperlike))
    lazy var likeButton = self.createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleLike))
    
    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton{
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    @objc fileprivate func handleTapDismiss(){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupVisualBlurEffectView()
    }
    
    //MARK:- 布局
    fileprivate func setupVisualBlurEffectView(){
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    fileprivate func setupLayout(){
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        let swipingView = swipingPhotosController.view!
        scrollView.addSubview(swipingView)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        scrollView.addSubview(dismissButton)
        dismissButton.anchor(top: swipingView.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 24), size: .init(width: 50, height: 50))
        
        // 底下一排按钮
        let stackView = UIStackView(arrangedSubviews: [dislikeButton, superLikeButton, likeButton])
        stackView.spacing = -32
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    // 增高pageView
    fileprivate let extraSwipingHeight: CGFloat = 80
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 在设置layoutSubviews时，swipingPhotosController才知道view.frame的具体属性。
        // 否则它将显示整个屏幕大小
        let swipingView = swipingPhotosController.view!
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)
    }
    
    //MARK:- scroll view
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // contentOffset: 拉拽偏移的程度，y往下拉是负数
        let changeY = -scrollView.contentOffset.y
        
        if changeY < 0 {return} //如果向上拉则不变
        
        // 例：向下拉了50度，则图片向左50度，宽度增加100度，向上50度，高度增加100度。所以看起来是按比例放大了
        let width: CGFloat = view.frame.width + changeY * 2
        let imageView = swipingPhotosController.view!
        imageView.frame = CGRect(x: -changeY, y: -changeY, width: width, height: width + extraSwipingHeight)
    }
    
    //MARK:- handle buttons
    @objc fileprivate func handleDislike(){}
    @objc fileprivate func handleSuperlike(){}
    @objc fileprivate func handleLike(){}
}
