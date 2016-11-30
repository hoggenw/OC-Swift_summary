//
//  PSPopupView.swift
//  Swift
//
//  Created by 王留根 on 16/11/30.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import UIKit


enum HideIndex:Int32 {
    case non = 0
    case home = 1
    case message = 2
    case search = 3
    case history = 4
    case collotion = 5
};

class PSPopupView: NSObject {
    public static let psPopupView = PSPopupView()
    var popupView : UIView?
    var backView : UIView?
    let viewWidth :CGFloat = 90
    let tabController : UITabBarController =  UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
    //MAKR:使用时直接掉这个类方法就可以了
    class func showPopupView (hideIndex:HideIndex = .non) {
        if PSPopupView.psPopupView.popupView != nil{
            PSPopupView.psPopupView.popupView = nil
            PSPopupView.psPopupView.backView = nil
            PSPopupView.psPopupView.creatPopupView(hideIndex: hideIndex)
            
        }else {
            PSPopupView.psPopupView.creatPopupView(hideIndex: hideIndex)
        }
        
        
    }
    func creatPopupView(hideIndex:HideIndex = .non) {
        let popupViewHeight:CGFloat = 120 - (hideIndex == .non ? 0 : 42)
        PSPopupView.psPopupView.popupView  = UIView(frame: CGRect(x: MAIN_WIDTH-100, y: 68, width: viewWidth, height: popupViewHeight))
        PSPopupView.psPopupView.backView = UIView()
        PSPopupView.psPopupView.backView?.frame = CGRect(x: 0, y: 0, width: MAIN_WIDTH, height: MAIN_HEIGHT)
        
        PSPopupView.psPopupView.backView?.backgroundColor = UIColor.clear
        PSPopupView.psPopupView.backView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hidden)));
        
        PSPopupView.psPopupView.popupView?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        PSPopupView.psPopupView.popupView?.layer.cornerRadius = 2;
        PSPopupView.psPopupView.popupView?.clipsToBounds = false
        
        UIApplication.shared.keyWindow?.addSubview(PSPopupView.psPopupView.backView!)
       UIApplication.shared.keyWindow?.addSubview(PSPopupView.psPopupView.popupView!)
        
        let shapeImageView = UIImageView()
        shapeImageView.image = UIImage(named: "detail_popup_shape")
        PSPopupView.psPopupView.popupView?.addSubview(shapeImageView)
        shapeImageView.snp.makeConstraints { (make) in
            make.right.equalTo((PSPopupView.psPopupView.popupView?.snp.right)!).offset(-10)
            make.bottom.equalTo((PSPopupView.psPopupView.popupView?.snp.top)!)
            make.width.equalTo(17)
            make.height.equalTo(9)
        }
        var offsetY:CGFloat = 0
        if !(hideIndex == HideIndex.message) {
            let imageString = PSCommonUtils.ifMeiQiaNewMessage() ? "popup_icon_message_r":"popup_icon_message"
            PSPopupView.psPopupView.creatButton(imageName: imageString, title: "  客服", needLine: true, rectY: offsetY).addTarget(self, action: #selector(severceCenter), for: .touchUpInside)
            offsetY += 42
        }
        
        if !(hideIndex == HideIndex.home) {
            PSPopupView.psPopupView.creatButton(imageName: "popup_icon_home", title: "  首页", needLine: true, rectY: offsetY).addTarget(self, action: #selector(homeButtonAction), for: .touchUpInside)
            offsetY += 42
        }
        if !(hideIndex == HideIndex.search) {
           PSPopupView.psPopupView.creatButton(imageName: "popup_icon_help", title: "  帮助", needLine: false, rectY: offsetY).addTarget(self, action: #selector(helpButtonAction), for: .touchUpInside)
            offsetY += 42
        }
        
    }
    
    func homeButtonAction() {
        MobClick.event("首页")
        let nav :UINavigationController = tabController.selectedViewController! as! UINavigationController
        nav.popToRootViewController(animated: false)
        
        PSPopupView.psPopupView.hidden()
        tabController.selectedIndex = 0
        
        
    }
    
    func severceCenter() {
        MobClick.event("客服")
        PSPopupView.psPopupView.hidden()
        let nav :UINavigationController = tabController.selectedViewController! as! UINavigationController
        PSOCTransferVendor.transferMQChatViewManager(nav)
        
    }
    func helpButtonAction(){
        MobClick.event("快捷入口_帮助中心")
        PSPopupView.psPopupView.hidden()
        let nav :UINavigationController = tabController.selectedViewController! as! UINavigationController
        let webVC = PSGeneralWebViewController()
        webVC.title = "帮助中心"
        webVC.strUrl = String(format: "%@%@", PSWebBaseUrl, PSStaticWebSuffix_Help)
        webVC.needMoreHelp = true
        webVC.hidesBottomBarWhenPushed = true
        nav.pushViewController(webVC, animated: true)
        
        
    }

    func hidden () {
        PSPopupView.psPopupView.popupView?.removeAllSubViews()
        PSPopupView.psPopupView.popupView?.removeFromSuperview()
        PSPopupView.psPopupView.popupView = nil
        PSPopupView.psPopupView.backView?.removeFromSuperview()
        PSPopupView.psPopupView.backView = nil
        
    }
    func creatButton(imageName:String,title:String,needLine:Bool,rectY:CGFloat) ->UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: imageName), for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .left
        button.setTitleColor(UIColor.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: rectY, width: viewWidth, height: 42)
        PSPopupView.psPopupView.popupView?.addSubview(button)
        if needLine {
            let lineView = PSPopupView.psPopupView.createLine();
            button.addSubview(lineView)
            
            lineView.frame = CGRect(x: 4, y: 41, width: viewWidth-8, height: 1)
        }
        
        
        return button
        
    }
    
    
    func createLine()->UIView{
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        return lineView
        
        
    }
}
