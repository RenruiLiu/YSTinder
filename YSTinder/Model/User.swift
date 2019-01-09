//
//  User.swift
//  YSTinder
//
//  Created by jozen on 2019/1/9.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

struct User: ProducesCardViewModel {
    // properties
    let name: String
    let age: Int
    let profession: String
    let imageName: String
    let city: String
    
    //将一个User中需要展示到View的内容都转成一个ViewModel
    func toCardViewModel() -> CardViewModel{
        let attributedText = NSMutableAttributedString(string: name, attributes: [.font:UIFont.systemFont(ofSize: 32, weight: .heavy)])
        attributedText.append(NSAttributedString(string: "  \(age)", attributes: [.font:UIFont.systemFont(ofSize: 24, weight: .regular)]))
        attributedText.append(NSAttributedString(string: "\n\(profession)", attributes: [.font:UIFont.systemFont(ofSize: 20, weight: .regular)]))
        attributedText.append(NSAttributedString(string: "\n\(city)", attributes: [.font:UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        return CardViewModel(imageName: imageName, attributedString: attributedText, textAlignment: .left)
    }
}
