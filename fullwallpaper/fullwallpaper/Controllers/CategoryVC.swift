//
//  CategoryVC.swift
//  fullwallpaper
//
//  Created by Honglei on 10/29/20.
//

import UIKit
import Nuke
import LeanCloud
import UIEmptyState
import JGProgressHUD
import SwiftTheme


class CategoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    //Variables
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    fileprivate var timeOnThisPage: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tictoc), userInfo: nil, repeats: true)
        initTableView()
    }
    
    @objc func tictoc(){
        timeOnThisPage += 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var info = ["Um_Key_PageName": "分类浏览", "Um_Key_Duration": timeOnThisPage] as [String : Any]
        if let user = LCApplication.default.currentUser{
            let userId = user.objectId!.stringValue!
            info["Um_Key_UserID"] = userId
        }
        UMAnalyticsSwift.event(eventId: "Um_Event_PageView", attributes: info)
    }
    
    func initTableView(){
        titleLabel.theme_textColor = "BarTitleColor"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        emptyStateDataSource = self
        emptyStateDelegate = self
        self.tableView.separatorColor = .clear
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if categories.count == 0{
            initIndicator(view: self.view)
            loadCategories(completion: loadCategoryCompletionHandler)
        }
    }
    
    func loadCategoryCompletionHandler() -> Void{
        self.tableView.reloadData()
        self.reloadEmptyStateForTableView(self.tableView)
        stopIndicator()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryTableViewCell", for: indexPath) as! CategoryTableViewCell
        let row: Int = indexPath.row
        cell.titleLabel.text = categories[row].name
        let imgUrl = URL(string: categories[row].coverUrl)!
        Nuke.loadImage(with: imgUrl, options: categoryLoadingOptions, into: cell.imageV)
        return cell
    }
    
    func loadCategoryCollectionVC(category: String, categoryCN: String){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let categoryCollectionVC = mainStoryBoard.instantiateViewController(withIdentifier: "categoryCollectionVC") as! CategoryCollectionVC
        
        categoryCollectionVC.category = category
        categoryCollectionVC.categoryCN = categoryCN
        categoryCollectionVC.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            self.present(categoryCollectionVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loadCategoryCollectionVC(category: categories[indexPath.row].eng, categoryCN: categories[indexPath.row].name)
    }
    // MARK: - Empty State Data Source
    
    var emptyStateTitle: NSAttributedString {
            let attrs = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
            let title: String = "没有数据，请检查网络！"
            return NSAttributedString(string: title, attributes: attrs)
        }
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        emptyView.contentView.layer.borderColor = UIColor.clear.cgColor
        emptyView.contentView.layer.backgroundColor = UIColor.clear.cgColor
    }
}
