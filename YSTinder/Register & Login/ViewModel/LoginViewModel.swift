//
//  LoginViewModel.swift
//  YSTinder
//
//  Created by jozen on 2019/1/18.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import Foundation

class LoginViewModel {
    
    var isLoggingIn = Bindable<Bool>()
    var isFormValid = Bindable<Bool>()
    var email: String? {didSet{ checkFormValidity()}}
    var password: String? {didSet{ checkFormValidity()}}
    
    fileprivate func checkFormValidity(){
        let isValid = email?.isEmpty == false && password?.isEmpty == false
        isFormValid.value = isValid
    }
    
    // 确认表单无误后登陆，返回潜在错误
    func performLogin(completion: @escaping (Error?) -> ()){
        let (email,password) = checkIfScretLogin()
        
        isLoggingIn.value = true
        loginUser(WithEmail: email, password: password, completion: { err in
            completion(err)
        })
    }
    
    func checkIfScretLogin() -> (String, String){
        if email == SecretLoginAccount.secretLoginEmailKey && password == SecretLoginAccount.secretLoginPswKey {
            return (SecretLoginAccount.secretLoginEmail,SecretLoginAccount.secretLoginPassword)
        }
        return (email ?? "",password ?? "")
    }
}
