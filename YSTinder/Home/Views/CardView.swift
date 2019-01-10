//
//  CardView.swift
//  YSTinder
//
//  Created by jozen on 2019/1/9.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit
import AudioToolbox

class CardView: UIView {

    //MARK:- Properties
    var cardViewModel: CardViewModel!{
        didSet{
            didSetCardViewModel()
            setupImageIndexObserver()
        }
    }
    
    fileprivate let shouldDismissCardThreshold: CGFloat = 100
    fileprivate let imageView = UIImageView()
    fileprivate let informationLabel = UILabel()
    fileprivate let barDeselectedColor: UIColor = UIColor(white: 0, alpha: 0.1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    //MARK:- 对index的React编程
    fileprivate func setupImageIndexObserver(){
        //view的点击事件触发index改变，传到viewModel，viewModel又通过observer通知view改变图片
        //通过index改变图片和bar
        cardViewModel.imageIndexObserver = { [weak self] (index, image) in
            self?.imageView.image = image
            //set bars to the right color
            self?.barsStackView.arrangedSubviews.forEach {(bar) in
                bar.backgroundColor = self?.barDeselectedColor
            }
            self?.barsStackView.arrangedSubviews[index].backgroundColor = .white
            
            if index > 0 {
                self?.informationLabel.attributedText = self?.cardViewModel.captionString
            } else {
                self?.informationLabel.attributedText = self?.cardViewModel.attributedString
            }
        }
    }
    
    //MARK:- Layout
    
    fileprivate func didSetCardViewModel() {
        let imageName = cardViewModel.imageNames.first ?? ""
        imageView.image = UIImage(named: imageName)
        informationLabel.attributedText = cardViewModel.attributedString
        informationLabel.textAlignment = cardViewModel.textAlignment
        setupBars()
    }
    
    fileprivate func setupInformationLabel(){
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        informationLabel.textColor = .white
        informationLabel.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        informationLabel.numberOfLines = 0
    }
    
    fileprivate func setupLayout() {
        layer.cornerRadius = 10
        clipsToBounds = true
        
        setupImageView()
        addGestureToCardView()
        setupGradientLayerOnImageView() //添加底部阴影, 位于图片之上，Information之下
        setupInformationLabel()
        setupBarsStackView()
    }
    
    //顶部的图片bar
    fileprivate let barsStackView = UIStackView()
    fileprivate func setupBarsStackView(){
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
    }
    
    fileprivate func setupBars(){
        (0..<cardViewModel.imageNames.count).forEach { (_) in
            let barView = UIView()
            barView.backgroundColor = UIColor(white: 0, alpha: 0.1)
            barsStackView.addArrangedSubview(barView)
        }
        barsStackView.arrangedSubviews.first?.backgroundColor = .white
    }
    
    fileprivate func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.fillSuperview()
    }
    
    //底部的梯度阴影
    let gradientLayer = CAGradientLayer()
    fileprivate func setupGradientLayerOnImageView(){
        //颜色从clear过渡到black，程度为画面的0.5到1.1
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5,1.1]
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        // 等subView加载完毕后可以得到CardView的Frame
        // 并将阴影盖上其frame
        gradientLayer.frame = self.frame
    }
    
    //MARK:- Gesture
    fileprivate func addGestureToCardView(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        addGestureRecognizer(panGesture)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
    }
    
    //点击
    @objc fileprivate func handleTapGesture(gesture: UITapGestureRecognizer){
        let tapLocation = gesture.location(in: nil)
        let shouldNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        if shouldNextPhoto {
            cardViewModel.goToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
    }

    //拖拽
    @objc fileprivate func handlePanGesture(gesture: UIPanGestureRecognizer){
        switch gesture.state {
        case .began:
            //当开始拖拽时，移除所有card的动画
            superview?.subviews.forEach({ (subview) in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            moveCardPositionBy(gesture)
        case .ended:
            handleGestureEnded(gesture)
        default: break
        }
    }
    
    fileprivate func getNextCard() -> CardView? {
        let cards = superview?.subviews as! [CardView]
        let nextIndex = cards.count - 2
        let nextCard = nextIndex < 0 ? nil : cards[nextIndex]
        return nextCard
    }
    
    func sendLightImpact() {
        let lightImpact = UIImpactFeedbackGenerator(style: .light)
        lightImpact.impactOccurred()
    }
    
    fileprivate func handleGestureEnded(_ gesture: UIPanGestureRecognizer) {
        let shouldLike = gesture.translation(in: nil).x > shouldDismissCardThreshold
        let shouldNope = gesture.translation(in: nil).x < -shouldDismissCardThreshold
        
        if shouldLike || shouldNope {sendLightImpact()}
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            if shouldLike {
                self.frame = CGRect(x: 600, y: 0, width: self.frame.width, height: self.frame.height)
            } else if shouldNope {
                self.frame = CGRect(x: -600, y: 0, width: self.frame.width, height: self.frame.height)
            } else {
                // reset the card position
                self.transform = .identity
            }
        }, completion: { (_) in
            self.transform = .identity
            
            if shouldLike {
                self.removeFromSuperview()
            } else if shouldNope {
                self.removeFromSuperview()
            }
        })
    }
    
    fileprivate func moveCardPositionBy(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        //rotaion
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 180
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
