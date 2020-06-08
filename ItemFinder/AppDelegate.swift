//
//  AppDelegate.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/8.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit
import CoreData
import SnapKit
import Alamofire
import IQKeyboardManagerSwift
import Kingfisher
import LeanCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public var launchNetworkNotReachable: Bool!
    private var qqOAuth: TencentOAuth!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setUpKeyboard()
        UMConfigure.initWithAppkey(kUMengAppKey, channel: "App Store")
        WXApi.registerApp(kWeChatAppId, universalLink: kWeChatUniversalLink)
        qqOAuth = TencentOAuth(appId: kQQAppId, andUniversalLink: kQQUniversalLink, andDelegate: self)
        configUPush(options: launchOptions)
        setupCOSXMLShareService()
        setupLeanCloud()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = initTabBarController()
        window?.makeKeyAndVisible()
        return true
    }
    
    private func setupLeanCloud(){
        LCApplication.logLevel = .all
        do {
            try LCApplication.default.set(
                id: "PE1XcPzpMK7dlrdsYUvfRLnk-MdYXbMMI",
                key: "7zmLdlVWxX4308LnMLlxLKjA"
            )
        } catch {
            fatalError("\(error)")
        }
    }
    
    private func setUpKeyboard(){
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    private func monitorNetwork(){
        let manager = NetworkReachabilityManager()
        manager?.listener = { status in
            switch status {
            case .unknown:
                MBProgressHUD.showTipMessageInWindow(message: "网络连接异常", hideDelay: 1.5)
                break
            case .notReachable:
                MBProgressHUD.showTipMessageInWindow(message: "无网络连接", hideDelay: 1.5)
                break
            case .reachable(.wwan):
                print("蜂窝网")
                break
            case .reachable(.ethernetOrWiFi):
                print("WIFI")
                break
            }
        }
        manager?.startListening()
    }

    func initTabBarController() -> UITabBarController {
        let tabVC: UITabBarController = UITabBarController()
        // tabVC.tabBar.shadowImage = UIImage()
        tabVC.tabBar.backgroundImage = UIImage.createImage(color: UIColor.white, size: CGSize(width: kScreenWidth, height: kTabbarHeight))
        tabVC.tabBar.barTintColor = UIColor.white
        tabVC.tabBar.isTranslucent = false
        
        let vc1 = LeftVC()        
        let vc2 = CenterVC()
        let vc3 = RightVC()
        let vcs = [vc1,vc2,vc3]
        let titles = ["Groups","Spaces","More"]
        let images_nor = ["tabbar1_nor","tabbar2_nor","tabbar3_nor"]
        let images_sel = ["tabbar1_sel","tabbar2_sel","tabbar3_sel"]
        
        for i in 0..<titles.count {
            let vc = vcs[i]
            vc.title = titles[i]
            let item = UITabBarItem(title: titles[i], image: UIImage(named: images_nor[i])?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: images_sel[i])?.withRenderingMode(.alwaysOriginal))
            item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(hexString: "bfbfbf"),NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)], for: .normal)
            item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:kAppThemeColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)], for: .selected)
            
            let nav = BaseNavigationController(rootViewController: vc)
            nav.tabBarItem = item
            tabVC.addChild(nav)
        }
        return tabVC
    }
    
    private func setupCOSXMLShareService(){
        let configuration = QCloudServiceConfiguration()
        configuration.appID = kQCloudAppID
        configuration.signatureProvider = self
        let endpoint = QCloudCOSXMLEndPoint()
        endpoint.regionName = kQCloudRegion
        configuration.endpoint = endpoint
        QCloudCOSXMLService.registerDefaultCOSXML(with: configuration)
        QCloudCOSTransferMangerService.registerDefaultCOSTransferManger(with: configuration)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if WXApi.handleOpen(url, delegate: self) {
            return true
        }
        if TencentOAuth.canHandleOpen(url) {
            return TencentOAuth.handleOpen(url)
        }
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType != NSUserActivityTypeBrowsingWeb || userActivity.webpageURL == nil {
            return false
        }
        if let urlString = userActivity.webpageURL?.absoluteString {
            if urlString.hasPrefix(kWeChatUniversalLink + kWeChatAppId) {
                return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
            }else if urlString.hasPrefix(kQQUniversalLink){
                if TencentOAuth.canHandleUniversalLink(userActivity.webpageURL) {
                    return TencentOAuth.handleUniversalLink(userActivity.webpageURL)
                }
                
            }
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }


}


