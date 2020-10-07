//
//  ViewController.swift
//  Blackpink
//
//  Created by Honglei Ren on 10/2/20.
//

import UIKit
import CloudKit
import UILoadControl
import PopMenu
import Localize_Swift

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    // Outlet Variables
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var soloBtns: [UIButton]!{
        didSet{
            for soloBtn in soloBtns{
                soloBtn.layer.cornerRadius = soloBtn.layer.frame.width/2.0
                soloBtn.layer.masksToBounds = true
            }
        }
    }
    
    
    @IBAction func loadSoloVC(_ sender: UIButton) {
        let category: WallpaperCategory = getCategoryByIntValue(category: sender.tag)
        if category != .Group{
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let soloVC = mainStoryBoard.instantiateViewController(withIdentifier: "soloVC") as! SoloViewController
            
            soloVC.currentWallpaperCategory = category
            soloVC.modalPresentationStyle = .fullScreen
            
            DispatchQueue.main.async {
                self.present(soloVC, animated: true, completion: nil)
            }
        }
    }
    
    // Variables
    var spinner = UIActivityIndicatorView()
    var wallpapers:[CKRecord] = []
    var sortType:SortType = .byLike
    private let refreshControl = UIRefreshControl()
    var queryCursor: CKQueryOperation.Cursor? = nil
    var loaded: Bool = false
    // Constants
    
    let currentWallpaperCategory:WallpaperCategory = .Group
    let cloudContainer = CKContainer.init(identifier: icloudContainerID)
    var likedRecordIds:[String] = getLikedRecordIds()
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.loadControl = UILoadControl(target: self, action: #selector(load))
        collectionView.loadControl?.heightLimit = 100.0 //The default is 80.0
        initSpinnerAndRefreshControl()
        checkLoadUserAgreeVC()
        load()
    }
    
    func checkLoadUserAgreeVC(){
        if !isKeyInUserDefaults(key: fisrtTimeKey) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let userAgreementVC = storyboard.instantiateViewController(withIdentifier: "userAgreementVC") as! UserAgreementViewController
            userAgreementVC.modalPresentationStyle = .fullScreen
            
            DispatchQueue.main.async {
                self.present(userAgreementVC, animated: true, completion: nil)
            }
        }
    }
    
    func getIndexPathOfRecordId(recordId: String) -> IndexPath?{
        for idx in 0..<wallpapers.count{
            if (wallpapers[idx].recordID.recordName == recordId){
                let indexPath = IndexPath(row: idx, section: 0)
                return indexPath
            }
        }
        return nil
    }
    
    func sortWallpapers(){
        switch sortType {
            case .byModifiedDate:
                wallpapers = wallpapers.sorted {
                    ($0.value(forKey: "modificationDate") as! Date) > ($1.value(forKey: "modificationDate") as! Date)
                }
            case .byLike:
                wallpapers = wallpapers.sorted {
                    ($0.value(forKey: "likes") as! Int) > ($1.value(forKey: "likes") as! Int)
                }
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        if likeChangedRecordId != ""{
            likedRecordIds = getLikedRecordIds()
            sortWallpapers()
            collectionView.reloadData()
            likeChangedRecordId = ""
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let connected = Reachability.isConnectedToNetwork()
        if !connected{
            let alertCtl = presentNoNetworkAlert()
            self.present(alertCtl, animated: true, completion: nil)
        }
    }
    
    func initSpinnerAndRefreshControl() {
        refreshControl.backgroundColor = BlackPinkPink
        refreshControl.tintColor = .lightGray
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(load), for: UIControl.Event.valueChanged)
        spinner.style = .medium
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        //Define layout constraints for the spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200.0), spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        spinner.startAnimating()
    }
    
    @IBAction func presentPopMenu(_ sender: UIButton) {
        let imageTintColor = BlackPinkBlack
        let actions = [
            PopMenuDefaultAction(title: SortByLikesTxt, image: UIImage(named: "heart-fill-icon"), color: imageTintColor),
            PopMenuDefaultAction(title: SortByDateTxt, image: UIImage(named: "calendar-icon"), color: imageTintColor)
        ]
        let menuVC = PopMenuViewController(sourceView:sender, actions: actions)
        menuVC.delegate = self
        let backgroundColor = BlackPinkPink
        menuVC.appearance.popMenuColor.backgroundColor = .solid(fill: backgroundColor)
        self.present(menuVC, animated: true, completion: nil)
    }
    
    func getSortDescriptor(sortType: SortType) -> NSSortDescriptor {
        switch sortType {
        case .byModifiedDate:
            return NSSortDescriptor(key: "modificationDate", ascending: false)
        case .byLike:
            return NSSortDescriptor(key: "likes", ascending: false)
        }
    }
    
    func stopLoadingAnimation(){
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.collectionView.loadControl?.endLoading()
            
            if self.refreshControl.isRefreshing{
                self.refreshControl.endRefreshing()
            }
        }
    }
    func completionHandlerAfterLoad(error: Error?, cursor: CKQueryOperation.Cursor?) -> Void{
        queryCursor = cursor
        if error != nil{
            print("Error in load Wallpapers: \(error?.localizedDescription ?? "")")
            stopLoadingAnimation()
        } else{
            loaded = true
            stopLoadingAnimation()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func load(){
        let connected = Reachability.isConnectedToNetwork()
        if connected{
            if loaded && queryCursor == nil{
                self.completionHandlerAfterLoad(error: nil, cursor: nil)
                return
            }
            collectionView.reloadData()
            //Fetch data using Convienence API
            let publicDatabase = cloudContainer.publicCloudDatabase
            
            let predicate = NSPredicate(format: "issued = 1 AND category = \(currentWallpaperCategory.rawValue)")
            let query = CKQuery(recordType: "Wallpaper", predicate: predicate)
            let sortDescriptor = getSortDescriptor(sortType: sortType)
            query.sortDescriptors = [sortDescriptor]
            let queryOperation = queryCursor == nil ? CKQueryOperation(query: query): CKQueryOperation(cursor: queryCursor!)
            
            queryOperation.desiredKeys = ["likes"]
            queryOperation.queuePriority = .veryHigh
            queryOperation.resultsLimit = resultLimit
            queryOperation.recordFetchedBlock = { (record) -> Void in
                self.wallpapers.append(record)
            }
            queryOperation.queryCompletionBlock = {(cursor, error) -> Void in
                self.completionHandlerAfterLoad(error: error, cursor: cursor)
            }
            publicDatabase.add(queryOperation)
        }
        else
        {
            stopLoadingAnimation()
        }
    }
    
    //update loadControl when user scrolls de tableView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadControl?.update()
    }
    
    func likesToString(likes: Int) -> String{
        if likes < 1000{
            return "\(likes)"
        } else{
            let numK:CGFloat = CGFloat(likes) / 1000.0
            return String(format: "%.1fk", numK)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers.count
    }
    
    func setCellImageCompletionHandler(cell: MainCollectionCellView?, image: UIImage, record: CKRecord) -> Void{
        if let cell = cell{
            cell.imageV.image = image
            cell.setNeedsLayout()
        }
    }
    
    func  getCellWallpaperByRecordID(cell:MainCollectionCellView?, recordId: CKRecord.ID, record: CKRecord, completion: @escaping (MainCollectionCellView?, UIImage, CKRecord) -> Void){
        if let imageFileURL = imageCache.object(forKey: recordId) {
            if let imageData = try? Data.init(contentsOf: imageFileURL as URL) {
                let image = UIImage(data: imageData) ?? UIImage()
                DispatchQueue.main.async {
                    completion(cell, image, record)
                }
            }
        } else{
            let cloudContainer = CKContainer.init(identifier: icloudContainerID)
            let publicDatabase = cloudContainer.publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [recordId])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .veryHigh
            
            fetchRecordsImageOperation.perRecordCompletionBlock = {
                    (recordNested, recordID, error) -> Void in
                    if let error = error {
                        print("Failed to get image: \(error.localizedDescription)")
                        return
                    }

                    if let wallpaperRecord = recordNested,
                        let image = wallpaperRecord.object(forKey: "image"),
                        let imageAsset = image as? CKAsset {

                        if let imageData = try? Data.init(contentsOf: imageAsset.fileURL!) {
                            
                            // Replace the placeholder image with the restaurant image
                            let image = UIImage(data: imageData) ?? UIImage()
                            DispatchQueue.main.async {
                                completion(cell, image, record)
                            }
                            imageCache.setObject(imageAsset.fileURL! as NSURL, forKey: recordId)
                        }
                    }
                }
            publicDatabase.add(fetchRecordsImageOperation)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCollectionViewCell", for: indexPath) as! MainCollectionCellView
        cell.layer.borderColor = BlackPinkBlack.cgColor
        cell.layer.borderWidth = cellBoarder
        let wallpaper = wallpapers[indexPath.row]
        
        if let likes: Int = wallpaper.object(forKey: "likes") as? Int{
            DispatchQueue.main.async {
                cell.likeLabel.text = self.likesToString(likes: likes)
            }
        }
        let recordId = wallpaper.recordID
        
        if likedRecordIds.contains(recordId.recordName){
            DispatchQueue.main.async {
                cell.heartV.image = UIImage(systemName: "heart.fill") ?? UIImage(named: "heart-fill-icon")
            }
        }else{
            DispatchQueue.main.async {
                cell.heartV.image = UIImage(systemName: "heart") ?? UIImage(named: "heart-icon")
            }
        }
        
        getCellWallpaperByRecordID(cell: cell, recordId: recordId, record: wallpaper, completion: setCellImageCompletionHandler(cell:image:record:))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.size.width / numberOfItemsPerRow
        let height = collectionView.frame.size.height / 3.0
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = UIEdgeInsets(top: 0,left: 0, bottom: 0,right: 0)
        return inset
    }
    
    func loadDetailVC(cell: MainCollectionCellView?, image: UIImage, record: CKRecord) -> Void{
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailVC = mainStoryBoard.instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
        
        let publicDatabase = cloudContainer.publicCloudDatabase
        
        detailVC.image = image
        detailVC.record = record
        detailVC.db = publicDatabase
        detailVC.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async {
            self.present(detailVC, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wallpaper = wallpapers[indexPath.row]
        let recordId = wallpaper.recordID
        getCellWallpaperByRecordID(cell: nil, recordId: recordId, record: wallpaper, completion: loadDetailVC(cell:image:record:))
    }
}

extension MainViewController: PopMenuViewControllerDelegate {

    // This will be called when a pop menu action was selected
    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        var sortTypeChanged:Bool = false
        if index == 0{
            if sortType != .byLike{
                sortType = .byLike
                sortTypeChanged = true
            }
        }else{
            if sortType != .byModifiedDate{
                sortType = .byModifiedDate
                sortTypeChanged = true
            }
        }
        if sortTypeChanged{
            sortWallpapers()
            collectionView.reloadData()
        }
    }
}
