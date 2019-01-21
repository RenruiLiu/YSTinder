//
//  YSUserDetailsViewController.swift
//  YSTinder
//
//  Created by jozen on 2019/1/21.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

class YSUserDetailsViewController: UIViewController {

    var thisUser: YSUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .purple
        print("this user is:", thisUser)
    }

}
