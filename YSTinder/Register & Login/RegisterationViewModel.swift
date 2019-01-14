//
//  RegisterationViewModel.swift
//  YSTinder
//
//  Created by jozen on 2019/1/11.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit
import Firebase

//注册流程：检查表单是否合规 - 注册邮箱密码 - 存照片到storage - 获取照片url - 将key pair存进Firestore

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
        
                //存入firestore
                self.saveInfoToFirestore(completion: completion)
            })
        })
    }
    
    fileprivate func saveInfoToFirestore(completion: @escaping (Error?) -> ()){
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        print("开始存")
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData = ["fullName": fullName ?? "", "uid": uid]
        db.collection("users").document(uid).setData(docData) { (err) in
        
            print("结束存")
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
}

/*
 2019-01-14 09:54:00.257794+0800 YSTinder[6995:1570394] Received XPC error Connection interrupted for message type 3 kCFNetworkAgentXPCMessageTypePACQuery
 2019-01-14 09:54:00.258308+0800 YSTinder[6995:1570394] Received XPC error Connection invalid for message type 3 kCFNetworkAgentXPCMessageTypePACQuery 
 */
