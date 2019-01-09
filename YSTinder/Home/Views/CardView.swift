//
//  CardView.swift
//  YSTinder
//
//  Created by jozen on 2019/1/9.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

class CardView: UIView {

    //MARK:- Properties
    var cardViewModel: CardViewModel!{
        didSet{
            imageView.image = UIImage(named: cardViewModel.imageName)
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
        }
    }
    
    fileprivate let shouldDismissCardThreshold: CGFloat = 100
    fileprivate let imageView = UIImageView()
    fileprivate let informationLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupImageView()
        addGesture()
        setupInformationLabel()
    }
    
    //MARK:- Layout
    
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
    }
    
    fileprivate func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.fillSuperview()
    }
    
    //MARK:- Gesture
    fileprivate func addGesture(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        addGestureRecognizer(panGesture)
    }

    @objc fileprivate func handlePanGesture( gesture: UIPanGestureRecognizer){
        switch gesture.state {
        case .changed:
            moveCardPositionBy(gesture)
        case .ended:
            handleGestureEnded(gesture)
        default: break
        }
    }
    
    fileprivate func handleGestureEnded(_ gesture: UIPanGestureRecognizer) {
        let shouldLike = gesture.translation(in: nil).x > shouldDismissCardThreshold
        let shouldNope = gesture.translation(in: nil).x < -shouldDismissCardThreshold
        
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
