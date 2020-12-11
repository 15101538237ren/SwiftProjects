//
//  VIPBenifitsVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/10/20.
//

import UIKit
import LeanCloud
import UIEmptyState

class VIPBenefitsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate {
    var imgNames:[String] = ["membership", "restore"]
    var titles:[String] = ["专属壁纸，享受特权", "精选壁纸，每日更新"]
    var descriptions:[String] = ["解锁PRO会员壁纸，尽享专属尊贵", "精选壁纸，每日更新"]
    
    //Variables
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardImgView: UIImageView!{
        didSet{
            cardImgView.layer.cornerRadius = 12.0
            cardImgView.layer.masksToBounds = true
        }
    }
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
    }
    
    func initTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        emptyStateDataSource = self
        emptyStateDelegate = self
        self.tableView.tableHeaderView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "vipBenefitTableViewCell", for: indexPath) as! VIPBenefitTableViewCell
        let row: Int = indexPath.row
        cell.imgView.image = UIImage(named: imgNames[row]) ?? UIImage()
        cell.titleLbl.text = titles[row]
        cell.descriptionLbl.text = descriptions[row]
        return cell
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
