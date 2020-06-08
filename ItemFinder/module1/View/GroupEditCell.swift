//
//  GroupEditCell.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/16.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

typealias MoreBlock = ()->Void

class GroupEditCell: UITableViewCell {

    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    public var moreBlock : MoreBlock!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func moreBtnClick(_ sender: UIButton) {
        moreBlock()
    }
    
    
}
