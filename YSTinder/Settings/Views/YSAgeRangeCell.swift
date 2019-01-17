//
//  YSAgeRangeCell.swift
//  YSTinder
//
//  Created by jozen on 2019/1/17.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

class YSAgeRangeCell: UITableViewCell {
    
    //MARK:- UI components
    let minSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 18
        slider.maximumValue = 80
        return slider
    }()
    let maxSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 18
        slider.maximumValue = 80
        slider.value = 80
        return slider
    }()
    
    class AgeRangeLabel: UILabel {
        //改变其宽度
        override var intrinsicContentSize: CGSize {
            return .init(width: 90, height: 0)
        }
    }
    var minValue: Int = 18
    var maxValue: Int = 80
    
    let minLabel: UILabel = {
        let lb = AgeRangeLabel()
        lb.text = "最小 18 岁"
        return lb
    }()
    let maxLabel: UILabel = {
        let lb = AgeRangeLabel()
        lb.text = "最大 80 岁"
        return lb
    }()
    
    func setAgeRange(min: Int, max: Int){
        minValue = min
        maxValue = max
        maxLabel.text = "最大 \(maxValue) 岁"
        minLabel.text = "最小 \(minValue) 岁"
        maxSlider.value = Float(maxValue)
        minSlider.value = Float(minValue)
    }
    
    func setMinAge(min:Int){
        minValue = min
        minLabel.text = "最小 \(minValue) 岁"
        minSlider.value = Float(minValue)
    }
    func setMaxAge(max:Int){
        maxValue = max
        maxLabel.text = "最大 \(maxValue) 岁"
        maxSlider.value = Float(maxValue)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stackView = UIStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [minLabel,minSlider]),
            UIStackView(arrangedSubviews: [maxLabel,maxSlider]),
        ])
        stackView.axis = .vertical
        addSubview(stackView)
        let padding: CGFloat = 16
        stackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        stackView.spacing = padding
    }
    
    //MARK:- useless
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
