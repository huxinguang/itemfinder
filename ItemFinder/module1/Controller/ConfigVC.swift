//
//  ConfigVC.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/21.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit
import SnapKit

enum ConfigType {
    case group
    case space
}

typealias ChooseBlock = (Int)->Void

class ConfigVC: BaseViewController {
    
    private var topConstraint : Constraint!
    public var configTitle : String!
    public var type : ConfigType!
    public var data : [Any]!
    private var cv : ConfigView!
    public var chooseBlock : ChooseBlock!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(configDataDidChange), name: NSNotification.Name(rawValue: "GroupChangeNotification"), object: nil)
        
        let ctrl = UIControl()
        ctrl.addTarget(self, action: #selector(hide), for: .touchUpInside)
        view.addSubview(ctrl)
        ctrl.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let cv = Bundle.main.loadNibNamed("ConfigView", owner: nil, options: nil)?.first as! ConfigView
        cv.type = type
        cv.data = data
        cv.titleLabel.text = configTitle
        cv.handler = {[weak self] (operationType,index)  in
            guard let strongSelf = self else { return }
            switch operationType {
            case .close:
                strongSelf.hide()
                break
            case .setting:
                let vc = EditVC()
                if strongSelf.type == .group{
                    vc.type = .group
                }else{
                    vc.type = .space
                }
                let nav = BaseNavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true, completion: nil)
                break
            case .choose:
                strongSelf.hide()
                strongSelf.chooseBlock(index!)
                break
            }
            
        }
        view.addSubview(cv)
        cv.snp.makeConstraints { (make) in
            self.topConstraint = make.top.equalToSuperview().offset(kScreenHeight).constraint
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(kScreenHeight/2)
        }
        
        self.cv = cv
        
        view.layoutIfNeeded()
        topConstraint.update(offset: kScreenHeight/2)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
            self.view.layoutIfNeeded()
        }) { (finished) in
            
        }
        
        
    }
    
    private func loadData(){
        if type == .group {
            data = DataManager.share.getGroups()
        }else{
            data = DataManager.share.getSpaces()
        }
    }
    
    @objc private func hide(){
        topConstraint.update(offset: kScreenHeight)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = UIColor.clear
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished{
                self.dismiss(animated: false, completion: nil)
            }
        }
        
    }
    
    @objc private func configDataDidChange(){
        loadData()
        cv.tv.reloadData()
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



