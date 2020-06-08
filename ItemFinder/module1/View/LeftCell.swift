//
//  LeftCell.swift
//  ItemFinder
//
//  Created by xinguang hu on 2019/8/15.
//  Copyright © 2019 huxinguang. All rights reserved.
//

import UIKit

class LeftCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var tipLabel: UILabel!
    public var items : [Item]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cv.delegate = self
        cv.dataSource = self
        cv.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: "ItemCellID")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cv.reloadData()
    }
    

}

extension LeftCell: UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCellID", for: indexPath) as! ItemCell
        cell.imgView.kf.setImage(with: URL(string: items[indexPath.item].pic_url!))
        return cell
    }
    
    
    
}
