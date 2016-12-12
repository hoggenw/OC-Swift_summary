//
//  ViewController.swift
//  SWift
//
//  Created by 王留根 on 16/10/27.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //数组排序相关
    func compareCategoryModelArray(modelArray:[PSCategoryModel]) -> [PSCategoryModel]  {
        
        //降序
        let returnArray = modelArray.sorted { (model1, model2) -> Bool in
            return model1.sequence! < model2.sequence!
        }
        
        
        return returnArray
    }

}

