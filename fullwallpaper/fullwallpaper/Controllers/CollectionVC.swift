//
//  CollectionVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/21/20.
//

import UIKit
import Nuke
import UIEmptyState
import JGProgressHUD
import LeanCloud
import Refreshable
import SwiftTheme

class CollectionVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    //Constants
    let loadCollectionLimit:Int = 1000
    
    //Variables
    
    var minVolOfLastCollectionFetch: Int? = nil
    var collections:[LCObject] = []
    var NoNetwork = false
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
        var info = ["Um_Key_PageName": "专题浏览", "Um_Key_Duration": timeOnThisPage] as [String : Any]
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
        self.tableView.addLoadMore(action: { [weak self] in
            self?.handleLoadMore()
        })
        
        initIndicator(view: self.view)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryTableViewCell", for: indexPath) as! CategoryTableViewCell
        let row: Int = indexPath.row
        if let title = collections[row].get("name")?.stringValue{
            
            if let volume = collections[row].get("vol")?.intValue{
                cell.titleLabel.text = "第 \(volume) 期 - \(title)"
            }
            
        }
        
        if let file = collections[row].get("cover") as? LCFile{
            let imgUrl = URL(string: file.url!.stringValue!)!
            Nuke.loadImage(with: imgUrl, options: categoryLoadingOptions, into: cell.imageV)
        }
        
        return cell
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
        loadCollectionItemsVC(collection: collections[indexPath.row])
    }
    
    // MARK: - Empty State Data Source
    
    var emptyStateTitle: NSAttributedString {
            let attrs = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
            let title: String = NoNetwork ? "没有数据，请检查网络！" : "没有数据"
            
            return NSAttributedString(string: title, attributes: attrs)
        }
    
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        emptyView.contentView.layer.borderColor = UIColor.clear.cgColor
        emptyView.contentView.layer.backgroundColor = UIColor.clear.cgColor
    }
}
