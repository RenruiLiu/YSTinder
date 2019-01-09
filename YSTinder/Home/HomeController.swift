//
//  HomeController.swift
//  YSTinder
//
//  Created by jozen on 2019/1/9.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

class HomeController : UIViewController {

    //MARK:- Properties
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomStackView = BottomControlsStackView()
    
    let cardViewModels: [CardViewModel] = {
        //获取一些身为Model的用户和广告，他们都通过了ProducesCardViewModel这个Protocol
        let producers = [
            User(name: "Kelly", age: 23, profession: "Music DJ", imageName: "kelly1",city:"三里屯"),
            User(name: "Jane", age: 18, profession: "Teacher", imageName: "jane1", city:"暹岗村"),
            Advertiser(title: "侧滑栏", brandName: "Lets Build That App", posterPhotoName: "slide_out_menu_poster")]
            as [ProducesCardViewModel]
        
        //将这些Model使用各自定义的toCardViewModel方法转成ViewModel
        let viewModels = producers.map({ (vm) -> CardViewModel in
            return vm.toCardViewModel()
        })
        return viewModels
    }()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupCards()
    }

    //MARK:- UI
    fileprivate func setupCards(){
        cardViewModels.forEach { (cardVM) in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardVM
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
        
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
