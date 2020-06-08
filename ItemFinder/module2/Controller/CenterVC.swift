//
//  CenterVC.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/20.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit
import TZImagePickerController

class CenterVC: BaseViewController {

    @IBOutlet weak var cv: UICollectionView!
    private var spaces = [Space]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cv.register(UINib(nibName: "SpaceCell", bundle: nil), forCellWithReuseIdentifier: kCellReuseId)
        
    }

    override func configLeftBarButtonItem() {
        let btn = NavLeftButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imageName: "config_icon")
        btn.addTarget(self, action: #selector(onEditBtnClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btn)
        navigationItem.leftBarButtonItem = item
    }
    
    override func configRightBarButtonItem() {
        let btn = NavRightButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imageName: "search")
        btn.addTarget(self, action: #selector(onSearchBtnClick), for: .touchUpInside)
        let item = UIBarButtonItem.init(customView: btn)
        navigationItem.rightBarButtonItem = item
    }
    
    @objc private func onEditBtnClick(){
        let vc = EditVC()
        vc.type = .space
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func onSearchBtnClick(){
        let vc = SpaceSearchVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        let vc = TZImagePickerController(maxImagesCount: 1, delegate: self)
        vc?.navLeftBarButtonSettingBlock = { leftBtn in
            leftBtn?.setImage(UIImage(named: "tz_back"), for: .normal)
            leftBtn?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
            leftBtn?.setTitle("返回", for: .normal)
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
        present(vc!, animated: true, completion: nil)
    }
    
    
    private func loadData(){
        spaces = DataManager.share.getSpaces()
        DispatchQueue.main.async {
            self.cv.reloadData()
        }
        if spaces.count == 0 {
            showEmpty()
        }else{
            hideStatus()
        }
        
    }
    
    func showEmpty(){
        let status = Status(title: "No space yet", image: UIImage(named: "empty_list")) {
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


extension CenterVC: UICollectionViewDataSource,UICollectionViewDelegate,TZImagePickerControllerDelegate{
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
    
    
    // Mark: TZImagePickerControllerDelegate
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        let vc = SpaceAddVC()
        vc.image = photos[0]
        vc.type = .add
        vc.completionHanler = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.loadData()
        }
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}


extension CenterVC: StatusController {
    var statusView: StatusView? {
        let sv = DefaultStatusView()
        sv.actionButton.setTitleColor(kAppThemeColor, for: .normal)
        return sv
    }
    
}
