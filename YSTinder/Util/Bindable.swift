
//
//  Bindable.swift
//  YSTinder
//
//  Created by jozen on 2019/1/11.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import Foundation

class Bindable<T> {
    
    var observer: ((T?) -> ())?
    
    var value: T? {
        didSet {
            //使用泛型的变量didSet调用observer闭包, observer闭包中将返回value
            observer?(value)
        }
    }
    
    func bind(observer: @escaping (T?) -> ()){
        self.observer = observer
    }
}
