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
    func toCardViewModel() -> YSCardViewModel
}

class YSCardViewModel {
    
    //MARK:- Properties
    let uid: String
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    let captionString: NSAttributedString
    fileprivate var imageIndex = 0 {
        didSet{
            let imageUrl = imageUrls[imageIndex]
            imageIndexObserver?(imageIndex,imageUrl)
        }
    }
    
    init(uid: String, imageUrls: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment, captionStr: NSAttributedString = NSAttributedString(string: "")) {
        self.uid = uid
        self.imageUrls = imageUrls
        self.attributedString = attributedString
        self.textAlignment = textAlignment
        self.captionString = captionStr
    }
    
    func goToNextPhoto(){
        imageIndex = min(imageIndex + 1, imageUrls.count - 1)
    }
    func goToPreviousPhoto(){
        imageIndex = max(imageIndex - 1, 0)
    }
    //一个闭包：用于观察index的状态以及反应
    var imageIndexObserver: ((Int, String) -> ())?
}

