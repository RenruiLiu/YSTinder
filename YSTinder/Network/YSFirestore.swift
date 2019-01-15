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

fileprivate var lastFetchedUser: YSUser?

func fetchUserFromFirestore(completion: @escaping ([YSCardViewModel]) -> ()){
    let query = Firestore.firestore().collection("users")
    
    // whereField：范围筛选 18~30岁的用户，只可以在同一个filed内筛选
    // 还可以 arrayContains 筛选 一个array Field中包含了 某元素的 成员
//    query.whereField("age", isLessThan: 30).whereField("age", isGreaterThan: 18)
    
    // pagination：根据uid的order，每次2个
    let filteredQuery = query.order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
        filteredQuery.getDocuments { (snapshot, err) in
        if let err = err {
            print("Failed to fetch users:",err)
            return
        }
        
        var cardViewModels = [] as [YSCardViewModel]
        snapshot?.documents.forEach({ (documentSnapshot) in
            let userDictionary = documentSnapshot.data()
            let user = YSUser(dictionary: userDictionary)
            cardViewModels.append(user.toCardViewModel())
            lastFetchedUser = user
        })
        print("加载了", cardViewModels.count,"个用户，最后一位的名字是：",lastFetchedUser?.name)
        //已获取所有cardViewModels，将其setup到View
        completion(cardViewModels)
    }
}
