//
//  BaseNavigationController.swift
//  VideoMaterial
//
//  Created by xinguang hu on 2019/4/11.
//  Copyright © 2019 Yunbangshou. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()//去掉黑线
        navigationBar.barTintColor = defaultNaviBarTintColor
        navigationBar.titleTextAttributes = defaultNaviTitleAttributes
        
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0{
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
