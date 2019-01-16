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
            let keys = [String](settingsDictionary.keys)
            headerLabel.text = keys[section-1]
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
        return settingsDictionary.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = YSSettingsCell(style: .default, reuseIdentifier: nil)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 
    }
}
