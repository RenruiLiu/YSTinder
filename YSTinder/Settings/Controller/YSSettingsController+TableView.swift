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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = YSSettingsCell(style: .default, reuseIdentifier: nil)
        //每行的textfield的placeholder
        cell.textField.placeholder = settingsSections[1][indexPath.section - 1]
        //给城市一栏添加点击事件
        if indexPath == .init(row: 0, section: 4) {
            cell.textField.addTarget(self, action: #selector(handleSelectCity), for: .editingDidBegin)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 
    }
    
    @objc fileprivate func handleSelectCity(_ textField: YSCustomTextField){
        let cityPicker = TLCityPickerController()
        cityPicker.delegate = self
        cityPicker.hotCitys = ["100010000", "200010000", "300210000", "600010000", "300110000"]
        navigationController?.pushViewController(cityPicker, animated: true)
        textField.removeTarget(self, action: #selector(handleSelectCity), for: .editingDidBegin)
    }
    
    func cityPickerController(_ cityPickerViewController: TLCityPickerController!, didSelect city: TLCity!) {
        print("选择了",city.cityName)
        //并不会成功，因为cell是复制品
        let cell = tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 4)) as? YSSettingsCell
        cell?.textField.text = city.cityName
        navigationController?.popViewController(animated: true)
    }
    
    func cityPickerControllerDidCancel(_ cityPickerViewController: TLCityPickerController!) {
        navigationController?.popViewController(animated: true)
    }
    
}
