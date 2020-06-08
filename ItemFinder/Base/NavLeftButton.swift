//
//  NavLeftButton.swift
//  VideoMaterial
//
//  Created by xinguang hu on 2019/6/6.
//  Copyright © 2019 Yunbangshou. All rights reserved.
//

import UIKit

class NavLeftButton: UIButton {
    
    public var image_name: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect,imageName: String) {
        super.init(frame: frame)
        image_name = imageName
        setImage(UIImage(named: imageName), for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let image = UIImage(named: image_name)
        return CGRect(x: 0 , y: contentRect.size.height/2 - (image?.size.height)!/2, width: (image?.size.width)!, height: (image?.size.height)!)
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
