//
//  ViewController.swift
//  Blackpink
//
//  Created by Honglei Ren on 10/2/20.
//

import UIKit
import CloudKit
import UILoadControl

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    // Outlet Variables
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var soloBtns: [UIButton]!{
        didSet{
            for soloBtn in soloBtns{
                soloBtn.layer.cornerRadius = soloBtn.layer.frame.width/2.0
                soloBtn.layer.masksToBounds = true
            }
        }
    }
    
    // Variables
    var spinner = UIActivityIndicatorView()
    var wallpapers:[CKRecord] = []
    private var imageCache = NSCache<CKRecord.ID, NSURL>()
    var sortType:SortType = .byLike
    var refreshControl: UIRefreshControl?
    var queryCursor: CKQueryOperation.Cursor? = nil
    var loaded: Bool = false
    // Constants
    
    let cellPadding:CGFloat = 1.5
    let numberOfItemsPerRow:CGFloat = 3
    let currentWallpaperCategory:WallpaperCategory = .Group
    let resultLimit:Int = 27
    
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.loadControl = UILoadControl(target: self, action: #selector(load))
        collectionView.loadControl?.heightLimit = 100.0 //The default is 80.0
        initSpinnerAndRefreshControl()
        load()
    }
    
    func initSpinnerAndRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = .white
        refreshControl?.tintColor = .gray
        refreshControl?.addTarget(self, action: #selector(load), for: UIControl.Event.valueChanged)
        spinner.style = .medium
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        //Define layout constraints for the spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200.0), spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        spinner.startAnimating()
    }
    
    func getSortDescriptor(sortType: SortType) -> NSSortDescriptor {
        switch sortType {
        case .byModifiedDate:
            return NSSortDescriptor(key: "modificationDate", ascending: false)
        case .byLike:
            return NSSortDescriptor(key: "likes", ascending: false)
        }
    }
    
    func completionHandlerAfterLoad(error: Error?, cursor: CKQueryOperation.Cursor?) -> Void{
        if error != nil{
            print("Error in load Wallpapers: \(error?.localizedDescription ?? "")")
        } else{
            loaded = true
            if let cursor = cursor {
                queryCursor = cursor
            }
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.collectionView.reloadData()
                self.collectionView.loadControl?.endLoading()
                if let refreshControl = self.refreshControl {
                    if refreshControl.isRefreshing{
                        refreshControl.endRefreshing()
                    }
                }
            }
        }
        
    }
    
    @objc func load(){
        if loaded && queryCursor == nil{
            self.completionHandlerAfterLoad(error: nil, cursor: nil)
            return
        }
        collectionView.reloadData()
        //Fetch data using Convienence API
        let cloudContainer = CKContainer.init(identifier: icloudContainerID)
        let publicDatabase = cloudContainer.publicCloudDatabase
        
        let predicate = NSPredicate(format: "issued = 1 AND category = \(currentWallpaperCategory.rawValue)")
        let query = CKQuery(recordType: "Wallpaper", predicate: predicate)
        let sortDescriptor = getSortDescriptor(sortType: sortType)
        query.sortDescriptors = [sortDescriptor]
        print(queryCursor==nil)
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCollectionViewCell", for: indexPath) as! MainCollectionCellView
        
        let wallpaper = wallpapers[indexPath.row]
        
        if let likes: Int = wallpaper.object(forKey: "likes") as? Int{
            DispatchQueue.main.async {
                cell.likeLabel.text = self.likesToString(likes: likes)
            }
        }
        
        if let imageFileURL = imageCache.object(forKey: wallpaper.recordID) {
            print("Get image from cache")
            if let imageData = try? Data.init(contentsOf: imageFileURL as URL) {
                cell.imageV.image = UIImage(data: imageData)
            }
        } else{
            let cloudContainer = CKContainer.init(identifier: icloudContainerID)
            let publicDatabase = cloudContainer.publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [wallpaper.recordID])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .veryHigh
            
            fetchRecordsImageOperation.perRecordCompletionBlock = {
                    (record, recordID, error) -> Void in
                    if let error = error {
                        print("Failed to get image: \(error.localizedDescription)")
                        return
                    }

                    if let wallpaperRecord = record,
                        let image = wallpaperRecord.object(forKey: "image"),
                        let imageAsset = image as? CKAsset {

                        if let imageData = try? Data.init(contentsOf: imageAsset.fileURL!) {

                            // Replace the placeholder image with the restaurant image
                            DispatchQueue.main.async {
                                cell.imageV.image = UIImage(data:imageData)
                                cell.setNeedsLayout()
                            }
                            self.imageCache.setObject(imageAsset.fileURL! as NSURL, forKey: wallpaper.recordID)
                            print("Loaded image for cell \(indexPath.row)")
                        }
                    }
                }
            publicDatabase.add(fetchRecordsImageOperation)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.size.width -  (numberOfItemsPerRow + 1) * cellPadding) / numberOfItemsPerRow
        
        let height = (collectionView.frame.size.height - (numberOfItemsPerRow + 1) * cellPadding) / 3.0
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellPadding,left: cellPadding, bottom: cellPadding,right: cellPadding)
    }
}
