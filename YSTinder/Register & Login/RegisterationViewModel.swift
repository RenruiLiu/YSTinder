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
    var fullName: String?{didSet{ checkIsFormValid() }}
    var email: String?{didSet{ checkIsFormValid() }}
    var password: String?{didSet{ checkIsFormValid() }}
    
    // 检查form的结果通过isFormValidObserver传给view
    fileprivate func checkIsFormValid(){
        let isFormValid = fullName?.isEmpty == false && password?.isEmpty == false && email?.isEmpty == false
        bindableIsFormValid.value = isFormValid
    }
    
    func performRegisteration(completion: @escaping (Error?) -> ()) {
        
        bindableIsRegistering.value = true
        
        guard let email = email, let password = password else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            if let err = err {
                print("Failed to create a new user:",err)
                self.bindableIsRegistering.value = false
                completion(err)
                return
            }
            
            //注册新用户成功,存照片到库
            self.saveImageToFirebase(completion: completion)
        }
    }
    
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> ()){
        // 存照片
        let imageFileName = UUID().uuidString
        let reference = Storage.storage().reference(withPath: "/images/\(imageFileName)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        reference.putData(imageData, metadata: nil, completion: { (_, err) in
            if let err = err {
                print("Failed to store image:",err)
                self.bindableIsRegistering.value = false
                completion(err)
                return
            }
            
            //存储照片成功
            //获取照片地址
            reference.downloadURL(completion: { (url, err) in
                if let err = err{
                    self.bindableIsRegistering.value = false
                    completion(err)
                    return
                }
                
                print("image url is:", url?.absoluteString ?? "")
                
                //跳入主页面
                completion(nil)
            })
        })
    }
}
