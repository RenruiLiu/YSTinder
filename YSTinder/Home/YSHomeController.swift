//
//  HomeController.swift
//  YSTinder
//
//  Created by jozen on 2019/1/9.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

class YSHomeController : UIViewController {

    //MARK:- Properties
    let topStackView = YSTopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomStackView = YSBottomControlsStackView()
    
    let cardViewModels: [YSCardViewModel] = {
        //获取一些身为Model的用户和广告，他们都通过了ProducesCardViewModel这个Protocol
        let producers = [
            YSUser(name: "Kelly", age: 23, profession: "Music DJ", imageNames: ["kelly1","kelly2","kelly3"],city:"三里屯", caption: "一个随便写的caption"),
            YSUser(name: "Jane", age: 18, profession: "Teacher", imageNames: ["jane1","jane2","jane3"], city:"暹岗村", caption: "一个随便写的caption"),
            YSAdvertiser(title: "侧滑栏", brandName: "Lets Build That App", posterPhotoName: "slide_out_menu_poster"),
            YSUser(name: "Kelly", age: 23, profession: "Music DJ", imageNames: ["kelly1"],city:"三里屯", caption: "一个随便写的caption"),
            YSUser(name: "Jane", age: 18, profession: "Teacher", imageNames: ["jane1"], city:"暹岗村", caption: "一个随便写的caption"),
            YSAdvertiser(title: "侧滑栏", brandName: "Lets Build That App", posterPhotoName: "slide_out_menu_poster")]
            as [ProducesCardViewModel]
        
        //将这些Model使用各自定义的toCardViewModel方法转成ViewModel
        let viewModels = producers.map({ (vm) -> YSCardViewModel in
            return vm.toCardViewModel()
        })
        return viewModels
    }()
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupCards()
        setupButtons()
    }

    //MARK:- UI
    fileprivate func setupCards(){
        for (_,cardVM) in cardViewModels.enumerated() {
            let cardView = YSCardView(frame: .zero)
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

    //MARK:- Button
    fileprivate func setupButtons() {
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
    }
    
    @objc fileprivate func handleSettings(){
        present(YSRegisterationController(),animated: true)
    }
    
}
