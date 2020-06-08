//
//  RightVC.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/16.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices
import TZImagePickerController

private let headerCellID = "HeaderCellID"

class RightVC: BaseViewController {
    
    private let titles = ["Recommend to friends","Leave a comment","Feedback","Privacy policy","About ItemFinder"]
    private let images = ["recommend","appstore_icon","feedback","pravicy_icon","aboutus"]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "RightVCHeaderCell", bundle: nil), forCellReuseIdentifier: headerCellID)
        tableView.tableFooterView = UIView()
    }

    private func onAvatarClick(){
        let vc = TZImagePickerController(maxImagesCount: 1, delegate: self)
        vc?.navLeftBarButtonSettingBlock = { leftBtn in
            leftBtn?.setImage(UIImage(named: "tz_back"), for: .normal)
            leftBtn?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
            leftBtn?.setTitle("Back", for: .normal)
            leftBtn?.setTitleColor(kAppThemeColor, for: .normal)
            leftBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        vc?.statusBarStyle = .default
        vc?.naviBgColor = UIColor.white
        vc?.naviTitleColor = UIColor.black
        vc?.naviTitleFont = UIFont.boldSystemFont(ofSize: 18)
        vc?.barItemTextColor = kAppThemeColor
        vc?.navigationBar.isTranslucent = false
        vc?.oKButtonTitleColorNormal = kAppThemeColor
        vc?.photoOriginSelImage = UIImage(named: "checkdot_sel")
        vc?.photoOriginDefImage = UIImage(named: "checkdot_nor")
        vc?.allowPickingVideo = false
        vc?.allowTakeVideo = false
        vc?.allowCrop = true
        let rWidth = kScreenWidth - 2*10
        vc?.cropRect = CGRect(x: 10, y: kScreenHeight/2-rWidth/2, width: rWidth, height: rWidth)
        vc?.modalPresentationStyle = .fullScreen
        present(vc!, animated: true, completion: nil)
    }
    
    private func onNameClick(){
        let alertVC = UIAlertController(title: "Edit nickname", message: "Enter your nickname", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let action2 = UIAlertAction(title: "OK", style: .default) {[weak self] (action) in
            guard let strongSelf = self else{ return }
            let tf = alertVC.textFields?.first
            let content = tf?.text?.replacingOccurrences(of: " ", with: "") ?? ""
            if content.count > 0{
                UserDefaults.standard.set(content, forKey: "username")
                UserDefaults.standard.synchronize()
                let cell = strongSelf.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! RightVCHeaderCell
                cell.nameBtn.setTitle(content, for: .normal)
            }else{
                MBProgressHUD.showTipMessageInView(message: "Nickname required", hideDelay: 1.5)
            }
        }
       
        alertVC.addAction(action1)
        alertVC.addAction(action2)
        alertVC.addTextField { (tf) in
            tf.clearButtonMode = .whileEditing
            if let name = UserDefaults.standard.object(forKey: "username") as? String{
                tf.text = name
            }

        }
        present(alertVC, animated: true, completion: nil)

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


extension RightVC: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: headerCellID) as! RightVCHeaderCell
            cell.opreationBlock = { [weak self] clickWhere in
                guard let strongSelf = self else {return}
                if clickWhere == .avatar{
                    strongSelf.onAvatarClick()
                }else{
                    strongSelf.onNameClick()
                }
            }
            cell.selectionStyle = .none
            return cell
            
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: kCellReuseId)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: kCellReuseId)
            }
            cell?.selectionStyle = .none
            cell?.textLabel?.text = titles[indexPath.row]
            cell?.imageView?.image = UIImage(named: images[indexPath.row])
            cell?.accessoryType = .disclosureIndicator
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return kScreenWidth*1/2
        }else{
            return 52*kScreenHeight/667
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let title = titles[indexPath.row]
            if title == "Recommend to friends"{
                let alert = UIAlertController(title: "", message: "Share to...", preferredStyle: .actionSheet)
                if WXApi.isWXAppInstalled() {
                    alert.addAction(UIAlertAction(title: "WeChat", style: .default, handler: { (action) in
                        let req = SendMessageToWXReq()
                        req.text = "I recommend ItemFinder to you, it is very convenient to use, you can go to the App Store to download it"
                        req.bText = true
                        req.scene = 0
                        WXApi.send(req, completion: nil)
                    }))
                }
                
                if QQApiInterface.isQQInstalled() {
                    alert.addAction(UIAlertAction(title: "QQ", style: .default, handler: { (action) in
                        let txtObj = QQApiTextObject(text: "I recommend ItemFinder to you, it is very convenient to use, you can go to the App Store to download it")
                        let req = SendMessageToQQReq(content: txtObj)
                        QQApiInterface.send(req)
                    }))
                }
                
                alert.addAction(UIAlertAction(title: "SMS", style: .default, handler: { (action) in
                    if MFMessageComposeViewController.canSendText(){
                        let sms = MFMessageComposeViewController()
                        sms.body = "I recommend ItemFinder to you, it is very convenient to use, you can go to the App Store to download it"
                        sms.messageComposeDelegate = self
                        sms.modalPresentationStyle = .fullScreen
                        self.present(sms, animated: true, completion: nil)
                    }else{
                        MBProgressHUD.showInfoInView(message: "Your device does not have a SIM card", hideDelay: 1.5)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Mail", style: .default, handler: { (action) in
                    if MFMailComposeViewController.canSendMail(){
                        let mail = MFMailComposeViewController()
                        mail.setSubject("Recommendation")
                        mail.setMessageBody("I recommend ItemFinder to you, it is very convenient to use, you can go to the App Store to download it", isHTML: false)
                        mail.mailComposeDelegate = self
                        mail.modalPresentationStyle = .fullScreen
                        self.present(mail, animated: true, completion: nil)
                    }else{
                        MBProgressHUD.showInfoInView(message: "You have not set up mailing for this device", hideDelay: 1.5)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                
                if alert.responds(to: #selector(getter: popoverPresentationController)) {
                    let cell = tableView.cellForRow(at: indexPath)
                    alert.popoverPresentationController?.sourceView = cell
                    alert.popoverPresentationController?.sourceRect = CGRect(x: kScreenWidth, y: 0, width: 0, height: 52*kScreenHeight/667)
                }
                
                present(alert, animated: true, completion: nil)
                
            }else if title == "Leave a comment"{
                let appUrl = URL(string: "itms-apps://itunes.apple.com/app/id1476484409?action=write-review")!
                if UIApplication.shared.canOpenURL(appUrl){
                    UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
                }
                
            }else if title == "Feedback"{
                if MFMailComposeViewController.canSendMail(){
                    let mail = MFMailComposeViewController()
                    mail.navigationBar.tintColor = kAppThemeColor
                    mail.setSubject("ItemFinder feedback")
                    let msgBody = String(format: "For the current version of ItemFinder:%@,%@,OS %@\n my suggestions：\n1、\n2、\n3、", UIApplication.shared.appVersion!,UIDevice.current.machineModel!,UIDevice.current.systemVersion)
                    mail.setMessageBody(msgBody, isHTML: false)
                    mail.setToRecipients(["hxg0925@163.com"])
                    mail.mailComposeDelegate = self
                    mail.modalPresentationStyle = .fullScreen
                    present(mail, animated: true, completion: nil)
                }else{
                    MBProgressHUD.showTipMessageInView(message: "You have not set up mailing for this device", hideDelay: 1.5)
                }
            }else if title == "Privacy policy"{
                let sf = SFSafariViewController(url: URL(string: "https://raw.githubusercontent.com/huxinguang/pravicy/master/ItemFinder.md")!)
                sf.preferredBarTintColor = UIColor.white
                sf.preferredControlTintColor = kAppThemeColor
                if #available(iOS 11.0, *){
                    sf.dismissButtonStyle = .close
                }
                sf.modalPresentationStyle = .fullScreen
                present(sf, animated: true, completion: nil)
            }else if title == "About ItemFinder"{
                let vc = AboutVC()
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
}

extension RightVC: TZImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        let image = photos[0]
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        let imagePath = docPath! + "avatar.jpg"
        let data = image.jpegData(compressionQuality: 0.3)
        if FileManager.default.fileExists(atPath: imagePath) {
            do{
                try FileManager.default.removeItem(atPath: imagePath)
                try data?.write(to: URL(fileURLWithPath: imagePath))
            } catch{
                MBProgressHUD.showTipMessageInView(message: "Edit failed ", hideDelay: 1.5)
            }
        }else{
            do {
                try data?.write(to: URL(fileURLWithPath: imagePath))
            } catch{
                MBProgressHUD.showTipMessageInView(message: "Edit failed", hideDelay: 1.5)
            }
        }
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! RightVCHeaderCell
        cell.avatarBtn.setImage(image, for: .normal)
    }

}

extension RightVC: MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        var msg = ""
        if result == .cancelled {
            msg = "Canceled"
        }else if result == .sent{
            msg = "Succeed"
        }else{
            msg = "Failed"
        }
        MBProgressHUD.showTipMessageInWindow(message: msg, hideDelay: 1.5)
        controller.dismiss(animated: true, completion: nil)
        
    }

}

extension RightVC: MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        var msg = ""
        if result == .cancelled {
            msg = "Canceled"
        }else if result == .sent{
            msg = "Succeed"
        }else{
            msg = "Failed"
        }
        MBProgressHUD.showTipMessageInWindow(message: msg, hideDelay: 1.5)
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
