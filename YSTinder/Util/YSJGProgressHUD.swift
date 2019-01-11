//
//  YSJGProgressHUD.swift
//  YSTinder
//
//  Created by jozen on 2019/1/11.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import JGProgressHUD

func showErrorHUD(title: String, detail: String, view: UIView){
    let hud = JGProgressHUD(style: .dark)
    hud.indicatorView = JGProgressHUDErrorIndicatorView()
    hud.textLabel.text = title
    hud.detailTextLabel.text = detail
    hud.show(in: view)
    hud.dismiss(afterDelay: 3, animated: true)
}

