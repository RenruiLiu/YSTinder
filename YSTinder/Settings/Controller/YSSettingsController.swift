//
//  YSSettingsController.swift
//  YSTinder
//
//  Created by jozen on 2019/1/16.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

// 继承一个imagePickerController中含有一个button -> 可以让didFinishPickingMediaWithInfo中，通过picker获取到这个button
class YSCustomImagePickerController: UIImagePickerController {
    var imageButton: UIButton?
}

class YSSettingsController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TLCityPickerDelegate {    
    
    //MARK:- properties
    var delegate: SettingsControllerDelegate?
    
    lazy var imageButton1 = createButton(selector: #selector(handleSelectPhoto))
    lazy var imageButton2 = createButton(selector: #selector(handleSelectPhoto))
    lazy var imageButton3 = createButton(selector: #selector(handleSelectPhoto))
    let settingsSections = [["昵称","职业","年龄","城市","个性签名","年龄范围"],
        ["称呼我为","我的职业是","我的年龄是","我住在哪里","个性签名"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupNavigationBar()
        tableView.keyboardDismissMode = .interactive
//        deployCurrentUser()
    }
    
    //MARK:- nav bar
    
    fileprivate func setupNavigationBar() {
        navigationItem.title = "设置"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "注销", style: .plain, target: self, action: #selector(handleLogout))
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
        button.imageView?.image?.withRenderingMode(.alwaysOriginal)
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
        
        // 上传图片到firestore
        setImageForUser(selectedImage, onButton: imageButton)
    }
    
    //MARK:- Load User
    var currentUser: YSUser? {
        didSet{
            tableView.reloadData()
            loadUserPhotos()
        }
    }
    
//    fileprivate func deployCurrentUser(){
//        fetchCurrentUser { [weak self] (user) in
//            self?.currentUser = user
//            self?.tableView.reloadData()
//            self?.loadUserPhotos()
//        }
//    }
    
    fileprivate func loadUserPhotos(){
        var imageUrls = [] as [URL]
        currentUser?.imageUrls?.forEach({ (urlStr) in
            if let url = URL(string: urlStr) {
                imageUrls.append(url)
            }
        })
        let buttons = [imageButton1,imageButton2,imageButton3]
        for (i,url) in imageUrls.enumerated() {
            if i < 0 || i >= buttons.count {return}
            // 使用manager
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                buttons[i].setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }

    //MARK:- textfields
    @objc func handleTextFieldTextChange(textField: UITextField){
        let text = textField.text
        switch textField.placeholder {
        case settingsSections[1][0]:
            currentUser?.name = text
        case settingsSections[1][1]:
            currentUser?.profession = text
        case settingsSections[1][2]:
            currentUser?.age = Int(text ?? "")
        case settingsSections[1][4]:
            currentUser?.caption = text
        default:
            break
        }
    }
    
    //MARK:- age slider
    @objc func handleMinAgeChange(slider: UISlider){
        //通过cell获取到它的value
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 6)) as? YSAgeRangeCell
        cell?.setMinAge(min: Int(slider.value))
        
        //如果最小比最大大，把最大等于最小
        if slider.value > (cell?.maxSlider.value)! {
            cell?.setMaxAge(max: Int(slider.value))
        }
        
        //保存value到user
        currentUser?.minSeekingAge = Int(slider.value)
    }
    //同上
    @objc func handleMaxAgeChange(slider: UISlider){
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 6)) as? YSAgeRangeCell
        cell?.maxValue = Int(slider.value)
        cell?.setMaxAge(max: Int(slider.value))
        if slider.value < (cell?.minSlider.value)! {
            cell?.setMinAge(min: Int(slider.value))
        }
        currentUser?.maxSeekingAge = Int(slider.value)
    }
    
    //MARK:- select photo
    //选择了照片之后立马上传到firestore，接着将取回的下载URLappend到user.imageUrls里。
    //这样点保存的时候就会保存好所有照片的url了
    fileprivate func setImageForUser(_ selectedImage: UIImage?, onButton button: UIButton?){
        let hud = showWaitingHUD(title: "上传照片", detail: "", view: view)
        uploadImageToFirestore(image: selectedImage ?? UIImage()) { [weak self] (urlString, err)  in
            if let err = err {
                hud.hudShowError(title: "上传图片失败", detail: err.localizedDescription)
                return}
            guard let imageUrlString = urlString else {return}
            
            guard var urls = self?.currentUser?.imageUrls else {return}
            if urls.count < 3 {
                self?.currentUser?.imageUrls?.append(imageUrlString)
            } else {
                if button == self?.imageButton1 {
                    urls[0] = imageUrlString
                } else if button == self?.imageButton2 {
                    urls[1] = imageUrlString
                } else {
                    urls[2] = imageUrlString
                }
            }
            self?.currentUser?.imageUrls = urls
            hud.hudShowSuccess(title: "图片上传完成", detail: "")
        }
    }
    
    //MARK:- Save Data
    //TODO:- 用户保存后，刷新主页
    @objc fileprivate func handleSave(){
        view.endEditing(true)
        let hud = showWaitingHUD(title: "保存中", detail: "", view: view)
        saveUserInfoToFirestore(user: currentUser) { (err) in
            if let err = err {
                hud.hudShowError(title: "保存失败", detail: err.localizedDescription)
                return
            }
            
            hud.dismiss()
            self.dismiss(animated: true, completion: {
                self.delegate?.didSaveSettings()
            })
        }
    }
    
    //MARK:- 注销
    @objc fileprivate func handleLogout(){
        //logout
        //present login
        logout()
        dismiss(animated: true, completion: nil)
    }
}
