 //
//  PSLocalDataManager.swift
//  Swift
//
//  Created by 王留根 on 16/11/1.
//  Copyright © 2016年 ios-mac. All rights reserved.
//


import UIKit
import FMDB
import ObjectMapper

 enum PSSMSCodeType {
    case PSSMSCodeTypeRegister     // 0=注册；
    case PSSMSCodeTypeResetPwd          // 1=重置密码
    case PSSMSCodeTypeUpdatePwd        // 2=修改密码
    case PSSMSCodeTypeUpdatePhone
 }



class PSLocalDataManager: NSObject {
    let PSTableName_ShippingAddress = "shippingAddressTable";
    let PSTableName_PickUpUser      = "pickUpUserTable";
    let PSTableName_BusinessAuthenticate = "businessAuthenticate";
    
    // 这三个是筛选属性时的key，前2个是直接筛选属性，后1个是关键字搜索页面的筛选中的筛选属性
    let  PSKeyName_CategoryFilter = "PSCategoryFilter_SelectedAttributes";
    let  PSKeyName_BuyNowFilter  = "PSBuyNowFilter_SelectedAttributes";
    let  PSKeyName_KeywordFilter = "PSKeywordFilter_CurrentSelectedAttributes";
    // 关键字搜索页面的2个选项
    let  PSKeyName_KeywordFilter_SelectedCategory = "PSKeywordFilter_SelectedCategory";
    let  PSKeyName_KeywordFilter_SelectedStoreAttributes = "PSKeywordFilter_SelectedStoreAttributes";
    let  PSKeyName_KeywordFilter_SelectedRequestAttributes = "PSKeywordFilter_SelectedRequestAttributes";
    
    
    let  PSKeyName_SMSCodeRegister_SendTime        = "PSSMSCodeRegister_SendTime";
    let  PSKeyName_SMSCodeRegister_SendAccount     = "PSSMSCodeRegister_SendAccount";
    let  PSKeyName_SMSCodeResetPwd_SendTime        = "PSSMSCodeResetPwd_SendTime";
    let  PSKeyName_SMSCodeResetPwd_SendAccount     = "PSSMSCodeResetPwd_SendAccount";
    let  PSKeyName_SMSCodeUpdatePwd_SendTime       = "PSSMSCodeUpdatePwd_SendTime";
    let  PSKeyName_SMSCodeUpdatePwd_SendAccount    = "PSSMSCodeUpdatePwd_SendAccount";
    let  PSKeyName_SMSCodeUpdatePhone_SendTime     = "PSSMSCodeUpdatePhone_SendTime";
    let  PSKeyName_SMSCodeUpdatePhone_SendAccount  = "PSSMSCodeUpdatePhone_SendAccount";
    
    public static let localManager :PSLocalDataManager = PSLocalDataManager()
    var fmdb: FMDatabase?
    override init() {
        super.init()
        self.creatDataBase(name: "QianJiTuanLocalData.db")
    }
    func creatDataBase(name: String) {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let path = documentsPath+"/"+name
        
        fmdb = FMDatabase(path: path)
        
        if fmdb?.open() == false {
            print("打开数据库失败")
            return
        }
        creatTable()

    }
    func creatTable() {
        print("db begin")
        //浏览记录
        let sql1 = "create table if not exists BrowingTabel(itemId primary key not null,sellPrice not null,image not null, name not null,date not null);"
        //订单信息
        let sql2 = "CREATE TABLE IF NOT EXISTS newOrderTabel (stockId TEXT PRIMARY KEY NOT NULL,stockCount INTEGER,count INTEGER,itemId TEXT NOT NULL,sellPrice TEXT NOT NULL,originPrice TEXT NOT NULL,name TEXT NOT NULL,categoryId TEXT NOT NULL,dockId TEXT,dockName TEXT,phone not null,purchaseNum not null);"
        //创建收货地址
        let sql3 = "create table if not exists shippingAddressTable(recordId integer primary key autoincrement, account text not null, addressId text not null, areaCode integer, isDefault integer, name text not null, phone text not null, street text not null);"
        //创建自提人信息表
        let sql4 = "create table if not exists pickUpUserTable(account text primary key, name text not null, phone text not null);"
        //商家资质认证
        let sql5 = "create table if not exists businessAuthenticate(account text primary key, companyName text, identityCode text, identityFront text, identityBack text, phone text, areaCode integer, street text, businessLicenceCode text, businessLicence text, status integer, reason text);"
        _ = fmdb!.executeUpdate(sql1, withArgumentsIn: nil)
        _ = fmdb!.executeUpdate(sql2, withArgumentsIn: nil)
        _ = fmdb!.executeUpdate(sql3, withArgumentsIn: nil)
        _ = fmdb!.executeUpdate(sql5, withArgumentsIn: nil)
        _ = fmdb!.executeUpdate(sql4, withArgumentsIn: nil)

        
    }
    func clearTempCache() {
        //筛选记录
        clearBuyNowFilterSelectedAttributeIds()
        clearCategoryFilterSelectedAttributeIds()
        clearKeywordFilterSelectedAttributeIds()
        clearKeywordFilterSelectedCategoryIdAndSelectedAttributeIds()
        //短信验证码发送时间
        clearAllSMSCodeSendTimeSendInterval()
        
    }
    func clearBuyNowFilterSelectedAttributeIds() {
        let userDef = UserDefaults.standard
        userDef.removeObject(forKey: PSKeyName_BuyNowFilter)
        userDef.synchronize()
    }

