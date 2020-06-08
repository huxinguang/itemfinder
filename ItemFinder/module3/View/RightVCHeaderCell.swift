//
//  RightVCHeaderCell.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/27.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

enum ClickWhere {
    case avatar
    case name
}
typealias SetOpreationBlock = (ClickWhere)->Void

class RightVCHeaderCell: UITableViewCell {

    @IBOutlet weak var avatarBtn: UIButton!
    
    @IBOutlet weak var nameBtn: UIButton!
    
    public var opreationBlock: SetOpreationBlock!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarBtn.layer.cornerRadius = kScreenWidth/4/2
        avatarBtn.layer.masksToBounds = true
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        let imagePath = docPath! + "avatar.jpg"
        if FileManager.default.fileExists(atPath: imagePath) {
            avatarBtn.setImage(UIImage(contentsOfFile: imagePath), for: .normal)
        }else{
            avatarBtn.setImage(UIImage(named: "avatar"), for: .normal)
        }
        
        if let name = UserDefaults.standard.object(forKey: "username") as? String{
            nameBtn.setTitle(name, for: .normal)
        }else{
            nameBtn.setTitle("Click to set your nickname", for: .normal)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func avatarClick(_ sender: UIButton) {
        opreationBlock(.avatar)
    }
    
    @IBAction func nameClick(_ sender: Any) {
        opreationBlock(.name)
    }
    
}
