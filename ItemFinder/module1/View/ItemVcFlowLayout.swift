//
//  ItemVcFlowLayout.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/16.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

class ItemVcFlowLayout: UICollectionViewFlowLayout {

    let cellSpacing: CGFloat = 12.0
    let lineSpacing: CGFloat = 15.0
    let margin: CGFloat = 15.0
    let count: CGFloat = 3.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollDirection = .vertical
        let exactW = (kScreenWidth - (count-1)*cellSpacing - 2*margin)/count
        let exactH = exactW
        let itemW = Int(exactW)
        let itemH = Int(exactH)
        itemSize = CGSize(width: itemW, height: itemH)
        minimumLineSpacing = lineSpacing
        minimumInteritemSpacing = cellSpacing
        sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 10, right: margin)
    }
    
}