    func clearCategoryFilterSelectedAttributeIds() {
        let userDef = UserDefaults.standard
        userDef.removeObject(forKey: PSKeyName_CategoryFilter)
        userDef.synchronize()
        
    }
    func clearKeywordFilterSelectedAttributeIds() {
        let userDef = UserDefaults.standard
        userDef.removeObject(forKey: PSKeyName_KeywordFilter)
        userDef.synchronize()
        
    }
    
    func clearKeywordFilterSelectedCategoryIdAndSelectedAttributeIds() {
        let userDef = UserDefaults.standard
        userDef.removeObject(forKey: PSKeyName_KeywordFilter_SelectedCategory)
        userDef.removeObject(forKey: PSKeyName_KeywordFilter_SelectedStoreAttributes)
        userDef.removeObject(forKey: PSKeyName_KeywordFilter_SelectedRequestAttributes)
        userDef.synchronize()
        
    }
    func clearAllSMSCodeSendTimeSendInterval() {
        clearTimeSendIntervalSMSCodeType(codeType:  PSSMSCodeType.PSSMSCodeTypeRegister)
        clearTimeSendIntervalSMSCodeType(codeType:  PSSMSCodeType.PSSMSCodeTypeResetPwd)
        clearTimeSendIntervalSMSCodeType(codeType:  PSSMSCodeType.PSSMSCodeTypeUpdatePwd)
        clearTimeSendIntervalSMSCodeType(codeType:  PSSMSCodeType.PSSMSCodeTypeUpdatePhone)
        
    }
    func clearTimeSendIntervalSMSCodeType(codeType:PSSMSCodeType) {
        var type :String?
        switch codeType {
        case PSSMSCodeType.PSSMSCodeTypeRegister:
            type = "Register"

        case PSSMSCodeType.PSSMSCodeTypeResetPwd:
            type = "ResetPwd"
        case PSSMSCodeType.PSSMSCodeTypeUpdatePwd:
            type = "UpdatePwd"
        case PSSMSCodeType.PSSMSCodeTypeUpdatePhone :
            type = "UpdatePhone"
    
        }
        let timeKey :String = String(format: "PSKeyName_SMSCode%@_SendTime", type!)
        let accountKey : String = String(format: "PSKeyName_SMSCode%@_SendAccount", type!)
        let userDef = UserDefaults.standard
        userDef.removeObject(forKey: timeKey)
        userDef.removeObject(forKey: accountKey)
        userDef.synchronize()
    }
}
//浏览记录
extension PSLocalDataManager {
    
}
//订单信息
extension PSLocalDataManager {
    
}
//创建收货列表
extension PSLocalDataManager {
    