extension AppDelegate : QCloudSignatureProvider{
    
    func signature(with fileds: QCloudSignatureFields!, request: QCloudBizHTTPRequest!, urlRequest urlRequst: NSMutableURLRequest!, compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
        
        let credential = QCloudCredential()
        credential.secretID = kQCloudSecretID
        credential.secretKey = kQCloudSecretKey
        let creator = QCloudAuthentationV5Creator(credential: credential)
        let signature = creator?.signature(forData: urlRequst)
        continueBlock(signature,nil)
    }
    
}

extension AppDelegate : UNUserNotificationCenterDelegate{
    
    /*
    收到通知时，在不同的状态在点击通知栏的通知时所调用的方法不同。未启动时，点击通知的回调方法是：
    
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    
    而对应的通知内容则为
    
    NSDictionary * userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    当pushNotificationKey为nil时，说明用户是直接点击APP进入的，如果点击的是通知栏，那么即为对应的通知内容。
    */
    
    func configUPush(options: [UIApplication.LaunchOptionsKey: Any]?) {
        // Push组件基本功能配置
        let entity = UMessageRegisterEntity()
        //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
        entity.types = Int(UMessageAuthorizationOptions.badge.rawValue|UMessageAuthorizationOptions.sound.rawValue|UMessageAuthorizationOptions.alert.rawValue)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        UMessage.registerForRemoteNotifications(launchOptions: options, entity: entity) { (granted, error) in
            if (granted) {
            }else{
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UMessage.registerDeviceToken(deviceToken)
        var token: String!
        if #available(iOS 13.0, *){
            token = deviceToken.reduce("", {$0 + String(format: "%02x", $1)})
        }else{
            token = deviceToken.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
        }
        print("######"+token)
        
    }
    
    //iOS10新增：处理前台收到通知的代理方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let trigger = notification.request.trigger, trigger.isKind(of: UNPushNotificationTrigger.self){
            //应用处于前台时的远程推送接受
            //关闭U-Push自带的弹出框
            UMessage.setAutoAlert(false)
            //必须加这句代码
            UMessage.didReceiveRemoteNotification(notification.request.content.userInfo)
        }else{
            //应用处于前台时的本地推送接受
        }
        
        completionHandler([.sound,.badge,.alert])
        
    }
    
    //iOS10新增：处理后台点击通知的代理方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let trigger = response.notification.request.trigger, trigger.isKind(of: UNPushNotificationTrigger.self) {
            let userInfo = response.notification.request.content.userInfo
            //应用处于后台时的远程推送接受
            //必须加这句代码
            UMessage.didReceiveRemoteNotification(userInfo)
            if let info = userInfo as? [String : Any] {
                receivePush(userInfo: info)
            }
        }else{
            //应用处于后台时的本地推送接受
        }
    }
    
    func receivePush(userInfo : [String : Any]) {}
}

extension AppDelegate : WXApiDelegate{
    
    func onReq(_ req: BaseReq) {
        
    }
    
    func onResp(_ resp: BaseResp) {
        if resp.isMember(of: SendAuthResp.self) {
            NotificationCenter.default.post(name: NSNotification.Name.App.WxAuthRespNotification, object: nil, userInfo: ["resp":resp])
        }
    }
    
}

extension AppDelegate : TencentSessionDelegate{
    
    func tencentDidLogin() {
        
    }
    
    func tencentDidNotLogin(_ cancelled: Bool) {
        
    }
    
    func tencentDidNotNetWork() {
        
    }
    
}


