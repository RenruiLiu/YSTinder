//
//  YSCustomTextField.swift
//  YSTinder
//
//  Created by jozen on 2019/1/11.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

class YSCustomTextField: UITextField {
    let padding: CGFloat
    init(padding: CGFloat){
        self.padding = padding
        super.init(frame: .zero)
        
        self.layer.cornerRadius = 25
        self.backgroundColor = .white
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    } //placeholder的间距
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    } //编辑字的间距
    
    override var intrinsicContentSize: CGSize{
        return .init(width: 0, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
