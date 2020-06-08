//
//  SpaceSearchVC.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/19.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

class SpaceSearchVC: BaseViewController {
    
    private var tf: UITextField!
    
    @IBOutlet weak var cv: UICollectionView!
    
    private var appearByPush: Bool = true
    
    private var spaces = [Space]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTitleView()
        cv.register(UINib(nibName: "SpaceCell", bundle: nil), forCellWithReuseIdentifier: kCellReuseId)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if appearByPush {
            tf.becomeFirstResponder()
        }
    }
    
    private func configTitleView(){
        let tf = UITextField(frame: CGRect(x: 0, y: 0, width: kScreenWidth-20*2-44-60-8*2, height: 30))
        tf.placeholder = "Enter keyword here"
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.tintColor = kAppThemeColor
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        navigationItem.titleView = tf
        self.tf = tf
    }
    
    override func configRightBarButtonItem() {
        let btn = NavRightButton(frame: CGRect(x: 0, y: 0, width: 60, height: 44), title:"Search",color:kAppThemeColor)
        btn.addTarget(self, action: #selector(onRightBtnClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btn)
        navigationItem.rightBarButtonItem = item
    }
    
    override func onRightBtnClick() {
        tf.resignFirstResponder()
        let kw = tf.text!
        if kw.count > 0{
            spaces = DataManager.share.getSpaces(keyword: kw)
            cv.reloadData()
            if spaces.count == 0 {
                showEmpty()
            }else{
                hideStatus()
            }
        }else{
            MBProgressHUD.showTipMessageInView(message: "A keyword required", hideDelay: 1.5)
        }
    }

    func showEmpty(){
        let status = Status(title: "No related data", description: "Please try another keyword", actionTitle: "", image: UIImage(named: "empty_list")) {
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

extension SpaceSearchVC: UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuseId, for: indexPath) as! SpaceCell
        cell.titleLabel.text = spaces[indexPath.item].name
        cell.countLabel.text = String(format: "（%d）", spaces[indexPath.item].itemCount)
        cell.imgView.kf.setImage(with: URL(string: spaces[indexPath.item].pic_url!))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ItemsVC()
        vc.type = .space
        vc.id = spaces[indexPath.item].id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}


extension SpaceSearchVC: StatusController {
    var statusView: StatusView? {
        let sv = DefaultStatusView()
        sv.actionButton.setTitleColor(kAppThemeColor, for: .normal)
        return sv
    }
}
