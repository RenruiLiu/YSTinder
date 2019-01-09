//
//  CardViewModel.swift
//  YSTinder
//
//  Created by jozen on 2019/1/9.
//  Copyright © 2019 liurenrui. All rights reserved.
//  这个ViewModel用于定义 一个Model中一切需要展示在View上的内容

import UIKit

// 通过这个Protocol声明所有Model都有转成CardViewModel的方法
protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

struct CardViewModel {
    
    //MARK:- Properties
    let imageName: String
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
}
