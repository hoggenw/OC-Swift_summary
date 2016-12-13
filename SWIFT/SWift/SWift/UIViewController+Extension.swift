//
//  UIViewController+Extension.swift
//  QianJiWang
//
//  Created by Pisen on 2016/10/19.
//  Copyright © 2016年 Pisen. All rights reserved.
//

import UIKit

extension UIViewController {

    private struct AssociatedKeys {
        static var params:NSMutableDictionary?
    }
    var params:NSMutableDictionary?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.params) as? NSMutableDictionary
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.params, newValue as NSMutableDictionary?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func presentViewController(className:String,params:NSMutableDictionary? = nil,animated:Bool = true,completion:(() -> Void)? = nil) {
        let ClassVC:AnyClass? = NSClassFromString("QianJiWang." + className)
        if ClassVC == nil {
            return
        }
        let VC = ClassVC as? UIViewController.Type
        if VC == nil {
            return
        }
        let vc = (VC?.init())!
        vc.params = params
        
        // Remark: tabbar hidden
        vc.hidesBottomBarWhenPushed = true
        
        self.present(vc, animated: animated, completion: completion)
        
    }
    
    func pushViewController(className:String,params:NSMutableDictionary? = nil,animated:Bool = true) {
        let ClassVC:AnyClass? = NSClassFromString("QianJiWang." + className)
        if ClassVC == nil {
            return
        }
        let VC = ClassVC as? UIViewController.Type
        if VC == nil {
            return
        }
        let vc = (VC?.init())!
        vc.params = params
        
        // Remark: tabbar hidden
        vc.hidesBottomBarWhenPushed = true
        
        if self.isKind(of: UINavigationController.self) {
            let nav = self as! UINavigationController
            nav.pushViewController(vc,animated:animated)
        }else{
            self.navigationController?.pushViewController(vc, animated: animated)
        }
        
    }
}
