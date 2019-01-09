//
//  TopNavigationStackView.swift
//  YSTinder
//
//  Created by jozen on 2019/1/9.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

class TopNavigationStackView: UIStackView {
    
    let settingsButton = createButton(image: #imageLiteral(resourceName: "top_left_profile"))
    let fireImageView = UIImageView(image: #imageLiteral(resourceName: "app_icon"))
    let messageButton = createButton(image: #imageLiteral(resourceName: "top_right_messages"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //setup UI
        setupViews()
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        distribution = .equalCentering
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    //MARK:- UI
    func setupViews() {
        fireImageView.contentMode = .scaleAspectFit
        [settingsButton, UIView(), fireImageView, UIView(), messageButton].forEach { (v) in
            addArrangedSubview(v)
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
