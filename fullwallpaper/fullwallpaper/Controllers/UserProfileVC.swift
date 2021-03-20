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
import CropViewController
import SwifterSwift

class UserProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    @IBOutlet weak var backBtn:UIButton!
    @IBOutlet weak var logoutBtn:UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var avatar: UIImageView!{
        didSet{
            avatar.layer.cornerRadius = avatar.layer.frame.width/2.0
            avatar.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    
    var settingVC: SettingVC!
    var imagePicker = UIImagePickerController()
    private var selectedImage: UIImage? = nil
    
    var minDateOfLastLatestWallpaperFetches: [Int: String?] = [0:nil, 1:nil]
    
    var wallpapers:[Int : [Wallpaper]] = [0:[], 1:[]]
    var NoMoreData: [Bool] = [false, false]
    var urlsOfLoadedLikedWallpapers:[String] = []
    
    var NoNetWork: Bool = false
    var switched: Bool = true
    
    func setSegmentedControl(){
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray], for: .normal)
        segmentedControl.theme_backgroundColor = "SegmentedCtrlTintColor"
        segmentedControl.theme_selectedSegmentTintColor = "SegmentedCtrlSelectedTintColor"
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
        setSegmentedControl()
        setupCollectionView()
        initIndicator(view: self.view)
        initVC()
        updateAvatarAndName()
        loadWallpapers(selectedIdx: 0)
    }
    
    func initVC(){
        addGestureRecognizers()
    }
    
    private func handleLoadMore() {
        loadWallpapers(selectedIdx: segmentedControl.selectedSegmentIndex)
    }
    
    func completionHandler(){
        DispatchQueue.main.async { [self] in
            collectionView.stopLoadMore()
            collectionView.setLoadMoreEnable(false)
            if (switched){
                switched.toggle()
                collectionView.reloadData()
            }
            self.NoNetWork = false
            self.reloadEmptyStateForCollectionView(self.collectionView)
            stopIndicator()
        }
    }
    
    func loadDetailVC(imageUrl: URL, wallpaperObjectId: String, pro: Bool) -> Void{
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailVC = mainStoryBoard.instantiateViewController(withIdentifier: "detailVC") as! WallpaperDetailVC
        detailVC.isPro = pro
        detailVC.imageUrl = imageUrl
        detailVC.wallpaperObjectId = wallpaperObjectId
        detailVC.modalPresentationStyle = .overCurrentContext
        
        DispatchQueue.main.async {
            self.present(detailVC, animated: true, completion: nil)
        }
    }
    
    func loadWallpapers(selectedIdx: Int)
    {
        collectionView.setLoadMoreEnable(false)
        
        DispatchQueue.main.async { [self] in
            collectionView.stopLoadMore()
        }
        
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
                }
                else{
                    completionHandler()
                }
            }else{
                if switched{
                    switched.toggle()
                }
                
                if !NoMoreData[selectedIdx]{
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
                                        NoMoreData[selectedIdx] = true
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
                                
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                    self.NoNetWork = false
                                    self.collectionView.setLoadMoreEnable(true)
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
                }else{
                    stopIndicator()
                    self.NoNetWork = false
                    self.reloadEmptyStateForCollectionView(self.collectionView)
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
        cell.proBtn.alpha = wallpaper.isPro ? 1 : 0
        cell.likeLabel.text = "\(wallpaper.likes)"
        cell.proBtn.alpha = wallpaper.isPro ? 1 : 0
        let thumbnailUrl = URL(string: wallpaper.thumbnailUrl)!
        Nuke.loadImage(with: thumbnailUrl, options: wallpaperLoadingOptions, into: cell.imageV)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedIndex: Int = segmentedControl.selectedSegmentIndex
        
        let wallpaper:Wallpaper = wallpapers[selectedIndex]![indexPath.row]
        
        if let imgUrl = URL(string: wallpaper.imgUrl){
            loadDetailVC(imageUrl: imgUrl, wallpaperObjectId: wallpaper.objectId, pro: wallpaper.isPro)
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
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        loadWallpapers(selectedIdx: segmentedControl.selectedSegmentIndex)
    }
    
    func setElements(enable: Bool){
        self.view.isUserInteractionEnabled = enable
        self.backBtn.isUserInteractionEnabled = enable
        self.logoutBtn.isUserInteractionEnabled = enable
        self.nameLabel.isUserInteractionEnabled = enable
        self.avatar.isUserInteractionEnabled = enable
        self.segmentedControl.isUserInteractionEnabled = enable
        self.collectionView.isUserInteractionEnabled = enable
    }
    
    func addGestureRecognizers(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage(tapGestureRecognizer:)))
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(tapGestureRecognizer)
        
        let labelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(popNameTextInputAlert(tapGestureRecognizer:)))
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(labelTapGestureRecognizer)
    }
    
    @objc func selectImage(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            DispatchQueue.main.async { [self] in
                picker.dismiss(animated: true, completion: nil)
                
                let targetLength:CGFloat = view.bounds.width * UIScreen.main.scale
                
                let leftPosition = (pickedImage.size.width * pickedImage.scale - targetLength)/2.0
                let topPosition = (pickedImage.size.height * pickedImage.scale - targetLength)/2.0
                let cropController = CropViewController(image: pickedImage)
                cropController.title = "「缩放」或「拖拽」来调整"
                cropController.doneButtonTitle = "确定"
                cropController.cancelButtonTitle = "取消"
                cropController.imageCropFrame = CGRect(x: leftPosition, y: topPosition, width: targetLength, height: targetLength)
                cropController.aspectRatioPreset = .presetSquare
                cropController.rotateButtonsHidden = true
                cropController.rotateClockwiseButtonHidden = true
                cropController.resetButtonHidden = true
                cropController.aspectRatioLockEnabled = true
                cropController.resetAspectRatioEnabled = false
                cropController.aspectRatioPickerButtonHidden = true
                cropController.delegate = self
                self.present(cropController, animated: true, completion: nil)
            }
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        DispatchQueue.main.async { [self] in
            cropViewController.dismiss(animated: true, completion: nil)
            setElements(enable: false)
            initIndicator(view: view)
        }
        setProfile(image: image)
    }
    
    func setProfile(image: UIImage){
        if !Reachability.isConnectedToNetwork(){
            setElements(enable: true)
            stopIndicator()
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            return
        }
        if let resizedImage = image.resizeWithWidth(width: 200){
            self.selectedImage = image
            let imageData: Data = resizedImage.jpegData(compressionQuality: 1.0)!
            if let user = LCApplication.default.currentUser {
                DispatchQueue.global(qos: .background).async {
                    do {
                        // Save new avatar file on LC
                        let file = LCFile(payload: .data(data: imageData))
                        if let _ =  file.get("name")?.stringValue{
                            
                        }else{
                            do{
                                try file.set("name", value: "unnamed")
                            }catch{
                                print("无法设置文件名称")
                            }
                        }
                        _ = file.save { result in
                            switch result {
                            case .success:
                                // 将对象保存到云端
                                do {
                                    try user.set("avatar", value: file)
                                    _ = user.save { result in
                                        stopIndicator()
                                        switch result {
                                        case .success:
                                            DispatchQueue.main.async { [self] in
                                                avatar.image = selectedImage
                                            }
                                        case .failure(error: let error):
                                            self.view.makeToast("设置失败，请稍后重试!\(error.reason?.stringValue ?? "")", duration: 1.2, position: .center)
                                        }
                                        self.setElements(enable: true)
                                    }
                                }catch {
                                    stopIndicator()
                                    self.setElements(enable: true)
                                    self.view.makeToast("设置失败，请稍后重试!", duration: 1.2, position: .center)
                                    stopIndicator()
                                    self.setElements(enable: true)
                                }
                                
                            case .failure(error: let error):
                                DispatchQueue.main.async {
                                    stopIndicator()
                                    self.setElements(enable: true)
                                    self.view.makeToast("设置失败，请稍后重试!\(error.reason?.stringValue ?? "")", duration: 1.2, position: .center)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setDisplayName(name: String){
        if !Reachability.isConnectedToNetwork(){
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            return
        }
        initIndicator(view: self.view)
        setElements(enable: false)
        if let user = LCApplication.default.currentUser {
            do {
                try user.set("name", value: name)
                _ = user.save { result in
                    stopIndicator()
                    switch result {
                    case .success:
                        DispatchQueue.main.async { [self] in
                            nameLabel.text = name
                        }
                    case .failure(error: let error):
                        self.view.makeToast("设置失败，请稍后重试!\(error.reason?.stringValue ?? "")", duration: 1.2, position: .center)
                    }
                    self.setElements(enable: true)
                }
            }catch {
                stopIndicator()
                self.setElements(enable: true)
                self.view.makeToast("设置失败，请稍后重试!", duration: 1.0, position: .center)
            }
        }
    }
    
    @objc func popNameTextInputAlert(tapGestureRecognizer: UITapGestureRecognizer){
        let alertController = UIAlertController(title: "设置显示名称", message: "", preferredStyle: .alert)
        
        alertController.addTextField(text: "", placeholder: "输入显示名称", editingChangedTarget: nil, editingChangedSelector: nil)
        
        let setAction = UIAlertAction(title: "确定", style: .default){ _ in
            let name: String = alertController.textFields!.first!.text ?? ""
            if !name.isEmpty{
                self.setDisplayName(name: name)
                alertController.dismiss(animated: true, completion: nil)
            }else{
                self.view.makeToast("请输入显示名称", duration: 1.2, position: .center)
            }
            
         }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel){ _ in
            alertController.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(setAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
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
    
    
    @IBAction func logout(_ sender: UIButton) {
        LCUser.logOut()
        userLikedWPs = []
        self.dismiss(animated: true, completion: {
            self.settingVC.setDisplayNameAndUpdate(name: "")
            self.settingVC.view.makeToast("登出成功!", duration: 1.0, position: .center)
        })
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if let name = self.nameLabel.text{
                self.settingVC.setDisplayNameAndUpdate(name: name)
            }
        })
    }
}
