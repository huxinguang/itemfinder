//
//  AddGroupVC.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/19.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

typealias AddCompletion = ()->Void

class AddGroupVC: BaseViewController {
    
    public var completionHanler : AddCompletion!
    
    @IBOutlet weak var tf: UITextField!
    
    public var type : DetailType!
    public var group : Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tf.becomeFirstResponder()
        if self.type == .edit {
            self.tf.text = self.group!.name!
            self.title = "Edit Group"
        }else{
            self.title = "Add Group"
        }
    }
    
    override func configLeftBarButtonItem() {
        let btn = NavLeftButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imageName: "navi_theme")
        btn.addTarget(self, action: #selector(onCloseBtnClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btn)
        self.navigationItem.leftBarButtonItem = item
    }
    
    override func configRightBarButtonItem() {
        let btn = NavRightButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), title: "Save",color:kAppThemeColor)
        btn.addTarget(self, action: #selector(onSaveBtnClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem = item
    }
    
    @objc private func onCloseBtnClick(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onSaveBtnClick(){
        if tf.text?.count == 0 {
            MBProgressHUD.showTipMessageInView(message: "Group name required", hideDelay: 1.5)
            return
        }
        var group = Group()
        group.name = tf.text
        if type == .add {
            group.create_time = Int32(Date().timeIntervalSince1970)
            if DataManager.share.addGroup(group: group) {
                MBProgressHUD.showTipMessageInView(message: "Successfully added", hideDelay: 1.5)
            }
        }else{
            group.id = self.group!.id!
            if DataManager.share.updateGroup(group: group){
               MBProgressHUD.showTipMessageInView(message: "Successfully edited", hideDelay: 1.5)
            }
        }
        

        dismiss(animated: true) {
            self.completionHanler()
        }
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
