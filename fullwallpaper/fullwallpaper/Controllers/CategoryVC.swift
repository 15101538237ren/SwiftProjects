//
//  CategoryVC.swift
//  fullwallpaper
//
//  Created by Honglei on 10/29/20.
//

import UIKit

class CategoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var titles = ["艺术", "插画", "可爱", "卡通", "文字"]
    var images = ["art", "illustration", "cute", "cartoon", "word"]
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .clear
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryTableViewCell", for: indexPath) as! CategoryTableViewCell
        let row: Int = indexPath.row
        cell.imageV.image = UIImage(named: images[row])
        cell.titleLabel.text = titles[row]
        return cell
    }
}
