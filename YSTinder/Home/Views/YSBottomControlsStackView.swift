//
//  BottomControlsStackView.swift
//  YSTinder
//
//  Created by jozen on 2019/1/9.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

class YSBottomControlsStackView: UIStackView {

    let refreshButton = createButton(image: #imageLiteral(resourceName: "refresh_circle"))
    let dislikeButton = createButton(image: #imageLiteral(resourceName: "dismiss_circle"))
    let superLikeButton = createButton(image: #imageLiteral(resourceName: "super_like_circle"))
    let likeButton = createButton(image: #imageLiteral(resourceName: "like_circle"))
    let specialButton = createButton(image: #imageLiteral(resourceName: "boost_circle"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupButtons()
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        distribution = .fillEqually
    }
    
    //MARK:- UI
    func setupButtons() {
        [refreshButton, dislikeButton, superLikeButton, likeButton, specialButton].forEach { (button) in
            self.addArrangedSubview(button)
        }
    }
    
    static func createButton(image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
