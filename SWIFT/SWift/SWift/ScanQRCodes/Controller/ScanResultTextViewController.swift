//
//  ScanResultTextViewController.swift
//
//
//  Created by 王留根 on 2016/11/9.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import UIKit

class ScanResultTextViewController: UIViewController {

    //MARK:Private Property
    private let naviView = AccountNaviView.init(frame: CGRect.zero, title: "文本信息")
    private let textView = UITextView()
    
    var text:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initDataSource()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    //MARK:Private Methods
    private func initDataSource() {
    
        if params != nil {
            text = params?["text"] as? String
        }
    }
    
    private func initUI() {
        
        self.view.backgroundColor = kColorWhite_f3f3f3
        
        createNaviView()
        createTextView()
    }
    
    
    private func createNaviView() {
        
        self.view.addSubview(naviView)
        naviView.backClickEvent = { [weak self] ()->() in
            
            _ = self?.navigationController?.popViewController(animated: true)
        }
        naviView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.height.equalTo(64)
        }
        
        QJWUtil.addLineToNaviView(navView: naviView)
    }
    
    private func createTextView() {
    
        textView.backgroundColor = UIColor.white
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.black
        textView.layer.cornerRadius = 3
        textView.isEditable = false
        textView.clipsToBounds = true
        self.view.addSubview(textView)
        textView.text = text
        
        textView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.top.equalTo(naviView.snp.bottom).offset(10)
            make.height.equalTo(200)
        }
    }

}
