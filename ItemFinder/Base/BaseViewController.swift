//
//  BaseViewController.swift
//  VideoMaterial
//
//  Created by xinguang hu on 2019/6/6.
//  Copyright © 2019 Yunbangshou. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController,UINavigationControllerDelegate,UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationController?.delegate = self;
        //启用滑动返回
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        configLeftBarButtonItem()
        configRightBarButtonItem()
    }
    
    func configLeftBarButtonItem(){
        if navigationController?.viewControllers.count ?? 0 > 1  {
            let backBtn = NavLeftButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imageName: defaultNaviBackBtnImageName)
            backBtn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: backBtn)
            navigationItem.leftBarButtonItem = barButtonItem
        }
    }
    
    func configRightBarButtonItem(){
        if navigationController?.viewControllers.count ?? 0 > 1 {
            // swift 默认参数语法应用
            let rightBtn = NavRightButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), title: "保存")
            // rightBtn.backgroundColor = UIColor.black
            rightBtn.addTarget(self, action: #selector(onRightBtnClick), for: .touchUpInside)
            
            let barButtonItem = UIBarButtonItem(customView: rightBtn)
            navigationItem.rightBarButtonItem = barButtonItem
            
        }
    }
    
    
    //是否允许侧滑返回
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == navigationController?.interactivePopGestureRecognizer) {
            //只有二级以及以下的页面允许手势返回
            return navigationController?.viewControllers.count ?? 0 > 1
        }
        return true
    }
    
    
    @objc internal func onBack() -> Void{
        navigationController?.popViewController(animated: true)
    }
    
    @objc internal func onRightBtnClick() -> Void{
        
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
