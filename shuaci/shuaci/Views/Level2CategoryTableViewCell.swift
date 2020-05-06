//
//  Level1CategoryTableViewCell.swift
//  shuaci
//
//  Created by 任红雷 on 5/5/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class Level2CategoryTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let subcategories = categories[selected_category]!["subcategory"] {
            return subcategories.count + 1
        }
        else
        {
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Level2CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "level2_collection_cell", for: indexPath) as! Level2CollectionViewCell
        if indexPath.row == 0{
            cell.level2_category_button.setTitle("全部", for: .normal)
        }
        else{
            
            var title = ""
            if let category = categories[selected_category] {
                title = category["subcateory"]?[indexPath.row] as! String
            }
            cell.level2_category_button.setTitle(title, for: .normal)
        }
        
        return cell
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
