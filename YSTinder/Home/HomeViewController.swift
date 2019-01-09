//
//  ViewController.swift
//  YSTinder
//
//  Created by jozen on 2019/1/9.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

class HomeViewController : UIViewController {

    //MARK:- Properties
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomStackView = BottomControlsStackView()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupCards()
    }

    //MARK:- UI
    fileprivate func setupCards(){
        let cardView = CardView(frame: .zero)
        cardsDeckView.addSubview(cardView)
        cardView.fillSuperview()
    }
    
    fileprivate func setupLayout(){
        
        //stackView
        let stackView = UIStackView(arrangedSubviews: [topStackView,cardsDeckView,bottomStackView])
        stackView.axis = .vertical
        
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 0, left: 6, bottom: 0, right: 6)
        
        stackView.bringSubviewToFront(cardsDeckView)
    }

}
