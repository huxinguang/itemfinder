//
//  SpaceEditCell.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/23.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

class SpaceEditCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    public var moreBlock : MoreBlock!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onMoreClick(_ sender: UIButton) {
        moreBlock()
    }
}
