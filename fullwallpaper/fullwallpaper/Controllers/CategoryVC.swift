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
    //Constants
    let loadCollectionLimit:Int = 1000
    
    //Variables
    var isCategory:Bool = true // Whether is category or collection
    var NoNetwork = false
    var collections:[LCObject] = []
    var minVolOfLastCollectionFetch: Int? = nil
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!{
        didSet{
            segmentedControl.setTitle(classificationStr, forSegmentAt: 0)
            segmentedControl.setTitle(collectionStr, forSegmentAt: 1)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.text = classificationText
            if english{
                titleLabel.font = UIFont(name: "Clicker Script", size: 25.0)
            }
        }
    }
    fileprivate var timeOnThisPage: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tictoc), userInfo: nil, repeats: true)
        initTableView()
        setSegmentedControl()
    }
    
    @objc func tictoc(){
        timeOnThisPage += 1
    }
    
    func setSegmentedControl(){
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray], for: .normal)
        segmentedControl.theme_backgroundColor = "SegmentedCtrlTintColor"
        segmentedControl.theme_selectedSegmentTintColor = "SegmentedCtrlSelectedTintColor"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var info = ["Um_Key_PageName": "分类/专题浏览", "Um_Key_Duration": timeOnThisPage] as [String : Any]
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
        
        self.tableView.addLoadMore(action: { [weak self] in
            self?.handleLoadMore()
        })
        
        loadCollections()
    }
    
    private func handleLoadMore() {
        loadCollections()
    }
    
    func loadCollections(){
        if !Reachability.isConnectedToNetwork(){
            self.tableView.reloadData()
            NoNetwork = true
            self.reloadEmptyStateForTableView(self.tableView)
            stopIndicator()
            return
        }
        
        DispatchQueue.global(qos: .utility).async { [self] in
        do {
            let query = LCQuery(className: "Collection")
            query.whereKey("vol", .descending)
            
            if (minVolOfLastCollectionFetch != nil){
                query.whereKey("vol", .lessThan(minVolOfLastCollectionFetch!))
            }
            
            query.limit = loadCollectionLimit
            
            _ = query.find() { result in
                switch result {
                case .success(objects: let results):
                    if results.count == 0{
                        DispatchQueue.main.async {
                            tableView.stopLoadMore()
                            tableView.setLoadMoreEnable(false)
                            self.reloadEmptyStateForTableView(tableView)
                            stopIndicator()
                        }
                        return
                    }
                    
                    print("Fetched \(results.count) collections")
                    collections.append(contentsOf: results)
                    
                    if let vol = collections[collections.count - 1].get("vol")?.intValue{
                        
                        minVolOfLastCollectionFetch = vol
                    }
                    
                    DispatchQueue.main.async {
                        tableView.reloadData()
                        NoNetwork = false
                        self.reloadEmptyStateForTableView(tableView)
                        stopIndicator()
                        if collections.count > loadCollectionLimit{
                            self.tableView.stopLoadMore()
                        }
                    }
                    
                    break
                case .failure(error: let error):
                    print(error.localizedDescription)
                }
            }
        }
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
        let count = isCategory ? categories.count : collections.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryTableViewCell", for: indexPath) as! CategoryTableViewCell
        let row: Int = indexPath.row
        if isCategory{
            cell.titleLabel.text = english ? categories[row].eng.capitalized: categories[row].name.capitalized
            
            let imgUrl = URL(string: categories[row].coverUrl)!
            Nuke.loadImage(with: imgUrl, options: categoryLoadingOptions, into: cell.imageV)
        }else{
            let attrName:String = english ? "enName": "name"
            if let title = collections[row].get(attrName)?.stringValue{
                
                if let volume = collections[row].get("vol")?.intValue{
                    if english{
                        cell.titleLabel.text = "Vol.\(volume) - \(title)"
                    }else{
                        cell.titleLabel.text = "第 \(volume) 期 - \(title)"
                    }
                }
                
            }
            
            if let file = collections[row].get("cover") as? LCFile{
                let imgUrl = URL(string: file.url!.stringValue!)!
                Nuke.loadImage(with: imgUrl, options: categoryLoadingOptions, into: cell.imageV)
            }
        }
        
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
    
    func loadCollectionItemsVC(collection: LCObject){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let collectionItemsVC = mainStoryBoard.instantiateViewController(withIdentifier: "collectionItemsVC") as! CollectionItemsVC
        
        collectionItemsVC.collection = collection
        
        collectionItemsVC.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            self.present(collectionItemsVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isCategory{
            loadCategoryCollectionVC(category: categories[indexPath.row].eng, categoryCN: categories[indexPath.row].name)
        }else{
            loadCollectionItemsVC(collection: collections[indexPath.row])
        }
        
    }
    // MARK: - Empty State Data Source
    
    var emptyStateTitle: NSAttributedString {
            let attrs = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
            let title: String = NoDataCheckNetStr
            return NSAttributedString(string: title, attributes: attrs)
        }
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        isCategory.toggle()
        tableView.reloadData()
    }
    
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        emptyView.contentView.layer.borderColor = UIColor.clear.cgColor
        emptyView.contentView.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?){
        if traitCollection.userInterfaceStyle == .light {
            setTheme(theme: .day)
        } else {
            setTheme(theme: .night)
        }
    }
}

