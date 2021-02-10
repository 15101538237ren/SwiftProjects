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
import SwiftTheme
import SwiftMessages
import SwiftyStoreKit

class WallpaperVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    //Variables
    var imagePicker = UIImagePickerController()
    fileprivate var timeOnThisPage: Int = 0
    var hotWallpapers:[Wallpaper] = []
    var latestWallpapers:[Wallpaper] = []
    var NoNetWork:Bool = false
    var NoMoreData: [Bool] = [false, false]
    var sortType:SortType = .byLike {
        didSet{
            switch sortType {
            case .byLike:
                DispatchQueue.main.async {
                    self.titleLabel.text = "Popular"
                }
            case .byCreateDate:
                DispatchQueue.main.async {
                    self.titleLabel.text = "Latest"
                }
            }
        }
    }
    var switchedSortType = false
    var urlsOfHotWallpapers:[String] = []
    var skipOfHotWallpapers:Int = 0
    var minDateOfLastLatestWallpaperFetch: String? = nil
    private var isAdmin: Bool = false
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var sortBtn: UIButton!
    
    
    func popPrivacyMessage(){
        if !isKeyPresentInUserDefaults(key: privacyViewedKey){
            let messageView: TermsView = try! SwiftMessages.viewFromNib()
            messageView.configureDropShadow()
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            messageView.agreeAction = {
                UserDefaults.standard.set(true, forKey: privacyViewedKey)
                SwiftMessages.hide()
            }
            messageView.cancelAction = { UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)}
            var config = SwiftMessages.defaultConfig
            config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
            config.duration = .forever
            config.presentationStyle = .center
            config.dimMode = .blur(style: .light, alpha: 0.6, interactive: false)
            SwiftMessages.show(config: config, view: messageView)
            
        }
    }
    
    func setupCollectionView() {
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
    
    func checkUserStatus(){
        if let user = LCApplication.default.currentUser {
            _ = user.fetch(keys: ["proDue", "disabled"]) { result in
                switch result {
                case .success:
                    if let disabledLCObj = user.get("disabled"){
                        if let disabled = disabledLCObj.boolValue {
                            isDisabled = disabled
                            if isDisabled {
                                DispatchQueue.main.async {
                                    let alertController:UIAlertController = getBannedAlert()
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                return
                            }
                        }
                    }
                    
                    if let proDUE = user.get("proDue"){
                        if let proDUEdate = proDUE.dateValue{
                            if proDUEdate > Date(){
                                isPro = true
                            }
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
        
        let productIDs = getProductIDs()
        
        SwiftyStoreKit.retrieveProductsInfo(Set(productIDs)) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }
        let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tictoc), userInfo: nil, repeats: true)
        popPrivacyMessage()
        titleLabel.theme_textColor = "BarTitleColor"
        setupCollectionView()
        initIndicator(view: self.view)
        verifyAdmin()
        loadWallpapers()
        getUserLikedWPs()
    }
    
    @objc func tictoc(){
        timeOnThisPage += 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkUserStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var info = ["Um_Key_PageName": "主页浏览", "Um_Key_Duration": timeOnThisPage] as [String : Any]
        if let user = LCApplication.default.currentUser{
            let userId = user.objectId!.stringValue!
            info["Um_Key_UserID"] = userId
        }
        UMAnalyticsSwift.event(eventId: "Um_Event_PageView", attributes: info)
    }
    
    func verifyAdmin(){
        if let user = LCApplication.default.currentUser {
            let roleQuery = LCQuery(className: LCRole.objectClassName())
            roleQuery.whereKey("users", .equalTo(user))
            _ = roleQuery.find { result in
                switch result {
                case .success(objects: let roles):
                    for role in roles{
                        if let roleName = role.get("name"){
                            if roleName.stringValue! == "admin"{
                                self.isAdmin = true
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
    
    private func loadAuditVC() {
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let auditVC = mainStoryBoard.instantiateViewController(withIdentifier: "auditVC") as! AuditVC
        auditVC.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            self.present(auditVC, animated: true, completion: nil)
        }
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
    
    func loadSearchVC() -> Void{
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let searchVC = mainStoryBoard.instantiateViewController(withIdentifier: "searchVC") as! SearchVC
        
        searchVC.modalPresentationStyle = .overCurrentContext
        
        DispatchQueue.main.async {
            self.present(searchVC, animated: true, completion: nil)
        }
    }
    
    @objc func loadWallpapers()
    {
        collectionView.setLoadMoreEnable(false)
        
        DispatchQueue.main.async { [self] in
            collectionView.stopLoadMore()
            
            if switchedSortType{
                switchedSortType.toggle()
            }
        }
        
        if !Reachability.isConnectedToNetwork(){
            stopIndicator()
            NoNetWork = true
            self.reloadEmptyStateForCollectionView(self.collectionView)
            return
        }
        
        let idx: Int = sortType == .byLike ? 0 : 1
        if !NoMoreData[idx] {
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
                                let category = res.get("category")?.stringValue ?? ""
                                let likes = res.get("likes")?.intValue ?? 0
                                let pro = res.get("pro")?.boolValue ?? false
                                let date:String = fromLCDateToDateStr(date: res.createdAt!)
                                if let file = res.get("img") as? LCFile {
                                    let imgUrl = file.url!.stringValue!
                                    if sortType == .byCreateDate || !urlsOfHotWallpapers.contains(imgUrl){
                                        let thumbnailUrl = file.thumbnailURL(.scale(thumbnailScale))!.stringValue!
                                        let wallpaper = Wallpaper(objectId: res.objectId!.stringValue!, name: name, category: category, thumbnailUrl: thumbnailUrl, imgUrl: imgUrl, likes: likes, createdAt: date, isPro: pro)
                                        
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
                            
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                                self.NoNetWork = false
                                
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
            NoNetWork = false
            self.reloadEmptyStateForCollectionView(self.collectionView)
        }
        
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
    
    @IBAction func presentSortMenu(_ sender: UIButton){
            let iconWidthHeight:CGFloat = 20
            let popAction = PopMenuDefaultAction(title: "最热壁纸", image: UIImage(named: "heart-fill-icon"), color: UIColor.lightGray)
            let latestAction = PopMenuDefaultAction(title: "最新壁纸", image: UIImage(named: "calendar-icon"), color: UIColor.lightGray)
        
            popAction.iconWidthHeight = iconWidthHeight
            latestAction.iconWidthHeight = iconWidthHeight
            
            let popActions: [PopMenuAction] = [popAction, latestAction]
        
            let menuVC = PopMenuViewController(sourceView:sender, actions: popActions)
            menuVC.delegate = self
            menuVC.view.tag = 2
            menuVC.appearance.popMenuFont = .systemFont(ofSize: 15, weight: .regular)
            
            menuVC.appearance.popMenuColor.backgroundColor = .solid(fill: .white)
            self.present(menuVC, animated: true, completion: nil)
    }
    
    @IBAction func presentPopMenu(_ sender: UIButton) {
            let iconWidthHeight:CGFloat = 20
            let searchAction = PopMenuDefaultAction(title: "搜索壁纸", image: UIImage(named: "search"), color: UIColor.lightGray)
            let uploadAction = PopMenuDefaultAction(title: "上传壁纸", image: UIImage(named: "upload"), color: UIColor.lightGray)
        
            searchAction.iconWidthHeight = iconWidthHeight
            uploadAction.iconWidthHeight = iconWidthHeight
            
            var popActions: [PopMenuAction] = [searchAction, uploadAction]
            
            if isAdmin{
                let auditAction = PopMenuDefaultAction(title: "壁纸审核", image: UIImage(named: "audit"), color: UIColor.lightGray)
                
                auditAction.iconWidthHeight = iconWidthHeight
                popActions.append(auditAction)
            }
        
            let menuVC = PopMenuViewController(sourceView:sender, actions: popActions)
            menuVC.delegate = self
            menuVC.view.tag = 1
            menuVC.appearance.popMenuFont = .systemFont(ofSize: 15, weight: .regular)
            
            menuVC.appearance.popMenuColor.backgroundColor = .solid(fill: .white)
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
        if popMenuViewController.view.tag == 1{
            if index == 0{
                if isPro {
                    loadSearchVC()
                }else{
                    showVIPBenefitsVC(showHint: false)
                }
            }
            else if index == 1{
                self.dismiss(animated: false, completion: {
                    if let _ = LCApplication.default.currentUser {
                        self.selectImage()
                    } else {
                        // 显示注册或登录页面
                        self.showLoginOrRegisterVC()
                    }
                })
            }else if index == 2{
                if isAdmin{
                    loadAuditVC()
                }
            }
        }else{
            if index == 0{
                if sortType != .byLike{
                    sortType = .byLike
                    initIndicator(view: self.view)
                    switchedSortType = true
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    loadWallpapers()
                }
            }else if index == 1{
                if sortType != .byCreateDate{
                    sortType = .byCreateDate
                    initIndicator(view: self.view)
                    switchedSortType = true
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    loadWallpapers()
                }
            }
        }
        
    }
}
