//
//  ItemShadowCell.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/16.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

typealias DeleteBlock = ()->Void

class ItemShadowCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    public var deleteBlock : DeleteBlock!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onDeleteClick(_ sender: UIButton) {
        deleteBlock()
    }
    
}
