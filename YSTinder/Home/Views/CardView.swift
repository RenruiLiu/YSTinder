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
    let shouldDismissCardThreshold: CGFloat = 100
    fileprivate let imageView = UIImageView(image: #imageLiteral(resourceName: "kelly3"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupImageView()
        addGesture()
    }
    
    //MARK:- Layout
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
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            if shouldLike {
                self.frame = CGRect(x: 750, y: 0, width: self.frame.width, height: self.frame.height)
            } else if shouldNope {
                self.frame = CGRect(x: -750, y: 0, width: self.frame.width, height: self.frame.height)
            } else {
                // reset the card position
                self.transform = .identity
            }
        }, completion: { (_) in
            // bring card back
            self.transform = .identity
            self.frame = CGRect(x: 0, y: 0, width: self.superview!.frame.width, height: self.superview!.frame.height)
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
