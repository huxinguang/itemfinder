//
//  ItemsVC.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/16.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit
import NotificationBannerSwift

enum ItemsVcType {
    case all
    case group
    case space
}

class ItemsVC: BaseViewController {
    
    public var type : ItemsVcType!
    public var id : Int32?
    private var showDeleteBtn : Bool = false
    @IBOutlet weak var cv : UICollectionView!
    private var data : [Item]!
    private var rightBtn : NavRightButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        if data.count > 0 {
            if (UserDefaults.standard.object(forKey: "TipShown") == nil) {
                let banner = StatusBarNotificationBanner(title: "Long press to edit and sort", style: .info ,colors: CustomBannerColors())
                banner.show()
                UserDefaults.standard.set("True", forKey: "TipShown")
                UserDefaults.standard.synchronize()
            }
        }
        cv.register(UINib(nibName: "ItemShadowCell", bundle: nil), forCellWithReuseIdentifier: kCellReuseId)
    }
    
    func showEmpty(){
        let status = Status(title: "No item yet", image: UIImage(named: "empty_list")) {
        }
        show(status: status)
    }
    
    override func configRightBarButtonItem() {
        let btn = NavRightButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), title: "Done",color:kAppThemeColor)
        btn.addTarget(self, action: #selector(onRightBtnClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btn)
        navigationItem.rightBarButtonItem = item
        rightBtn = btn
        rightBtn.isHidden = true
    }
    
    override func onRightBtnClick() {
        showDeleteBtn = false
        rightBtn.isHidden = true
        cv.reloadData()
    }
    
    func loadData() {
        switch type! {
        case .all:
            title = "All Items"
            data = DataManager.share.getItems()
            break
        case .group:
            title = "Group.Items"
            data = DataManager.share.getItemsInGroup(group_id: id!)
            break
        case .space:
            title = "Space.Items"
            data = DataManager.share.getItemsInSpace(space_id: id!)
            break
            
        }
        cv.reloadData()
        if data.count == 0 {
            showEmpty()
        }else{
            hideStatus()
        }
    }
    

    @IBAction func handleGesture(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            if let indexPath = cv.indexPathForItem(at: sender.location(in: self.cv)){
                rightBtn.isHidden = false
                showDeleteBtn = true
                for cell in cv.visibleCells as![ItemShadowCell]{
                    cell.deleteBtn.isHidden = false
                }
                cv.beginInteractiveMovementForItem(at: indexPath)
            }
            break
        case .changed:
            cv.updateInteractiveMovementTargetPosition(sender.location(in: self.cv))
            break
        case .ended:
            cv.endInteractiveMovement()
            break
        default:
            cv.cancelInteractiveMovement()
            break
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

extension ItemsVC: UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuseId, for: indexPath) as! ItemShadowCell
        cell.deleteBtn.isHidden = !showDeleteBtn
        cell.imgView.kf.setImage(with: URL(string: data[indexPath.item].pic_url!))
        cell.deleteBlock = { [weak self] in
            guard let strongSelf = self else { return }
            if DataManager.share.deleteItem(item_id: strongSelf.data[indexPath.row].id!) {
                strongSelf.data.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    strongSelf.cv.reloadData()
                }
                if strongSelf.data.count == 0 {
                    strongSelf.showEmpty()
                    strongSelf.showDeleteBtn = false
                    strongSelf.rightBtn.isHidden = true
                }
                
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let sourceItem = data[sourceIndexPath.row]
        var currentIndex = sourceIndexPath.row
        if sourceIndexPath.row <= destinationIndexPath.row{
            for _ in sourceIndexPath.row..<destinationIndexPath.row{
                currentIndex = data.firstIndex(where: { (element) -> Bool in
                    element.id == sourceItem.id
                })!
                
                if currentIndex < destinationIndexPath.row{
                    data.swapAt(currentIndex, currentIndex+1)
                    currentIndex += 1
                }
            }
        }else{
            for _ in destinationIndexPath.row..<sourceIndexPath.row{
                currentIndex = data.firstIndex(where: { (element) -> Bool in
                    element.id == sourceItem.id
                })!
                if currentIndex > destinationIndexPath.row{
                    data.swapAt(currentIndex, currentIndex-1)
                    currentIndex -= 1
                }
            }
        }
        
        if type == .all {
            if DataManager.share.updateItemsSequence(items: data){
                self.loadData()
            }
        }else if type == .group{
            if DataManager.share.updateItemsSequenceInGroup(items: data){
                self.loadData()
            }
        }else if type == .space{
            if DataManager.share.updateItemsSequenceInSpace(items: data){
                self.loadData()
            }
            
        }
        
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ItemDetailVC()
        vc.item = self.data[indexPath.item]
        vc.type = .edit
        vc.completionHanler = {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.loadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    
}

extension ItemsVC: StatusController {
    var statusView: StatusView? {
        let sv = DefaultStatusView()
        sv.actionButton.setTitleColor(kAppThemeColor, for: .normal)
        return sv
    }
    
}

class CustomBannerColors: BannerColorsProtocol {
    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .info:
            return kAppThemeColor
        default:
            return kAppThemeColor
        }
    }

}



