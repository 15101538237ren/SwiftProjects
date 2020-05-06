//
//  Level1CategoryTableViewCell.swift
//  shuaci
//
//  Created by 任红雷 on 5/5/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class Level1CategoryTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var level1_collectionView: UICollectionView!
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: Level1CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "level1_collection_cell", for: indexPath) as? Level1CollectionViewCell
        {
            cell.level1_category_label.text = categories[indexPath.row]?["category"] as? String
            return cell
        }
        return UICollectionViewCell()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.level1_collectionView.delegate = self
        self.level1_collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
