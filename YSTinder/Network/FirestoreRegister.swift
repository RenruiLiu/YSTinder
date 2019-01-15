//
//  FirestoreRegister.swift
//  YSTinder
//
//  Created by jozen on 2019/1/15.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import Foundation
import Firebase

//注册流程：检查表单是否合规 - 注册邮箱密码 - 存照片到storage - 获取照片url - 将key pair存进Firestore

extension RegisterationViewModel {
    
    // 检查form的结果通过isFormValidObserver传给view
    func checkIsFormValid(){
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
    
    func saveImageToFirebase(completion: @escaping (Error?) -> ()){
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
                
                //存入firestore
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            })
        })
    }
    
    func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()){
        
        print("开始存")
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData = ["fullName": fullName ?? "", "uid": uid, "imageUrl": imageUrl]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            
            print("结束存")
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
}
