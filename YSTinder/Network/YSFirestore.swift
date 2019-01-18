//
//  FirestoreRegister.swift
//  YSTinder
//
//  Created by jozen on 2019/1/15.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import Foundation
import Firebase
import Reachability



//注册流程：检查表单是否合规 - 注册邮箱密码 - 存照片到storage - 获取照片url - 将key pair存进Firestore

extension RegisterationViewModel {
    
    // 检查form的结果通过isFormValidObserver传给view
    func checkIsFormValid(){
        let isFormValid = name?.isEmpty == false && password?.isEmpty == false && email?.isEmpty == false
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
    
    //将注册的照片存进firestore后又把imageURL存起来
    func saveImageToFirebase(completion: @escaping (Error?) -> ()){
        // 存照片
        guard let imageData = self.bindableImage.value else {return}
        uploadImageToFirestore(image: imageData) { (urlString, err) in
            if let err = err {
                self.bindableIsRegistering.value = false
                completion(err)
                return
            }
            
            //存入firestore
            guard let imageUrlStr = urlString else {return}
            self.saveInfoToFirestore(imageUrl: imageUrlStr, completion: completion)
        }
    }
    
    //保存注册信息到firestore
    func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()){
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData = ["name": name ?? "", "uid": uid, "imageUrls": [imageUrl]] as [String : Any]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
}

fileprivate var lastFetchedUser: YSUser?

// 分页fetch用户
    
    // whereField：范围筛选 18~30岁的用户，只可以在同一个filed内筛选
    // 还可以 arrayContains 筛选 一个array Field中包含了 某元素的 成员
    //    query.whereField("age", isLessThan: 30).whereField("age", isGreaterThan: 18)
    
    // pagination：根据uid的order，每次3个
    //    .order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""])

var nextQuery: Query?

fileprivate func queryFilter(currentUser: YSUser) -> Query{
    
    let db = Firestore.firestore()
    guard let minAge = currentUser.minSeekingAge,
        let maxAge = currentUser.maxSeekingAge else {return db.collection("users")}
    
    var query: Query?
    //如果不是第一次查询，有nextQuery，则本次query = nextQuery
    if nextQuery != nil {
        query = nextQuery
    } else {
        //如果是第一次query，则新建一个query
        query = db.collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge).limit(to: Constants.limitOfFetchUsers)
    }
    //从本次query开始，建立下一次query，并赋值给nextQuery
    query?.addSnapshotListener { (snapshot, err) in
        guard let lastSnapshot = snapshot?.documents.last else {return}
        let next = db.collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge).start(afterDocument: lastSnapshot).limit(to: Constants.limitOfFetchUsers)
        nextQuery = next
    }
    
    return query!
}

func fetchUsersFromFirestore(currentUser: YSUser ,completion: @escaping ([YSCardViewModel]) -> ()){
    let filteredQuery = queryFilter(currentUser: currentUser)

    //开始查询
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
            
        print("加载了", cardViewModels.count,"个用户，最后一位的名字是：",lastFetchedUser?.name ?? "none")
        //已获取所有cardViewModels，将其setup到View
        completion(cardViewModels)
    }
}

//获取当前用户
func fetchCurrentUser(completion: @escaping (YSUser) -> ()) {
    guard let uid = Auth.auth().currentUser?.uid else {return}
    Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
        if let err = err {
            print("Failed to fetch current user:",err)
            return
        }
        
        guard let userDictionary = snapshot?.data() else {return}
        let user = YSUser(dictionary: userDictionary)
        
        completion(user)
    }
}

//在设置中保存用户信息
func saveUserInfoToFirestore (user: YSUser?, completion:@escaping ((Error?)->())){
    guard let user = user else {return}
    guard let uid = user.uid else {return}
    let docData = user.toUserDictionary()
    
    if let err = checkNetworkConnection(){
        completion(err)
    }
    
    //开始保存
    Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
        if let err = err {
            print("Failed to save user settings:",err)
            completion(err)
            return
        }
        
        //保存成功
        completion(nil)
    }
}

//检查网络，没网时返回err
func checkNetworkConnection() -> Error?{
    let reachability = Reachability()!
    if reachability.connection == .none {
        let err = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"没有网络连接，请检查网络设置"])
        return err
    }
    return nil
}

// 上传图片，返回图片的下载url
func uploadImageToFirestore(image: UIImage, completion: @escaping (String?, Error?) -> ()){
    let imageFileName = UUID().uuidString
    let reference = Storage.storage().reference(withPath: "/images/\(imageFileName)")
    let imageData = image.jpegData(compressionQuality: 0.75) ?? Data()
    reference.putData(imageData, metadata: nil, completion: { (_, err) in
        if let err = err {
            print("Failed to store image:",err)
            completion(nil, err)
            return
        }
        
        //存储照片成功
        //获取照片地址
        reference.downloadURL(completion: { (url, err) in
            if let err = err{
                print("Failed to get the image's download URL:", err)
                completion(nil, err)
                return
            }
            
            //存入firestore
            let imageUrl = url?.absoluteString ?? ""
            completion(imageUrl, err)
        })
    })
}

func logout(){
    try? Auth.auth().signOut()
}

func loginUser(WithEmail email: String, password: String, completion:@escaping (Error?)->()){
    Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
        completion(err)
    }
}
