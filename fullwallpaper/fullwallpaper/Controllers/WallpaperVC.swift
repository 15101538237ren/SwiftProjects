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

class WallpaperVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    //Variables
    var imagePicker = UIImagePickerController()
    
    var wallpapers:[Wallpaper] = []
    var NoNetWork:Bool = false
    var sortType:SortType = .byLike
    
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
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = LCApplication.default.currentUser {
            LCUser.logOut()
        }
        setupCollectionView()
        initIndicator(view: self.view)
        loadWallpapers()
    }

    func loadDetailVC(imageUrl: URL) -> Void{
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailVC = mainStoryBoard.instantiateViewController(withIdentifier: "detailVC") as! WallpaperDetailVC
        
        detailVC.imageUrl = imageUrl
        detailVC.modalPresentationStyle = .overCurrentContext
        
        DispatchQueue.main.async {
            self.present(detailVC, animated: true, completion: nil)
        }
    }
    
    func loadWallpapers()
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
            let updated_count = query.count()
            print("Fetched \(updated_count.intValue) wallpapers")
            if wallpapers.count != updated_count.intValue{
                _ = query.find() { result in
                    switch result {
                    case .success(objects: let results):
                        wallpapers = []
                        for rid in 0..<results.count{
                            let res = results[rid]
                            let name = res.get("name")?.stringValue ?? ""
                            let category = res.get("category")?.stringValue ?? ""
                            
                            if let file = res.get("img") as? LCFile {
                                let imgUrl = file.url!.stringValue!
                                let wallpaper = Wallpaper(name: name, category: category, imgUrl: imgUrl)
                                
                                wallpapers.append(wallpaper)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.NoNetWork = false
                            self.reloadEmptyStateForCollectionView(self.collectionView)
                            stopIndicator()
                        }
                        
                        break
                    case .failure(error: let error):
                        print(error.localizedDescription)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.NoNetWork = false
                    self.reloadEmptyStateForCollectionView(self.collectionView)
                    stopIndicator()
                }
            }
        }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallpaperCollectionViewCell", for: indexPath) as! WallpaperCollectionViewCell
        let imgUrl = URL(string: wallpapers[indexPath.row].imgUrl)!
        Nuke.loadImage(with: imgUrl, options: wallpaperLoadingOptions, into: cell.imageV)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.size.width - (numberOfItemsPerRow - 1) * cellSpacing) / numberOfItemsPerRow
        let height = width * cellHeightWidthRatio
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let imgUrl = URL(string: wallpapers[indexPath.row].imgUrl){
            loadDetailVC(imageUrl: imgUrl)
        }
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
    
    func loadUploadVC() -> Void{
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let uploadVC = mainStoryBoard.instantiateViewController(withIdentifier: "uploadVC") as! UploadWallpaperVC
        
        uploadVC.modalPresentationStyle = .overCurrentContext
        
        DispatchQueue.main.async {
            self.present(uploadVC, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            DispatchQueue.main.async {
                picker.dismiss(animated: true, completion: nil)
                self.presentCropViewController(image: pickedImage)
            }
        }
    }
    
    func presentCropViewController(image: UIImage) {
        let cropController = CropViewController(image: image)
        cropController.title = "「缩放」或「拖拽」来调整"
        cropController.doneButtonTitle = "确定"
        cropController.cancelButtonTitle = "取消"
        cropController.delegate = self
        cropController.imageCropFrame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        cropController.rotateButtonsHidden = true
        cropController.rotateClockwiseButtonHidden = true
        cropController.resetButtonHidden = true
        cropController.aspectRatioLockEnabled = true
        cropController.resetAspectRatioEnabled = false
        cropController.aspectRatioPickerButtonHidden = true
        present(cropController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let uploadVC = mainStoryBoard.instantiateViewController(withIdentifier: "uploadVC") as! UploadWallpaperVC
        uploadVC.wallpaper = image
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
            }
        }else if index == 1{
            if sortType != .byCreateDate{
                sortType = .byCreateDate
            }
        }
        else{
            self.dismiss(animated: false, completion: {
                self.selectImage()
            })
        }
    }
}
