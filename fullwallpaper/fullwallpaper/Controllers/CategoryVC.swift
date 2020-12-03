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


class CategoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    //Variables
    @IBOutlet var batchUploadBtn: UIButton!
    @IBOutlet var auditBtn: UIButton!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
        initBtns()
    }
    
    func initBtns(){
        if let user = LCApplication.default.currentUser {
            let roleQuery = LCQuery(className: LCRole.objectClassName())
            roleQuery.whereKey("users", .equalTo(user))
            _ = roleQuery.find { result in
                switch result {
                case .success(objects: let roles):
                    for role in roles{
                        if let roleName = role.get("name"){
                            if roleName.stringValue! == "admin"{
                                self.displayBtns()
                                break
                            }
                        }
                    }
                case .failure(error: let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func displayBtns(){
        DispatchQueue.main.async {
            self.auditBtn.alpha = 1
            self.batchUploadBtn.alpha = 1
        }
    }
    
    func initTableView(){
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
