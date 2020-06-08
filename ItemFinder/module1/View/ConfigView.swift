//
//  ConfigView.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/21.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ConfigCellID"

enum UserOperationType {
    case close
    case setting
    case choose
}

typealias OperationHandler = (UserOperationType,Int?)->Void

class ConfigView: UIView {

    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var configBtn: UIButton!
    public var handler: OperationHandler!
    public var type: ConfigType!
    public var data: [Any]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tv.delegate = self
        tv.dataSource = self
        
    }
    
    @IBAction func onCloseClick(_ sender: UIButton) {
        handler(.close,nil)
    }
    
    @IBAction func onConfigClick(_ sender: UIButton) {
        handler(.setting,nil)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension ConfigView: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if cell == nil {
            cell = ConfigCell(style: .value1, reuseIdentifier: reuseIdentifier)
        }
        cell?.selectionStyle = .none
        if type == .space {
            let space = data[indexPath.row] as! Space
            cell?.textLabel?.text = space.name            
            cell?.imageView?.kf.setImage(with: URL(string: space.pic_url!))
        }else{
            let group = data[indexPath.row] as! Group
            cell?.textLabel?.text = group.name
        }
        return cell!

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(true, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) { [weak self] in
            guard let strongSelf = self else{return}
            strongSelf.handler(.choose,indexPath.row)
        }
    }
    
}
