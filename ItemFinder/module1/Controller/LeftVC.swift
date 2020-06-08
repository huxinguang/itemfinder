//
//  LeftVC.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/20.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit
import TZImagePickerController

class LeftVC: BaseViewController {
    
    @IBOutlet weak var tv: UITableView!
    
    private var groups = [Group]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tv.register(UINib(nibName: "LeftCell", bundle: nil), forCellReuseIdentifier: kCellReuseId)
    }
    
    override func configLeftBarButtonItem() {
        let allBtn = NavLeftButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imageName: "items_all")
        allBtn.addTarget(self, action: #selector(onAllBtnClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: allBtn)
        navigationItem.leftBarButtonItem = item
    }
    
    override func configRightBarButtonItem() {
        let searchBtn = NavRightButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imageName: "search")
        searchBtn.addTarget(self, action: #selector(onSearchBtnClick), for: .touchUpInside)
        let editBtn = NavRightButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imageName: "config_icon")
        editBtn.addTarget(self, action: #selector(onEditBtnClick), for: .touchUpInside)
        
        let searchItem = UIBarButtonItem(customView: searchBtn)
        let editItem = UIBarButtonItem(customView: editBtn)
        navigationItem.rightBarButtonItems = [searchItem,editItem]
    }

    @objc private func onAllBtnClick(){
        let vc = ItemsVC()
        vc.type = .all
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc private func onSearchBtnClick(){
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "Search Group", style: .default) {[weak self] (action) in
            guard let strongSelf = self else {return}
            let vc = GroupSearchVC()
            strongSelf.navigationController?.pushViewController(vc, animated: true)
        }

        let action2 = UIAlertAction(title: "Search Item", style: .default) {[weak self] (action) in
            guard let strongSelf = self else {return}
            let vc = ItemSearchVC()
            strongSelf.navigationController?.pushViewController(vc, animated: true)
        }
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action) in

        }

        alertVC.addAction(action1)
        alertVC.addAction(action2)
        alertVC.addAction(action3)
        
        if alertVC.responds(to: #selector(getter: popoverPresentationController)) {
            alertVC.popoverPresentationController?.sourceView = navigationItem.rightBarButtonItems![0].customView
            alertVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 44, height: 44);
        }
        
        present(alertVC, animated: true, completion: nil)
        
    }
    
    @objc private func onEditBtnClick(){
        let vc = EditVC()
        vc.type = .group
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "Add a group", style: .default) {[weak self] (action) in
            guard let strongSelf = self else {return}
            let vc = AddGroupVC()
            vc.type = .add
            vc.completionHanler = {[weak self] in
                guard let strongSelf = self else{ return }
                strongSelf.loadData()
            }
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            strongSelf.present(nav, animated: true, completion: nil)
        }
        
        let action2 = UIAlertAction(title: "Add an item", style: .default) {[weak self] (action) in
            guard let strongSelf = self else {return}
            let vc = TZImagePickerController(maxImagesCount: 1, delegate: strongSelf)
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
            vc?.modalPresentationStyle = .fullScreen
            strongSelf.present(vc!, animated: true, completion: nil)
        }
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        alertVC.addAction(action1)
        alertVC.addAction(action2)
        alertVC.addAction(action3)
        
        if alertVC.responds(to: #selector(getter: popoverPresentationController)) {
            alertVC.popoverPresentationController?.sourceView = sender
            alertVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 40, height: 40);
        }
        present(alertVC, animated: true, completion: nil)
    }
    
    func loadData(){
        groups = DataManager.share.getGroups()
        tv.reloadData()
        if groups.count == 0 {
            showEmpty()
        }else{
            hideStatus()
        }
    }
    
    func showEmpty(){
        let status = Status(title: "No group yet", image: UIImage(named: "empty_list")) {
        }
        show(status: status)
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

extension LeftVC: UITableViewDataSource, UITableViewDelegate,TZImagePickerControllerDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellReuseId) as! LeftCell
        cell.titleLabel.text = groups[indexPath.row].name
        cell.countLabel.text = String(format: "（%d）", groups[indexPath.row].items!.count)
        cell.items = groups[indexPath.row].items
        if cell.items.count > 0 {
            cell.cv.isHidden = false
            cell.tipLabel.isHidden = true
        }else{
            cell.cv.isHidden = true
            cell.tipLabel.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ItemsVC()
        vc.type = .group
        vc.id = groups[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Mark: TZImagePickerControllerDelegate
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        let vc = ItemDetailVC()
        vc.image = photos[0]
        vc.type = .add
        vc.completionHanler = {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.loadData()
        }
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}

extension LeftVC: StatusController {
    var statusView: StatusView? {
        let sv = DefaultStatusView()
        sv.actionButton.setTitleColor(kAppThemeColor, for: .normal)
        return sv
    }
    
}
