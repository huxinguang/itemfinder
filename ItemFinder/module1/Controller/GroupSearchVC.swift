//
//  GroupSearchVC.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/20.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

class GroupSearchVC: BaseViewController {

    private var tf: UITextField!
    @IBOutlet weak var tv: UITableView!
    private var appearByPush: Bool = true
    private var groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTitleView()
        tv.register(UINib(nibName: "LeftCell", bundle: nil), forCellReuseIdentifier: kCellReuseId)
        
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
            groups = DataManager.share.getGroups(keyword: kw)
            tv.reloadData()
            if groups.count == 0 {
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

extension GroupSearchVC: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellReuseId) as! LeftCell
        cell.titleLabel.text = groups[indexPath.row].name
        cell.countLabel.text = String(format: "（%d）", groups[indexPath.row].items!.count)
        cell.items = groups[indexPath.row].items
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appearByPush = false
        let vc = ItemsVC()
        vc.type = .group
        vc.id = groups[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension GroupSearchVC: StatusController {
    var statusView: StatusView? {
        let sv = DefaultStatusView()
        sv.actionButton.setTitleColor(kAppThemeColor, for: .normal)
        return sv
    }
}
