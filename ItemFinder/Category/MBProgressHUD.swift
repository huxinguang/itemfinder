//
//  MBProgressHUD+YbsUtil.swift
//  VideoMaterial
//
//  Created by xinguang hu on 2019/4/4.
//  Copyright © 2019 Yunbangshou. All rights reserved.
//

import Foundation

extension MBProgressHUD{
    
    fileprivate static func createHUD(message:String, isWindow:Bool) -> MBProgressHUD {
        let hudSuperView: UIView = isWindow ? UIApplication.shared.keyWindow! :
            UIViewController.currentViewController().view!
        let hud = MBProgressHUD.showAdded(to: hudSuperView, animated: true)
        hud.label.text = message
        hud.label.font = UIFont.systemFont(ofSize: 15)
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        hud.contentColor = UIColor.white
        hud.margin = 15
        hud.removeFromSuperViewOnHide = true
        return hud
    }
    
    // ####################### Text #########################
    
    static func showTipMessageInView(message: String, hideDelay:TimeInterval) -> Void {
        showTipMessage(message: message, isWindow: false, hideDelay: hideDelay)
    }
    
    static func showTipMessageInWindow(message: String, hideDelay:TimeInterval) -> Void {
        showTipMessage(message: message, isWindow: true, hideDelay: hideDelay)
    }
    
    fileprivate static func showTipMessage(message: String,isWindow: Bool, hideDelay:TimeInterval) -> Void {
        let hud = createHUD(message: message, isWindow: isWindow)
        hud.mode = .text
        hud.hide(animated: true, afterDelay: hideDelay)
    }
    
    // ####################### Activity #######################
    
    static func showActivityMessageInView(message: String) -> Void {
        showActivityMessage(message: message, isWindow: false)
    }
    
    static func showActivityMessageInWindow(message: String) -> Void {
        showActivityMessage(message: message, isWindow: true)
    }
    
    fileprivate static func showActivityMessage(message: String, isWindow: Bool) -> Void {
        let hud = createHUD(message: message, isWindow: isWindow)
        hud.mode = .indeterminate
    }
    
    // ####################### Image #######################
    
    static func showSuccessInView(message: String, hideDelay: TimeInterval) -> Void {
        showImageMessageInView(imageName: "MBHUD_Success", message: message, hideDelay: hideDelay)
    }
    
    static func showErrorInView(message: String, hideDelay: TimeInterval) -> Void {
        showImageMessageInView(imageName: "MBHUD_Error", message: message, hideDelay: hideDelay)
    }
    
    static func showInfoInView(message: String, hideDelay: TimeInterval) -> Void {
        showImageMessageInView(imageName: "MBHUD_Info", message: message, hideDelay: hideDelay)
    }
    
    static func showWarningInView(message: String, hideDelay: TimeInterval) -> Void {
        showImageMessageInView(imageName: "MBHUD_Warn", message: message, hideDelay: hideDelay)
    }
    
    static func showSuccessInWindow(message: String, hideDelay: TimeInterval) -> Void {
        showImageMessageInWindow(imageName: "MBHUD_Success", message: message, hideDelay: hideDelay)
    }
    
    static func showErrorInWindow(message: String, hideDelay: TimeInterval) -> Void {
        showImageMessageInWindow(imageName: "MBHUD_Error", message: message, hideDelay: hideDelay)
    }
    
    static func showInfoInWindow(message: String, hideDelay: TimeInterval) -> Void {
        showImageMessageInWindow(imageName: "MBHUD_Info", message: message, hideDelay: hideDelay)
    }
    
    static func showWarningInWindow(message: String, hideDelay: TimeInterval) -> Void {
        showImageMessageInWindow(imageName: "MBHUD_Warn", message: message, hideDelay: hideDelay)
    }
    
    fileprivate static func showImageMessageInView(imageName:String, message: String, hideDelay:TimeInterval) -> Void {
        showImageMessage(imageName: imageName, message: message, isWindow: false, hideDelay: hideDelay)
    }
    
   fileprivate static func showImageMessageInWindow(imageName:String, message: String, hideDelay:TimeInterval) -> Void {
        showImageMessage(imageName: imageName, message: message, isWindow: true, hideDelay: hideDelay)
    }
    
    fileprivate static func showImageMessage(imageName: String, message: String,isWindow: Bool, hideDelay:TimeInterval) -> Void {
        let hud = createHUD(message: message, isWindow: isWindow)
        hud.mode = .customView
        hud.customView = UIImageView.init(image: UIImage.init(named: imageName))
        hud.hide(animated: true, afterDelay: hideDelay)
    }
    
    // ####################### hide #######################
    static func hideHUD() -> Void {
        let view: UIView = UIApplication.shared.keyWindow!
        hide(for: view, animated: true)
        hide(for: UIViewController.currentViewController().view, animated: true)
    }
    
}
