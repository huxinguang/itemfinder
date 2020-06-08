//
//  YbsConstant.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/8.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit
import DynamicColor


//############################ AppDelegate ###########################

let kAppDelegate = UIApplication.shared.delegate as! AppDelegate

//############################## 屏幕适配 ##############################

let kScreenHeight :CGFloat = UIScreen.main.bounds.height
let kScreenWidth :CGFloat  = UIScreen.main.bounds.width

//判断是否为iPad
let IsPad = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)


//判断是否iPhone X/Xs
let IS_iPhoneX_Or_Xs = (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? (CGSize(width: 1125, height: 2436) == UIScreen.main.currentMode!.size) && !IsPad : false)

//判断iPHoneXr
let Is_iPhoneXr1 = (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? (CGSize(width: 828, height: 1792) == UIScreen.main.currentMode!.size) && !IsPad : false)

let Is_iPhoneXr2 = (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? (CGSize(width: 750, height: 1624) == UIScreen.main.currentMode!.size) && !IsPad : false)

//判断iPhoneXs Max
let IS_iPhoneXs_Max = (UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) ? (CGSize(width: 1242, height: 2688) == UIScreen.main.currentMode!.size) && !IsPad : false)

//判断是否为带刘海的iPhone
let IS_X_Series = (IS_iPhoneX_Or_Xs || Is_iPhoneXr1 || Is_iPhoneXr2 || IS_iPhoneXs_Max)

//状态栏高度
let kStatusBarHeight :CGFloat = (IS_X_Series ? 44.0 : 20.0)

//导航栏高度（不包含状态栏）
let kNavigationBarHeight :CGFloat = 44.0

//Tabbar 高度
let kTabbarHeight :CGFloat = (IS_X_Series ? (49.0 + 34.0) : 49.0)

//Tabbar 底部安全距离
let kTabbarSafeBottomMargin :CGFloat = (IS_X_Series ? 34.0 : 0.0)

//状态栏和导航栏总高度
let kStatusBarAndNavigationBarHeight :CGFloat = (IS_X_Series ? 88.0 : 64.0)

//############################ app样式配置 ############################

//默认导航栏标题颜色和字体


let defaultNaviBackBtnImageName = "navi_back_theme"
let defaultNaviTitleAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 18)]
let defaultNaviBarTintColor = UIColor.white




//################################ 接口 ###############################
let baseReleaseUrl = ""
let baseDebugUrl = ""
let baseTestUrl = ""


//############################## 接口状态码 ############################
let kSuccessCode = "200"
let kCodeKey = "code"
let kDataKey = "data"
let kMessageKey = "msg"
let kTokenExpiredCode = "5555"

//############################## 第三方SDK #############################


//UMeng
let kUMengAppKey = "5d64d15e4ca357dd9800013d"
let kWeChatAppId = "wx873db41a963d947b"
let kWeChatAppSecret = "d89bca38b0036931761762eedfcbc0c4"
let kWeChatUniversalLink = "https://www.balamoney.com/itemfinder/"

let kQQAppId = "101847188"
let kQQAppKey = "ead9ddd3b2e456ff3a36873c4ac0ddb0"
let kQQUniversalLink = "https://www.balamoney.com/qq_conn/101847188"


//tencent cos
let kQCloudAppID = "1259131898"
let kQCloudRegion = "ap-beijing"
let kQCloudSecretID = "AKID2sSnzypHbfU3MSltFNFsHQP9fy1pPfhX"
let kQCloudSecretKey = "kHYZNwFI8i28zbx3tb7OQDk24qRowoRp"
let kQCloudBucket = "aso-cos-1259131898"


//keychain key
let kDeviceIDKeychainKey = "kDeviceIDKeychainKey"
let kDeviceMAKeychainKey = "kDeviceMAKeychainKey"
let kDeviceTokenKeychainKey = "kDeviceTokenKeychainKey"

//color
let kAppThemeColor = UIColor(hexString: "EB4788")

// cellReuseIdentifier
let kCellReuseId = "CommonReuseIdentifier"















