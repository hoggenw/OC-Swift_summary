//
//  PSCityAdressPickerView.swift
//  千机团Swift
//
//  Created by 王留根 on 16/12/2.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import UIKit

class PSCityAdressPickerView: UIView {
    
    var doneButton = UIButton(type: .custom)
    var cancelButton = UIButton(type: .custom)
    var customPickerView : UIPickerView?
    let backgroudView  = UIView()
    
    var cityArray = [PSAreaModel]()
    var townArray = [PSAreaModel]()
    var provinceArray = [PSAreaModel]()
    //var dataSourceArray = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customPickerView = UIPickerView(frame: CGRect(x: 0, y: 50, width: frame.size.width, height: frame.size.height - 50))
        customPickerView?.backgroundColor = UIColor.colorWithHex(hexRGBValue: backGroudColor)
        doneButton.frame = CGRect(x: frame.size.width - 70, y: 0, width: 60, height: 50)
        cancelButton.frame = CGRect(x: 10, y: 0, width: 60, height: 50)
        let custonView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 50))
        custonView.backgroundColor = UIColor.white
        
        doneButton.setTitle("完成", for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        doneButton.titleLabel?.adjustsFontSizeToFitWidth = true
        cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        doneButton.setTitleColor(UIColor.colorWithHex(hexRGBValue: orangeColor), for: .normal)
        cancelButton.setTitleColor(UIColor.colorWithHex(hexRGBValue: blackColor), for: .normal)
        doneButton.addTarget(self, action: #selector(sureAction(sender:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelAction(sender:)), for: .touchUpInside)
        
        customPickerView?.delegate = self
        customPickerView?.dataSource = self
        
        backgroudView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        self.addSubview(backgroudView)
        
        backgroudView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp.left)
            make.height.equalTo(MAIN_HEIGHT)
            make.width.equalTo(MAIN_WIDTH)
        }
        
        self.addSubview(custonView)
        self.addSubview(cancelButton)
        self.addSubview(doneButton)
        self.addSubview(customPickerView!)

    }
    
    func sureAction(sender:UIButton) {
        
    }
    
    func cancelAction(sender:UIButton) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension PSCityAdressPickerView: UIPickerViewDelegate,UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return self.provinceArray.count
        }else if component == 1 {
            return self.cityArray.count
        }else {
            return townArray.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let model = self.provinceArray[row]
            return model.name
        }else if component == 1 {
            let model = self.cityArray[row]
            return model.name
        }else {
            let model = self.townArray[row]
            return model.name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.textAlignment = .center
            pickerLabel?.backgroundColor = UIColor.clear
            pickerLabel?.font = UIFont.systemFont(ofSize: 18)
        }
        pickerLabel?.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        return pickerLabel!
        
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return self.frame.size.width/3
        }else if component == 1 {
            return self.frame.size.width/3
        }else {
            return self.frame.size.width/3
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
}








































