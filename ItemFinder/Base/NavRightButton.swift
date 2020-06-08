//
//  NavRightButton.swift
//  VideoMaterial
//
//  Created by xinguang hu on 2019/6/11.
//  Copyright © 2019 Yunbangshou. All rights reserved.
//

import UIKit

class NavRightButton: UIButton {
    
    private var imageName: String!
    private var titleString: String!
    private var titleFont: UIFont!
    private var titleColor: UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect,imageName: String = "",title: String = "",font: UIFont = UIFont.systemFont(ofSize: 17),color: UIColor = UIColor.white){
        super.init(frame: frame)
        self.imageName = imageName
        titleString = title
        titleFont = font
        if !imageName.isEmpty {
            setImage(UIImage(named: imageName), for: .normal)
        }
        if !title.isEmpty {
            setTitle(title, for: .normal)
            titleLabel?.font = font
            setTitleColor(color, for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        if imageName.isEmpty {
            return CGRect.zero
        }else{
            let image = UIImage(named: imageName)
            return CGRect(x: bounds.size.width - (image?.size.width)! , y: contentRect.size.height/2 - (image?.size.height)!/2, width: (image?.size.width)!, height: (image?.size.height)!)
        }
        
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        if titleString.isEmpty {
            return CGRect.zero
        }else{
            let titleString: NSString = self.titleString! as NSString
            let titleSize = titleString.size(withAttributes: [NSAttributedString.Key.font: titleFont!])
            return CGRect(x: bounds.size.width - titleSize.width, y: bounds.size.height/2 - titleSize.height/2, width: titleSize.width , height: titleSize.height)
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
