//
//  RegisterationViewModel.swift
//  YSTinder
//
//  Created by jozen on 2019/1/11.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit
import Firebase

class RegisterationViewModel {
    
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    var bindableIsRegistering = Bindable<Bool>()
    
    // 收到新值调用check方法检查
    var name: String?{didSet{ checkIsFormValid() }}
    var email: String?{didSet{ checkIsFormValid() }}
    var password: String?{didSet{ checkIsFormValid() }}
    
}
