//
//  ScanQRCodesViewController.swift
//
//
//  Created by 王留根 on 2016/11/8.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import UIKit

class ScanQRCodesViewController: LBXScanViewController {

    private let photoButton = UIButton.init(type: .custom)
    private let flashButton = UIButton.init(type: .custom)
    
    private var isCreateButton = false
    
    deinit {
        print("deinit \(NSStringFromClass(self.classForCoder))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        if isCreateButton == false {
            isCreateButton = true
            createToolsButton()
        }
    }
    
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        
        if arrayResult.count < 1 {
            return
        }
        
        let result = arrayResult[0]
        let scanResult = result.strScanned
        if scanResult != nil {
            let str:String = scanResult!
            let seperatStr = "http://3c1000.com/product/details/"
            if str.hasPrefix(seperatStr) {
                let sku = str.substring(from: seperatStr.characters.count)
                print("sku \(sku)")
                let detailVC = ProductDetailController()
                detailVC.sysNo = sku
                self.navigationController?.pushViewController(detailVC, animated: true)
            }else{
                self.pushViewController(className: "ScanResultTextViewController", params: ["text":str], animated: true)
            }
        }
        

    }

    
    //MARK:Private Methods
    
    private func initUI() {
        
        
        var style = LBXScanViewStyle()
        style.animationImage = UIImage(named: "qrcode_scan_light_green")
        style.isNeedShowRetangle = false
        style.red_notRecoginitonArea = 0.4
        style.green_notRecoginitonArea = 0.4
        style.blue_notRecoginitonArea = 0.4
        style.alpa_notRecoginitonArea = 0.4
        style.photoframeLineW = 2.0;
        style.photoframeAngleW = 16;
        style.photoframeAngleH = 16;
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner;
        self.scanStyle = style

    }
    
    private func createToolsButton() {
    
        flashButton.setImage(UIImage.init(named: "qrcode_scan_btn_flash_nor"), for: .normal)
        flashButton.tag = 110
        flashButton.addTarget(self, action: #selector(buttonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(flashButton)
        flashButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(20)
            make.bottom.equalTo(self.view).offset(-20)
            make.width.equalTo(65)
            make.height.equalTo(87)
        }
        
        photoButton.setImage(UIImage.init(named: "qrcode_scan_btn_photo_nor"), for: .normal)
        photoButton.setImage(UIImage.init(named: "qrcode_scan_btn_photo_down"), for: .highlighted)
        photoButton.tag = 111
        photoButton.addTarget(self, action: #selector(buttonClick(sender:)), for: .touchUpInside)
        self.view.addSubview(photoButton)
        photoButton.snp.makeConstraints { (make) in
            make.bottom.width.height.equalTo(flashButton)
            make.right.equalTo(self.view).offset(-20)
        }
        
    }

    private func openOrCloseFlash() {
    
        scanObj?.changeTorch()
        if scanObj?.input?.device.torchMode == .on {
            
            flashButton.setImage(UIImage.init(named: "qrcode_scan_btn_scan_off"), for: .normal)
            
        }else{
            flashButton.setImage(UIImage.init(named: "qrcode_scan_btn_flash_nor"), for: .normal)
        }
    }
    
    //MARK:User Events
    @objc private func buttonClick(sender:UIButton) {
    
        if sender.tag == 110 {
            
            openOrCloseFlash()
        }else if sender.tag == 111 {
        
            openPhotoAlbum()
        }
    }
    
}
