//
//  ConfigCell.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/23.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

class ConfigCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let imgV = UIImageView()
        imgV.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        accessoryView = imgV
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if let img = imageView?.image {
            imageView?.image = UIImage(named: "img_default")
            super.layoutSubviews()
            imageView?.image = img
        }else{
            super.layoutSubviews()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        let av = accessoryView as! UIImageView
        if selected {
            av.image = UIImage(named: "checkbox_sel")
        }else{
            av.image = UIImage(named: "checkbox_nor")
        }
        
    }

}
