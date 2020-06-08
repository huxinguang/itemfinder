//
//  ItemDetailVC.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/16.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

private let headerCellReuseID = "headerCellReuseID"
//private let normalCellReuseID = "normalCellReuseID"

enum DetailType {
    case add
    case edit
}

class ItemDetailVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    public var image: UIImage?
    private let configTitles = ["Group","Space"]
    private let configImages = ["group_icon","space_icon"]
    private var groups : [Group]?
    private var spaces : [Space]?
    private var selectedGroup : Group?
    private var selectedSpace : Space?
    public var completionHanler : AddCompletion!
    public var type : DetailType!
    public var item : Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if type == .add {
            title = "Add Item"
        }else{
            title = "Item Infomation"
            item = DataManager.share.getItem(item_id: item!.id!)
        }
        
        tableView.register(UINib(nibName: "ItemAddHeaderCell", bundle: nil), forCellReuseIdentifier: headerCellReuseID)
        tableView.tableFooterView = UIView()
    }
    
    override func configRightBarButtonItem() {
        let btn = NavRightButton(frame: CGRect(x: 0, y: 0, width: 44, height: 30), title: "Save",color:kAppThemeColor)
        btn.addTarget(self, action: #selector(onSaveBtnClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btn)
        navigationItem.rightBarButtonItem = item
    }

    @objc private func onSaveBtnClick(){
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ItemAddHeaderCell
        if cell.textView.text.count <= 0 {
            MBProgressHUD.showTipMessageInView(message: "Item description required", hideDelay: 1.5)
            return
        }
        
        var item = Item()
        item.description = cell.textView.text
        if type == .add {
            item.create_time = Int32(Date().timeIntervalSince1970)
            
            if let group = selectedGroup{
                item.group_id = group.id
            }else{
                item.group_id = 0
            }
            
            if let space = selectedSpace{
                item.space_id = space.id
            }else{
                item.space_id = 0
            }
            
        }else{
            item.id = self.item!.id!
            item.create_time = self.item!.create_time
            if let group = self.selectedGroup{
                if group.id == self.item!.group_id!{
                    item.sequence_group = self.item!.sequence_group!
                }else{
                    item.sequence_group = DataManager.share.getMaxSequenceOfItemInGroup(group_id: group.id)+1
                }
                
                item.group_id = group.id
            }else{
                item.group_id = self.item!.group_id!
                item.sequence_group = self.item!.sequence_group!
            }
            
            if let space = self.selectedSpace{
                if space.id == self.item!.space_id!{
                    item.sequence_space = self.item!.sequence_space!
                }else{
                    item.sequence_space = DataManager.share.getMaxSequenceOfItemInSpace(space_id: space.id)+1
                }
                item.space_id = space.id
                
            }else{
                item.space_id = self.item!.space_id!
                item.sequence_space = self.item!.sequence_space!
            }
            
        }
        
        let put = QCloudCOSXMLUploadObjectRequest<AnyObject>()
        if image != nil {
            item.pic_width = Int32(image!.size.width)
            item.pic_height = Int32(image!.size.height)
            
            let data = image!.jpegData(compressionQuality: 0.5)
            put.object = String(format: "ios/%d.jpg", Int(Date().timeIntervalSince1970*1000))
            put.bucket = kQCloudBucket
            put.body = data as AnyObject?
            put.setFinish { [weak self] (outputObject, error) in
                
                if error != nil{
                    DispatchQueue.main.async {
                        MBProgressHUD.showTipMessageInView(message: "图片上传失败，请稍后重试", hideDelay: 1.5)
                    }
                    return
                }
                item.pic_url = outputObject?.location
                DispatchQueue.main.async {
                    guard let strongSelf = self else { return }
                    strongSelf.saveItem(item: item)
                }
                
            }
            QCloudCOSTransferMangerService.defaultCOSTransferManager()?.uploadObject(put)
            
        }else{
            item.pic_url = self.item!.pic_url
            item.pic_width = self.item!.pic_width
            item.pic_height = self.item!.pic_height
            item.sequence = self.item!.sequence
            saveItem(item: item)
        }
        

    }
    
    func saveItem(item: Item) {
        if type == .add {
            if DataManager.share.addItem(item: item){
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    MBProgressHUD.showTipMessageInWindow(message: "Item Added", hideDelay: 1.5)
                    strongSelf.navigationController?.popViewController(animated: true)
                    strongSelf.completionHanler()
                }
            }
        }else{
            if DataManager.share.updateItem(item: item){
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    MBProgressHUD.showTipMessageInWindow(message: "Update completed", hideDelay: 1.5)
                    strongSelf.navigationController?.popViewController(animated: true)
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

extension ItemDetailVC: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return configTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: headerCellReuseID) as! ItemAddHeaderCell
            if type == .add{
                cell.imgView.image = image
            }else{
                if image == nil{
                    cell.imgView.kf.setImage(with: URL(string: item!.pic_url!))
                }else{
                    cell.imgView.image = image
                }
                cell.textView.text = item!.description!
            }
            
            return cell
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: kCellReuseId)
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: kCellReuseId)
            }
            
            cell?.textLabel?.text = configTitles[indexPath.row]
            cell?.imageView?.image = UIImage(named: configImages[indexPath.row])
            if type == .edit{
                if indexPath.row == 0{
                    cell?.detailTextLabel?.text = item!.group_name ?? ""
                }else{
                    cell?.detailTextLabel?.text = item!.space_name ?? ""
                }
                
            }
            cell?.accessoryType = .disclosureIndicator
            cell?.selectionStyle = .none
            return cell!
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return kScreenWidth + 75.0 + 10.0
        }else{
            return 60.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let vc = ConfigVC()
            vc.configTitle = "选择" + configTitles[indexPath.row]
            if indexPath.row == 0{
                vc.type = .group
                groups = DataManager.share.getGroups(edit: true)
                vc.data = groups
            }else{
                vc.type = .space
                spaces = DataManager.share.getSpaces(edit: true)
                vc.data = spaces
            }
            vc.chooseBlock = {[weak self](index) in
                guard let strongSelf = self else{return}
                let cell = tableView.cellForRow(at: indexPath)
                if indexPath.row == 0{
                    let group = strongSelf.groups![index]
                    cell?.detailTextLabel?.text = group.name
                    strongSelf.selectedGroup = group
                    
                }else{
                    let space = strongSelf.spaces![index]
                    cell?.detailTextLabel?.text = space.name
                    strongSelf.selectedSpace = space
                }
                
            }
            let nav = BaseNavigationController(rootViewController: vc)
            nav.setNavigationBarHidden(true, animated: false)
            nav.modalPresentationStyle = .overCurrentContext
            nav.modalTransitionStyle = .coverVertical
            DispatchQueue.main.async {[weak self] in
                guard let strongSelf = self else{ return }
                strongSelf.present(nav, animated: false, completion: nil)
            }
        }
        
    }
    
    
    
}
