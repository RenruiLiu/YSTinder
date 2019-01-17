//
//  YSSettingsController+TableView.swift
//  YSTinder
//
//  Created by jozen on 2019/1/16.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

extension YSSettingsController{

    //MARK:- header
    //自定义一个向右偏16的label
    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        } else {
            let headerLabel = HeaderLabel()
            headerLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            headerLabel.text = settingsSections[0][section - 1]
            return headerLabel
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        } else {
            return 40
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingsSections[0].count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    fileprivate func setupCellTextField(_ indexPath: IndexPath, _ cell: YSSettingsCell) {
        let textField = cell.textField
        //获取currentUser数据后在这reload用户的数据到Textfield
        switch indexPath.section {
        case 1:
            textField.text = currentUser?.name
            textField.addTarget(self, action: #selector(handleTextFieldTextChange), for: .editingChanged)
        case 2:
            textField.text = currentUser?.profession
            textField.addTarget(self, action: #selector(handleTextFieldTextChange), for: .editingChanged)
        case 3:
            if let age = currentUser?.age {
                textField.text = "\(age)"
            }
            textField.keyboardType = .numberPad
            textField.addTarget(self, action: #selector(handleTextFieldTextChange), for: .editingChanged)
        case 4:
            textField.text = currentUser?.city
            //给城市一栏添加点击事件
            textField.addTarget(self, action: #selector(handleSelectCity), for: .editingDidBegin)
        case 5:
            textField.text = currentUser?.caption
            textField.addTarget(self, action: #selector(handleTextFieldTextChange), for: .editingChanged)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = YSSettingsCell(style: .default, reuseIdentifier: nil)
        
        setupCellTextField(indexPath, cell)
        //每行的textfield的placeholder
        cell.textField.placeholder = settingsSections[1][indexPath.section - 1]

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 
    }
    
    @objc fileprivate func handleSelectCity(_ textField: YSCustomTextField){
        cityTextField = textField
        
        let cityPicker = TLCityPickerController()
        cityPicker.delegate = self
        cityPicker.hotCitys = ["100010000", "200010000", "300210000", "600010000", "300110000"]
        navigationController?.pushViewController(cityPicker, animated: true)
        textField.removeTarget(self, action: #selector(handleSelectCity), for: .editingDidBegin)
    }
    
    func cityPickerController(_ cityPickerViewController: TLCityPickerController!, didSelect city: TLCity!) {
        cityTextField?.text = city.cityName
        currentUser?.city = city.cityName
        navigationController?.popViewController(animated: true)
    }
    
    func cityPickerControllerDidCancel(_ cityPickerViewController: TLCityPickerController!) {
        navigationController?.popViewController(animated: true)
    }
    
}
