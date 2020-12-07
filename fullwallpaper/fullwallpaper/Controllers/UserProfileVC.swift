//
//  UserProfileVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/6/20.
//

import UIKit
import LeanCloud
import Nuke
import UIEmptyState
import Refreshable

class UserProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var avatar: UIImageView!{
        didSet{
            avatar.layer.cornerRadius = avatar.layer.frame.width/2.0
            avatar.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    
    var NoNetWork: Bool = false
    var switched: Bool = true
    
    var minDateOfLastLatestWallpaperFetches: [Int: String?] = [0:nil, 1:nil]
    
    var wallpapers:[Int : [Wallpaper]] = [0:[], 1:[]]
    var urlsOfLoadedLikedWallpapers:[String] = []
    
    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0)
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        emptyStateDataSource = self
        emptyStateDelegate = self
        
        collectionView.addLoadMore(action: { [weak self] in
            self?.handleLoadMore()
        })
    }
    
    func updateAvatarAndName(){
        if let user = LCApplication.default.currentUser {
            _ = user.fetch(keys: ["avatar", "name"]) { result in
                switch result {
                case .success:
                    let name:String = user.get("name")?.stringValue ?? ""
                    DispatchQueue.main.async {
                        self.nameLabel.text = name
                    }
                    if let file = user.get("avatar") as? LCFile {
                        let imgUrl = file.url!.stringValue!
                        DispatchQueue.main.async {
                            Nuke.loadImage(with: URL(string: imgUrl)!, into: self.avatar)
                        }
                    }
                    
                case .failure(error: let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        initIndicator(view: self.view)
        updateAvatarAndName()
        loadWallpapers(selectedIdx: 0)
    }
    
    private func handleLoadMore() {
        loadWallpapers(selectedIdx: segmentedControl.selectedSegmentIndex)
    }
    
    func completionHandler(){
        DispatchQueue.main.async { [self] in
            collectionView.stopLoadMore()
            collectionView.setLoadMoreEnable(false)
            if (switched){
                collectionView.reloadData()
                switched = false
            }
            self.NoNetWork = false
            self.reloadEmptyStateForCollectionView(self.collectionView)
            stopIndicator()
        }
    }
    
    func loadDetailVC(imageUrl: URL, wallpaperObjectId: String) -> Void{
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailVC = mainStoryBoard.instantiateViewController(withIdentifier: "detailVC") as! WallpaperDetailVC
        
        detailVC.imageUrl = imageUrl
        detailVC.wallpaperObjectId = wallpaperObjectId
        detailVC.modalPresentationStyle = .overCurrentContext
        
        DispatchQueue.main.async {
            self.present(detailVC, animated: true, completion: nil)
        }
    }
    
    func loadWallpapers(selectedIdx: Int)
    {
        if !Reachability.isConnectedToNetwork(){
            self.NoNetWork = true
            completionHandler()
            return
        }
        
        if let currentUser = LCApplication.default.currentUser{
            if selectedIdx == 0{
                if (userLikedWPs.count > 0) && (wallpapers[selectedIdx]!.count < userLikedWPs.count){
                    var wallpaperObjs:[LCObject] = []
                    
                    for wallpaperObjectId in userLikedWPs{
                        let wallpaperObj = LCObject(className: "Wallpaper", objectId: wallpaperObjectId)
                        wallpaperObjs.append(wallpaperObj)
                    }
                    
                    _ = LCObject.fetch(wallpaperObjs, completion: { [self] (result) in
                        switch result {
                        case .success:
                            print("Fetched \(wallpaperObjs.count) wallpapers")
                            for rid in 0..<wallpaperObjs.count{
                                let res = wallpaperObjs[rid]
                                let name = res.get("name")?.stringValue ?? ""
                                let likes = res.get("likes")?.intValue ?? 0
                                let pro = res.get("pro")?.boolValue ?? false
                                let category = res.get("category")?.stringValue ?? ""
                                let date:String = fromLCDateToDateStr(date: res.createdAt!)
                                
                                if let file = res.get("img") as? LCFile {
                                    let imgUrl = file.url!.stringValue!
                                    if !urlsOfLoadedLikedWallpapers.contains(imgUrl){
                                        let thumbnailUrl = file.thumbnailURL(.scale(thumbnailScale))!.stringValue!
                                        let wallpaper = Wallpaper(objectId: res.objectId!.stringValue!, name: name, category: category, thumbnailUrl: thumbnailUrl, imgUrl: imgUrl, likes: likes, createdAt: date, isPro: pro)
                                        urlsOfLoadedLikedWallpapers.append(imgUrl)
                                        wallpapers[selectedIdx]!.append(wallpaper)
                                    }
                                }
                            }
                            
                            completionHandler()
                        case .failure(error: let error):
                            completionHandler()
                            self.view.makeToast(error.reason, duration: 1.0, position: .center)
                        }
                    })
                }else{
                    completionHandler()
                }
            }else{
                DispatchQueue.global(qos: .utility).async { [self] in
                do {
                    let query = LCQuery(className: "Wallpaper")
                    query.whereKey("uploader", .equalTo(currentUser))
                    query.whereKey("createdAt", .descending)
                    
                    if let minDate = minDateOfLastLatestWallpaperFetches[selectedIdx]{
                        if minDate != nil{
                            query.whereKey("createdAt", .lessThan(dateFromString(dateStr: minDate!)))
                        }
                    }
                    
                    query.limit = wallpaperLimitEachFetch
                    
                    _ = query.find { result in
                        switch result {
                        case .success(objects: let results):
                            if results.count == 0{
                                DispatchQueue.main.async {
                                    collectionView.stopLoadMore()
                                    collectionView.setLoadMoreEnable(false)
                                    if (switched){
                                        collectionView.reloadData()
                                        switched = false
                                    }
                                    self.reloadEmptyStateForCollectionView(self.collectionView)
                                    stopIndicator()
                                }
                                return
                            }
                            print("Fetched \(results.count) wallpapers")
                            for rid in 0..<results.count{
                                let res = results[rid]
                                let name = res.get("name")?.stringValue ?? ""
                                let likes = res.get("likes")?.intValue ?? 0
                                let pro = res.get("pro")?.boolValue ?? false
                                let category = res.get("category")?.stringValue ?? ""
                                let date:String = fromLCDateToDateStr(date: res.createdAt!)
                                
                                if let file = res.get("img") as? LCFile {
                                    let imgUrl = file.url!.stringValue!
                                    let thumbnailUrl = file.thumbnailURL(.scale(thumbnailScale))!.stringValue!
                                    let wallpaper = Wallpaper(objectId: res.objectId!.stringValue!, name: name, category: category, thumbnailUrl: thumbnailUrl, imgUrl: imgUrl, likes: likes, createdAt: date, isPro: pro)
                                    wallpapers[selectedIdx]!.append(wallpaper)
                                }
                            }
                            
                            minDateOfLastLatestWallpaperFetches[selectedIdx] = wallpapers[selectedIdx]![wallpapers[selectedIdx]!.count - 1].createdAt
                            
                            let first = wallpapers[selectedIdx]!.count == wallpaperLimitEachFetch
                            
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                                self.NoNetWork = false
                                if (switched){
                                    collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                                at: .top,
                                                                animated: true)
                                    switched = false
                                    collectionView.setLoadMoreEnable(true)
                                }
                                if !first{
                                    self.collectionView.stopLoadMore()
                                }
                                self.reloadEmptyStateForCollectionView(self.collectionView)
                                stopIndicator()
                            }
                            
                            break
                        case .failure(error: let error):
                            completionHandler()
                            self.view.makeToast(error.reason, duration: 1.0, position: .center)
                        }
                    }
                }
                }
            }
            
        }else{
            completionHandler()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers[segmentedControl.selectedSegmentIndex]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallpaperCollectionViewCell", for: indexPath) as! WallpaperCollectionViewCell
        let wallpaper:Wallpaper = wallpapers[segmentedControl.selectedSegmentIndex]![indexPath.row]
        let liked  = userLikedWPs.contains(wallpaper.objectId)
        cell.proBtn.alpha = wallpaper.isPro ? 1 : 0
        cell.heartV.image = liked ? UIImage(systemName: "heart.fill") ?? UIImage(named: "heart-fill-icon") : UIImage(systemName: "heart") ?? UIImage(named: "heart-icon")
        cell.likeLabel.text = "\(wallpaper.likes)"
        cell.proBtn.alpha = wallpaper.isPro ? 1 : 0
        let thumbnailUrl = URL(string: wallpaper.thumbnailUrl)!
        Nuke.loadImage(with: thumbnailUrl, options: wallpaperLoadingOptions, into: cell.imageV)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wallpaper:Wallpaper = wallpapers[segmentedControl.selectedSegmentIndex]![indexPath.row]
        if let imgUrl = URL(string: wallpaper.imgUrl){
            loadDetailVC(imageUrl: imgUrl, wallpaperObjectId: wallpaper.objectId)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.size.width - (numberOfItemsPerRow - 1) * cellSpacing) / numberOfItemsPerRow
        let height = width * cellHeightWidthRatio
        return CGSize(width: width, height: height)
    }
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        initIndicator(view: self.view)
        switched = true
        loadWallpapers(selectedIdx: segmentedControl.selectedSegmentIndex)
    }
    
    // MARK: - Empty State Data Source
    
    var emptyStateTitle: NSAttributedString {
            let attrs = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
            let title: String = NoNetWork ? "没有数据，请检查网络！" : "没有数据"
            return NSAttributedString(string: title, attributes: attrs)
        }
    
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        emptyView.contentView.layer.borderColor = UIColor.clear.cgColor
        emptyView.contentView.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