    func setupShippingAddressList() {
        let token = PSAccountManager.accountManager.fetch()?.accessToken
        let account = PSAccountManager.accountManager.fetch()?.phone
        if token == nil || account == nil {
            return
        }

        PSNetWorkManager.getShippingAddressListWith(success: { (response) in
            
            var sourceList : [PSShippingAddressModel] = [PSShippingAddressModel]()
            let jsonArray : [[String: Any]] = response[PSNetworkKey_Data] as! Array
            
            for dicInfo in jsonArray {
                let addressModel : PSShippingAddressModel = Mapper<PSShippingAddressModel>().map(JSON: dicInfo)!
                //print("addressModel.isDefault=\(addressModel.isDefault)")
                sourceList.append(addressModel)
                
            }
            PSLocalDataManager.localManager.deleteAllShippingAddressWithAccount(accout: account!)
            PSLocalDataManager.localManager.addShippingAddressList(sourceList: sourceList, accout: account!)
            
            
        }, failure: {(response) in

            print("getShippingAddressListWithSuccess failure, result : \(response)");
            
        }, error: { (error) in
            print("getShippingAddressListWithSuccess error, info :  \(error.localizedDescription)")
            
        }, showMsg: true)

        
    }
    
    func deleteAllShippingAddressWithAccount(accout:String) {
        let sql = "delete from \(PSTableName_ShippingAddress) where account='\(accout)';"
        let resultFlag = fmdb?.executeUpdate(sql, withArgumentsIn: nil)
        print("deleteAllShippingAddressWithAccount result :\(resultFlag)")
        
    }
    
    func addShippingAddressList(sourceList: [PSShippingAddressModel],accout: String) {
        for addressModel in sourceList {
            addShippingAddress(addressModel: addressModel, accout: accout)
        }
        
    }
    //添加
    func addShippingAddress(addressModel : PSShippingAddressModel , accout:String) {
        if isExistShippingAddressWith(addressId: addressModel.addressId!, accout: accout) == false {
            
            print("addShippingAddress result : \(fmdb?.executeUpdate("insert into \(PSTableName_ShippingAddress)(account, addressId, areaCode, isDefault, name, phone, street) values( ?, ?, ?, ?, ?, ?, ?);", withArgumentsIn: [accout, addressModel.addressId!, addressModel.areaCode!, addressModel.isDefault!,addressModel.name!, addressModel.phone!, addressModel.street!]))")

            //设置默认地址
            if  addressModel.isDefault == true {
                print("setDefault result : \(fmdb?.executeUpdate("update \(PSTableName_ShippingAddress) set isDefault=0 where account= ? and addressId!= ?;", withArgumentsIn: [accout,addressModel.addressId!]))")
            }
        }else {
            
        }

        
    }
    //修改
    func updateShippingAddress(addressModel: PSShippingAddressModel , accout : String) {
        if isExistShippingAddressWith(addressId: addressModel.addressId!, accout: accout) == false {
         
            print("updateShippingAddress result : \(fmdb?.executeUpdate("update \(PSTableName_ShippingAddress) set areaCode= ?, isDefault=?, name=?, phone=?, street=? where account=? and addressId= ?;", withArgumentsIn: [addressModel.areaCode!, addressModel.isDefault!,addressModel.name!, addressModel.phone!, addressModel.street!,accout, addressModel.addressId!]))")
            //设置默认地址
            if addressModel.isDefault == true {
                print("setDefault result : \(fmdb?.executeUpdate("update \(PSTableName_ShippingAddress) set isDefault=0 where account= ? and addressId!= ?;", withArgumentsIn: [accout,addressModel.addressId!]))")
            }
        }else {
            addShippingAddress(addressModel: addressModel, accout: accout)
        }
    }
    
    //是否存在
    func isExistShippingAddressWith(addressId: String ,accout: String) -> Bool{

        let sql = "select * from \(PSTableName_ShippingAddress) where account='\(accout)' and addressId='\(addressId)';"
        let rs = fmdb?.executeQuery(sql, withArgumentsIn: nil)
        if rs?.next() == true {
            return true
        }
        return false
    }
    
}
//创建自提人信息
extension PSLocalDataManager {
    
}
//商家资质认证
extension PSLocalDataManager {
    
}




































