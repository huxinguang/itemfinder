//
//  SpaceAddVC.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/22.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

class SpaceAddVC: BaseViewController {
    
    public var completionHanler : AddCompletion!
    
    public var image: UIImage?

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var tf: UITextField!
    
    public var type : DetailType!
    public var space : Space?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if type == .edit {
            title = "Edit Space"
            tf.text = self.space!.name!
            imgView.kf.setImage(with: URL(string: space!.pic_url!))
            configLeftItem()
        }else{
            title = "Add Space"
            imgView.image = image
        }
    }
    
    private func configLeftItem() {
        let btn = NavLeftButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imageName: "navi_theme")
        btn.addTarget(self, action: #selector(onCloseBtnClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btn)
        navigationItem.leftBarButtonItem = item
    }
    
    override func configRightBarButtonItem() {
        let btn = NavRightButton(frame: CGRect(x: 0, y: 0, width: 44, height: 30), title: "Save",color:kAppThemeColor)
        btn.addTarget(self, action: #selector(onSaveBtnClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btn)
        navigationItem.rightBarButtonItem = item
    }
    
    @objc private func onCloseBtnClick(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onSaveBtnClick(){
        
        var space = Space()
        space.name = tf.text
        
        if type == .add {
            space.pic_width = Int32(image!.size.width)
            space.pic_height = Int32(image!.size.height)
            space.create_time = Int32(Date().timeIntervalSince1970)
        }else{
            space.id = self.space!.id!
            space.create_time = self.space!.create_time!
            space.sequence = self.space!.sequence!
            if image != nil{
                space.pic_width = Int32(image!.size.width)
                space.pic_height = Int32(image!.size.height)
            }else{
                space.pic_width = self.space!.pic_width!
                space.pic_height = self.space!.pic_height!
            }
            
        }
        
        if image != nil {
            let put = QCloudCOSXMLUploadObjectRequest<AnyObject>()
            let data = image!.jpegData(compressionQuality: 0.5)
            put.object = String(format: "ios/%d.jpg", Int(Date().timeIntervalSince1970*1000))
            put.bucket = kQCloudBucket
            put.body = data as AnyObject?
            put.setFinish { [weak self] (outputObject, error) in
                
                if error != nil{
                    DispatchQueue.main.async {
                        MBProgressHUD.showTipMessageInView(message: "Upload failed, pleace retry later", hideDelay: 1.5)
                    }
                    return
                }
                space.pic_url = outputObject?.location
                DispatchQueue.main.async {
                    guard let strongSelf = self else { return }
                    strongSelf.saveSpace(space: space)
                }
                
            }
            QCloudCOSTransferMangerService.defaultCOSTransferManager()?.uploadObject(put)
        }else{
            space.pic_url = self.space!.pic_url!
            saveSpace(space: space)
        }
        
        
    }
    
    func saveSpace(space: Space) {
        
        if type == .add {
            if DataManager.share.addSpace(space: space){
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    MBProgressHUD.showTipMessageInWindow(message: "Addition  completed", hideDelay: 1.5)
                    strongSelf.navigationController?.popViewController(animated: true)
                    strongSelf.completionHanler()
                }
            }
        }else{
            if DataManager.share.updateSpace(space: space){
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    MBProgressHUD.showTipMessageInWindow(message: "Updating completed", hideDelay: 1.5)
                    strongSelf.dismiss(animated: true, completion: nil)
                    strongSelf.completionHanler()
                }
                
            }
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
