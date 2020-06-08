//
//  ItemAddHeaderCell.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/16.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

class ItemAddHeaderCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var textView: UITextView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.xg_placeholder = "Add a description to the item so that you can search for it later using keywords."
        textView.xg_placeholderColor = UIColor(hexString: "cccccc")
        textView.tintColor = kAppThemeColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
