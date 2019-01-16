//
//  YSSettingsController.swift
//  YSTinder
//
//  Created by jozen on 2019/1/16.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

// 继承一个imagePickerController中含有一个button -> 可以让didFinishPickingMediaWithInfo中，通过picker获取到这个button
class YSCustomImagePickerController: UIImagePickerController {
    var imageButton: UIButton?
}

class YSSettingsController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TLCityPickerDelegate {    
    
    //MARK:- properties
    lazy var imageButton1 = createButton(selector: #selector(handleSelectPhoto))
    lazy var imageButton2 = createButton(selector: #selector(handleSelectPhoto))
    lazy var imageButton3 = createButton(selector: #selector(handleSelectPhoto))
    let settingsSections = [["昵称","职业","年龄","城市","个性签名"],
        ["称呼我为","我的职业是","我的年龄是","我住在哪里","个性签名"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupNavigationBar()
        tableView.keyboardDismissMode = .interactive
    }
    
    //MARK:- nav bar
    
    fileprivate func setupNavigationBar() {
        navigationItem.title = "设置"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(handleCancel)),
            UIBarButtonItem(title: "注销", style: .plain, target: self, action: #selector(handleCancel))
        ]
    }
    
    fileprivate func setupLayout(){
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table header
    
    lazy var header: UIView = {
        let header = UIView()
        
        // setup imageButtons
        let padding: CGFloat = 8
        // imageButton1最大，占header的0.45宽
        header.addSubview(imageButton1)
        imageButton1.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        imageButton1.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        // 用stackView装剩下两个
        let stackView = UIStackView(arrangedSubviews: [imageButton2,imageButton3])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: imageButton1.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
    
    @objc fileprivate func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func createButton(selector: Selector) -> UIButton{
        let button = UIButton(type: .system)
        button.setTitle("选择照片", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    @objc fileprivate func handleSelectPhoto(button: UIButton){
        let imagePicker = YSCustomImagePickerController()
        imagePicker.imageButton = button
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 从info拿图片 设置到 picker的imageButton上
        let selectedImage = info[.originalImage]  as? UIImage
        let imageButton = (picker as? YSCustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true, completion: nil)
    }
    

}
