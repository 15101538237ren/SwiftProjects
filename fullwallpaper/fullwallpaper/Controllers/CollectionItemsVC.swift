//
//  CollectionItemsVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/21/20.
//

import UIKit
import LeanCloud
import Nuke
import UIEmptyState
import CropViewController
import Refreshable
import SwiftTheme

class CollectionItemsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate{
    
    
    var imagePicker = UIImagePickerController()
    var collection: LCObject!
    var sortType:SortType = .byLike
    var switchedSortType = false
    var NoNetwork: Bool = false
    
    var hotWallpapers:[Wallpaper] = []
    var NoMoreData: [Bool] = [false, false]
    var urlsOfHotWallpapers:[String] = []
    var skipOfHotWallpapers:Int = 0
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    var latestWallpapers:[Wallpaper] = []
    var minDateOfLastLatestWallpaperFetch: String? = nil
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    fileprivate var timeOnThisPage: Int = 0
    
    
    func setupCollectionView() {
        DispatchQueue.main.async {
            self.titleLabel.text = self.collection.get("name")?.stringValue ?? "专题"
        }
        titleLabel.theme_textColor = "BarTitleColor"
        collectionView.theme_backgroundColor = "View.BackgroundColor"
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
    
    func setSegmentedControl(){
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray], for: .normal)
        segmentedControl.theme_backgroundColor = "SegmentedCtrlTintColor"
        segmentedControl.theme_selectedSegmentTintColor = "SegmentedCtrlSelectedTintColor"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tictoc), userInfo: nil, repeats: true)
        enableEdgeSwipeGesture()
        setupCollectionView()
        setSegmentedControl()
        initIndicator(view: self.view)
        loadWallpapers()
    }
    
    func enableEdgeSwipeGesture(){
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .left
        view.addGestureRecognizer(edgePan)
    }
    
    @objc func screenEdgeSwiped(sender: UIScreenEdgePanGestureRecognizer){
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            
            if viewTranslation.x > 0 {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: self.viewTranslation.x, y: 0)
                })
            }
        case .ended:
            if viewTranslation.x < (view.width/3.0) {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                let transition = CATransition()
                transition.duration = 0.7
                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                transition.type = CATransitionType.fade
                transition.subtype = CATransitionSubtype.fromLeft
                self.view.window!.layer.add(transition, forKey: nil)
                self.dismiss(animated: false, completion: nil)
            }
        default:
            break
        }
    }
    
    
    @objc func tictoc(){
        timeOnThisPage += 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let collectionName =  self.collection.get("name")?.stringValue ?? "细节页"
        var info = ["Um_Key_PageName": "专题【\(collectionName)】浏览", "Um_Key_Duration": timeOnThisPage] as [String : Any]
        if let user = LCApplication.default.currentUser{
            let userId = user.objectId!.stringValue!
            info["Um_Key_UserID"] = userId
        }
        UMAnalyticsSwift.event(eventId: "Um_Event_PageView", attributes: info)
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
        collectionView.setLoadMoreEnable(false)
        
        DispatchQueue.main.async { [self] in
            collectionView.stopLoadMore()
            
            if switchedSortType{
                switchedSortType.toggle()
            }
        }
        
        if !Reachability.isConnectedToNetwork(){
            self.NoNetwork = true
            self.reloadEmptyStateForCollectionView(self.collectionView)
            stopIndicator()
            return
        }
        let idx: Int = sortType == .byLike ? 0 : 1
        if !NoMoreData[idx] {
            DispatchQueue.global(qos: .utility).async { [self] in
            do {
                let query = LCQuery(className: "Wallpaper")
                query.whereKey("status", .equalTo(1))
                
                let collectionObj = LCObject(className: "Collection", objectId: collection.objectId!.stringValue!)
                query.whereKey("dependent", .equalTo(collectionObj))
                
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
                            let index: Int = sortType == .byLike ? 0 : 1
                            NoMoreData[index] = true
                            DispatchQueue.main.async {
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
                            let category:String = res.get("category")?.stringValue ?? ""
                            let date:String = fromLCDateToDateStr(date: res.createdAt!)
                            
                            if let file = res.get("img") as? LCFile {
                                let imgUrl = file.url!.stringValue!
                                if sortType == .byCreateDate || !urlsOfHotWallpapers.contains(imgUrl){
                                    let thumbnailUrl = file.thumbnailURL(.scale(thumbnailScale))!.stringValue!
                                    let wallpaper = Wallpaper(objectId: res.objectId!.stringValue!,name: name, category: category, thumbnailUrl: thumbnailUrl, imgUrl: imgUrl, likes: likes, createdAt: date, isPro: pro)
                                    
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
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.NoNetwork = false
                            self.collectionView.setLoadMoreEnable(true)
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
        }else{
            stopIndicator()
            self.NoNetwork = false
            self.reloadEmptyStateForCollectionView(self.collectionView)
        }
        
    }
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                if sortType != .byLike{
                    sortType = .byLike
                    initIndicator(view: self.view)
                    switchedSortType = true
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    loadWallpapers()
                }
            case 1:
                if sortType != .byCreateDate{
                    sortType = .byCreateDate
                    initIndicator(view: self.view)
                    switchedSortType = true
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    loadWallpapers()
                }
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
        cell.proBtn.alpha = wallpaper.isPro ? 1 : 0
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
    
    func showVIPBenefitsVC(showHint: Bool) {
        let MainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vipBenefitsVC = MainStoryBoard.instantiateViewController(withIdentifier: "vipBenefitsVC") as! VIPBenefitsVC
        vipBenefitsVC.showHint = showHint
        vipBenefitsVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(vipBenefitsVC, animated: true, completion: nil)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wallpaper:Wallpaper = sortType == .byLike ? hotWallpapers[indexPath.row] : latestWallpapers[indexPath.row]
        if wallpaper.isPro && !isPro{
            showVIPBenefitsVC(showHint: true)
        }else{
            if let imgUrl = URL(string: wallpaper.imgUrl){
                loadDetailVC(imageUrl: imgUrl, wallpaperObjectId: wallpaper.objectId)
            }
        }
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
    
    func selectImage(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectWallpaper(_ sender: UIButton) {
        if let _ = LCApplication.default.currentUser {
            self.selectImage()
        } else {
            // 显示注册或登录页面
            self.showLoginOrRegisterVC()
        }
    }
    
    func showLoginOrRegisterVC() {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let emailVC = LoginRegStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        emailVC.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            self.present(emailVC, animated: true, completion: {
                emailVC.view.makeToast("请先「登录」或「注册」来上传壁纸", duration: 1.5, position: .center)
            })
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
        uploadVC.collection = collection
        uploadVC.modalPresentationStyle = .overCurrentContext
        if let category:String = collection.get("category")?.stringValue{
            uploadVC.currentCategory = category
            uploadVC.hideSelectCategory = true
        }
        
        DispatchQueue.main.async {
            cropViewController.dismiss(animated: true, completion: nil)
            self.present(uploadVC, animated: true, completion: nil)
        }
    }
    
}
