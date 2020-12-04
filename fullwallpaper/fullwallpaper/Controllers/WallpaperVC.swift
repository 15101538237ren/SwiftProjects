//
//  ViewController.swift
//  fullwallpaper
//
//  Created by Honglei on 10/28/20.
//

import UIKit
import LeanCloud
import Nuke
import UIEmptyState
import PopMenu
import CropViewController
import Refreshable

class WallpaperVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    //Variables
    var imagePicker = UIImagePickerController()
    
    var hotWallpapers:[Wallpaper] = []
    var latestWallpapers:[Wallpaper] = []
    var NoNetWork:Bool = false
    var sortType:SortType = .byLike
    var switchedSortType = false
    var urlsOfHotWallpapers:[String] = []
    var skipOfHotWallpapers:Int = 0
    var minDateOfLastLatestWallpaperFetch: String? = nil
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        initIndicator(view: self.view)
        loadWallpapers()
        getUserLikedWPs()
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
    
    @IBAction func loadSearchVC(sender: UIButton) -> Void{
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let searchVC = mainStoryBoard.instantiateViewController(withIdentifier: "searchVC") as! SearchVC
        
        searchVC.modalPresentationStyle = .overCurrentContext
        
        DispatchQueue.main.async {
            self.present(searchVC, animated: true, completion: nil)
        }
    }
    
    @objc func loadWallpapers()
    {
        if !Reachability.isConnectedToNetwork(){
            stopIndicator()
            NoNetWork = true
            self.reloadEmptyStateForCollectionView(self.collectionView)
            return
        }
        
        DispatchQueue.global(qos: .utility).async { [self] in
        do {
            let query = LCQuery(className: "Wallpaper")
            query.whereKey("status", .equalTo(1))
            
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
                        let category = res.get("category")?.stringValue ?? ""
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
                        skipOfHotWallpapers += results.count
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
                        self.reloadEmptyStateForCollectionView(self.collectionView)
                        stopIndicator()
                        if !first{
                            self.collectionView.stopLoadMore()
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
    
    private func handleLoadMore() {
        loadWallpapers()
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
    
    @IBAction func presentPopMenu(_ sender: UIButton) {
            let iconWidthHeight:CGFloat = 20
            let popAction = PopMenuDefaultAction(title: "最热壁纸", image: UIImage(named: "heart-fill-icon"), color: UIColor.darkGray)
            let latestAction = PopMenuDefaultAction(title: "最新壁纸", image: UIImage(named: "calendar-icon"), color: UIColor.darkGray)
            let uploadAction = PopMenuDefaultAction(title: "上传壁纸", image: UIImage(named: "upload"), color: UIColor.darkGray)
            
            popAction.iconWidthHeight = iconWidthHeight
            latestAction.iconWidthHeight = iconWidthHeight
            uploadAction.iconWidthHeight = iconWidthHeight
            
            let menuVC = PopMenuViewController(sourceView:sender, actions: [popAction, latestAction, uploadAction])
            menuVC.delegate = self
            menuVC.appearance.popMenuFont = .systemFont(ofSize: 15, weight: .regular)
            
            menuVC.appearance.popMenuColor.backgroundColor = .solid(fill: UIColor(red: 128, green: 128, blue: 128, alpha: 1))
            self.present(menuVC, animated: true, completion: nil)
        }
    
    func showLoginOrRegisterVC() {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let emailVC = LoginRegStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        emailVC.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            self.present(emailVC, animated: true, completion: nil)
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
        uploadVC.hideSelectCategory = false
        uploadVC.modalPresentationStyle = .overCurrentContext
        
        DispatchQueue.main.async {
            cropViewController.dismiss(animated: true, completion: nil)
            self.present(uploadVC, animated: true, completion: nil)
        }
    }
    
    func selectImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
}

extension WallpaperVC: PopMenuViewControllerDelegate {

    // This will be called when a pop menu action was selected
    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        if index == 0{
            if sortType != .byLike{
                sortType = .byLike
                initIndicator(view: self.view)
                switchedSortType = true
                loadWallpapers()
            }
        }else if index == 1{
            if sortType != .byCreateDate{
                sortType = .byCreateDate
                initIndicator(view: self.view)
                switchedSortType = true
                loadWallpapers()
            }
        }
        else{
            self.dismiss(animated: false, completion: {
                if let _ = LCApplication.default.currentUser {
                    self.selectImage()
                } else {
                    // 显示注册或登录页面
                    self.showLoginOrRegisterVC()
                }
            })
        }
    }
}
