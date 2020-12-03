//
//  CategoryCollectionVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/7/20.
//

import UIKit
import LeanCloud
import Nuke
import UIEmptyState
import CropViewController
import Refreshable

class CategoryCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate{
    
    //Constants
    let loadCollectionLimit:Int = 1000
    
    //Variables
    
    var minVolOfLastCollectionFetch: Int? = nil
    var collections:[LCObject] = []
    
    var imagePicker = UIImagePickerController()
    var hotWallpapers:[Wallpaper] = []
    var latestWallpapers:[Wallpaper] = []
    var showingCollectionView: Bool = false
    var sortType:SortType = .byLike
    var switchedSortType = false
    var urlsOfHotWallpapers:[String] = []
    var skipOfHotWallpapers:Int = 0
    var minDateOfLastLatestWallpaperFetch: String? = nil

    
    
    var category: String!
    var categoryCN: String!
    var NoNetWork: Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    func setupTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .clear
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.addLoadMore(action: { [weak self] in
            self?.handleLoadMoreCollections()
        })
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        showCollectionView()
        initIndicator(view: self.view)
        loadWallpapers()
    }
    
    private func handleLoadMoreCollections() {
        loadCollections()
    }
    
    func loadCollections(){
        if !Reachability.isConnectedToNetwork(){
            self.tableView.reloadData()
            NoNetWork = true
            self.reloadEmptyStateForTableView(self.tableView)
            stopIndicator()
            return
        }
        
        DispatchQueue.global(qos: .utility).async { [self] in
        do {
            let query = LCQuery(className: "Collection")
            query.whereKey("category", .equalTo(category))
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
                            tableView.reloadData()
                            NoNetWork = false
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
                        NoNetWork = false
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
    
    
    func emptyStateViewShouldShow(for tableView: UITableView) -> Bool {
        return collections.count == 0 ? true : false
    }
    
    func emptyStateViewShouldShow(for collectionView: UICollectionView) -> Bool {
        return (sortType == .byLike ? hotWallpapers.count : latestWallpapers.count) == 0 ? true : false
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
    
    func loadWallpapers()
    {
        DispatchQueue.main.async {
            self.titleLabel.text = self.category.capitalized
        }
        if !Reachability.isConnectedToNetwork(){
            self.NoNetWork = true
            self.reloadEmptyStateForCollectionView(self.collectionView)
            stopIndicator()
            return
        }
        
        DispatchQueue.global(qos: .utility).async { [self] in
        do {
            let query = LCQuery(className: "Wallpaper")
            query.whereKey("category", .equalTo(category))
            
            if sortType == .byLike{
                query.whereKey("likes", .descending)
                query.skip = skipOfHotWallpapers
            }else{
                query.whereKey("createdAt", .descending)
                
                if (minDateOfLastLatestWallpaperFetch != nil){
                    query.whereKey("createdAt", .lessThan(dateFromString(dateStr: minDateOfLastLatestWallpaperFetch!)))
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
                            if (switchedSortType){
                                collectionView.reloadData()
                                switchedSortType = false
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
                        
                        let date:String = fromLCDateToDateStr(date: res.createdAt!)
                        
                        if let file = res.get("img") as? LCFile {
                            let imgUrl = file.url!.stringValue!
                            if sortType == .byCreateDate || !urlsOfHotWallpapers.contains(imgUrl){
                                let thumbnailUrl = file.thumbnailURL(.scale(thumbnailScale))!.stringValue!
                                let wallpaper = Wallpaper(objectId: res.objectId!.stringValue!, name: name, category: category, thumbnailUrl: thumbnailUrl, imgUrl: imgUrl, likes: likes, createdAt: date)
                                
                                if sortType == .byLike{
                                    hotWallpapers.append(wallpaper)
                                    urlsOfHotWallpapers.append(wallpaper.imgUrl)
                                }else{
                                    latestWallpapers.append(wallpaper)
                                }
                            }
                        }
                    }
                    
                    if sortType == .byCreateDate{
                        minDateOfLastLatestWallpaperFetch = latestWallpapers[latestWallpapers.count - 1].createdAt
                    }else{
                        skipOfHotWallpapers += wallpaperLimitEachFetch
                    }
                    
                    let first = sortType == .byLike ? hotWallpapers.count == wallpaperLimitEachFetch : latestWallpapers.count == wallpaperLimitEachFetch
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.NoNetWork = false
                        if (switchedSortType){
                            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                        at: .top,
                                                        animated: true)
                            switchedSortType = false
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
                    print(error.localizedDescription)
                }
            }
        }
        }
    }
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                if sortType != .byLike ||  showingCollectionView{
                    sortType = .byLike
                    initIndicator(view: self.view)
                    switchedSortType = true
                    showingCollectionView = false
                    loadWallpapers()
                    showCollectionView()
                }
            case 1:
                if sortType != .byCreateDate || showingCollectionView{
                    sortType = .byCreateDate
                    initIndicator(view: self.view)
                    switchedSortType = true
                    showingCollectionView = false
                    loadWallpapers()
                    showCollectionView()
                }
            case 2:
                showingCollectionView = true
                initIndicator(view: self.view)
                loadCollections()
                showTableView()
            default:
                break
        }
    }
    
    private func handleLoadMore() {
        loadWallpapers()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let wallpaperCount = sortType == .byLike ? hotWallpapers.count : latestWallpapers.count
        return wallpaperCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallpaperCollectionViewCell", for: indexPath) as! WallpaperCollectionViewCell
        let wallpaper:Wallpaper = sortType == .byLike ? hotWallpapers[indexPath.row] : latestWallpapers[indexPath.row]
        let liked  = userLikedWPs.contains(wallpaper.objectId)
        cell.heartV.image = liked ? UIImage(systemName: "heart.fill") ?? UIImage(named: "heart-fill-icon") : UIImage(systemName: "heart") ?? UIImage(named: "heart-icon")
        cell.likeLabel.text = "\(wallpaper.likes)"
        let thumbnailUrl = URL(string: sortType == .byLike ? wallpaper.thumbnailUrl : wallpaper.thumbnailUrl)!
        Nuke.loadImage(with: thumbnailUrl, options: wallpaperLoadingOptions, into: cell.imageV)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.size.width - (numberOfItemsPerRow - 1) * cellSpacing) / numberOfItemsPerRow
        let height = width * cellHeightWidthRatio
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wallpaper:Wallpaper = sortType == .byLike ? hotWallpapers[indexPath.row] : latestWallpapers[indexPath.row]
        if let imgUrl = URL(string: wallpaper.imgUrl){
            loadDetailVC(imageUrl: imgUrl, wallpaperObjectId: wallpaper.objectId)
        }
    }
    
    func showTableView(){
        DispatchQueue.main.async {
            self.collectionView.alpha = 0
            self.collectionView.isUserInteractionEnabled = false
            self.tableView.alpha = 1
            self.tableView.isUserInteractionEnabled = true
        }
    }
    func showCollectionView(){
        DispatchQueue.main.async {
            self.tableView.alpha = 0
            self.tableView.isUserInteractionEnabled = false
            self.collectionView.alpha = 1
            self.collectionView.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func selectWallpaper(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            DispatchQueue.main.async {
                picker.dismiss(animated: true, completion: nil)
                let  cropController = createCropViewController(image: pickedImage)
                cropController.delegate = self
                self.present(cropController, animated: true, completion: nil)
            }
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let uploadVC = mainStoryBoard.instantiateViewController(withIdentifier: "uploadVC") as! UploadWallpaperVC
        uploadVC.wallpaper = image
        uploadVC.modalPresentationStyle = .overCurrentContext
        uploadVC.hideSelectCategory = true
        uploadVC.currentCategory = category
        uploadVC.categoryCN = categoryCN
        
        DispatchQueue.main.async {
            cropViewController.dismiss(animated: true, completion: nil)
            self.present(uploadVC, animated: true, completion: nil)
        }
    }
    
}
