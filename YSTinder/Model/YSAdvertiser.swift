//
//  Advertiser.swift
//  YSTinder
//
//  Created by jozen on 2019/1/9.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

struct YSAdvertiser: ProducesCardViewModel {
    
    let title: String
    let brandName: String
    let posterPhotoName: String

    //将一个User中需要展示到View的内容都转成一个ViewModel
    func toCardViewModel() -> YSCardViewModel{
        let attributedText = NSMutableAttributedString(string: title, attributes: [.font:UIFont.systemFont(ofSize: 32, weight: .heavy)])
        attributedText.append(NSAttributedString(string: "\n\(brandName)", attributes: [.font:UIFont.systemFont(ofSize: 24, weight: .bold)]))
        
        return YSCardViewModel(uid: "", imageUrls: [posterPhotoName], attributedString: attributedText, textAlignment: .center)
    }
}
