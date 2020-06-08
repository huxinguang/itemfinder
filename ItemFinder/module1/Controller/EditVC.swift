//
//  EditVC.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/16.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

enum EditType {
    case group
    case space
}

class EditVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    public var type : EditType!
    private var data = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if type == .group {
            title = "Edit Group"
            tableView.register(UINib(nibName: "GroupEditCell", bundle: nil), forCellReuseIdentifier: kCellReuseId)
        }else{
            title = "Edit Space"
            tableView.register(UINib(nibName: "SpaceEditCell", bundle: nil), forCellReuseIdentifier: kCellReuseId)
        }
        tableView.tableFooterView = UIView()
        
        
        loadData()
        tableView.setEditing(true, animated: false)
        
    }
    
    override func configLeftBarButtonItem() {
        var imageName : String!
        if navigationController?.viewControllers.count ?? 0 > 1  {
            imageName = defaultNaviBackBtnImageName
        }else{
            imageName = "navi_theme"
        }

        let backBtn = NavLeftButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imageName: imageName)
        backBtn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: backBtn)
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    override func onBack() {
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "GroupChangeNotification")))
        
        if navigationController?.viewControllers.count ?? 0 > 1  {
            navigationController?.popViewController(animated: true)
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
    

    private func loadData(){
        if type == .group {
            data = DataManager.share.getGroups(edit:true)
        }else{
            data = DataManager.share.getSpaces(edit:true)
        }
        tableView.reloadData()
    }
    
    func showActionSheet(indexPath : IndexPath ){
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "Edit", style: .default) {[weak self] (action) in
            guard let strongSelf = self else {return}
            if strongSelf.type == .group{
                let vc = AddGroupVC()
                vc.type = .edit
                vc.group = strongSelf.data[indexPath.row] as? Group
                vc.completionHanler = {
                    strongSelf.loadData()
                }
                let nav = BaseNavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true, completion: nil)
            }else{
                
                let vc = SpaceAddVC()
                vc.type = .edit
                vc.space = strongSelf.data[indexPath.row] as? Space
                vc.completionHanler = { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.loadData()
                }
                let nav = BaseNavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true, completion: nil)
            }

        }
        
        let action2 = UIAlertAction(title: "Delete", style: .destructive) {[weak self] (action) in
            guard let strongSelf = self else {return}
            if strongSelf.type == .group{
                let gp = strongSelf.data[indexPath.row] as! Group
                if DataManager.share.deleteGroup(group_id: gp.id!){
                    strongSelf.loadData()
                }
            }else{
                let sp = strongSelf.data[indexPath.row] as! Space
                if DataManager.share.deleteSpace(space_id: sp.id!){
                    strongSelf.loadData()
                }
            }
            
        }
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        alertVC.addAction(action1)
        alertVC.addAction(action2)
        alertVC.addAction(action3)
        
        if alertVC.responds(to: #selector(getter: popoverPresentationController)) {
            var sourceView: UIView!
            if type == .group {
                let cell = tableView.cellForRow(at: indexPath) as! GroupEditCell
                sourceView = cell.moreBtn
            }else{
                let cell = tableView.cellForRow(at: indexPath) as! SpaceEditCell
                sourceView = cell.moreBtn
            }
            
            alertVC.popoverPresentationController?.sourceView = sourceView
            alertVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 30, height: 30);
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

extension EditVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if type == .group {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCellReuseId) as! GroupEditCell
            let data = self.data[indexPath.row] as! Group
            cell.titleLabel.text = data.name
            cell.moreBlock = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.showActionSheet(indexPath: indexPath)
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: kCellReuseId) as! SpaceEditCell
            let data = self.data[indexPath.row] as! Space
            cell.titleLabel.text = data.name
            cell.imgView.kf.setImage(with: URL(string: data.pic_url!))
            cell.moreBlock = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.showActionSheet(indexPath: indexPath)
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if type == .group {
            
            let sourceGroup = data[sourceIndexPath.row] as! Group
            var currentIndex = sourceIndexPath.row
            if sourceIndexPath.row <= destinationIndexPath.row{
                for _ in sourceIndexPath.row..<destinationIndexPath.row{
                    currentIndex = data.firstIndex(where: { (element) -> Bool in
                        (element as! Group).id == sourceGroup.id
                    })!
                    
                    if currentIndex < destinationIndexPath.row{
                        data.swapAt(currentIndex, currentIndex+1)
                        currentIndex += 1
                    }
                }
            }else{
                for _ in destinationIndexPath.row..<sourceIndexPath.row{
                    currentIndex = data.firstIndex(where: { (element) -> Bool in
                        (element as! Group).id == sourceGroup.id
                    })!
                    if currentIndex > destinationIndexPath.row{
                        data.swapAt(currentIndex, currentIndex-1)
                        currentIndex -= 1
                    }
                }
            }
            
            if DataManager.share.updateGroupsSequence(groups: data as! [Group]){
               loadData()
            }
        
        }else{
            let sourceSpace = data[sourceIndexPath.row] as! Space
            var currentIndex = sourceIndexPath.row
            if sourceIndexPath.row <= destinationIndexPath.row{
                for _ in sourceIndexPath.row..<destinationIndexPath.row{
                    currentIndex = data.firstIndex(where: { (element) -> Bool in
                        (element as! Space).id == sourceSpace.id
                    })!
                    
                    if currentIndex < destinationIndexPath.row{
                        data.swapAt(currentIndex, currentIndex+1)
                        currentIndex += 1
                    }
                }
            }else{
                for _ in destinationIndexPath.row..<sourceIndexPath.row{
                    currentIndex = data.firstIndex(where: { (element) -> Bool in
                        (element as! Space).id == sourceSpace.id
                    })!
                    if currentIndex > destinationIndexPath.row{
                        data.swapAt(currentIndex, currentIndex-1)
                        currentIndex -= 1
                    }
                }
            }
            
            if DataManager.share.updateSpacesSequence(spaces: data as! [Space]){
                self.loadData()
            }

        }
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    
    
}
