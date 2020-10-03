//
//  ViewController.swift
//  Blackpink
//
//  Created by Honglei Ren on 10/2/20.
//

import UIKit
import CloudKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // Outlet Variables
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Variables
    var spinner = UIActivityIndicatorView()
    var wallpapers:[CKRecord] = []
    private var imageCache = NSCache<CKRecord.ID, NSURL>()
    var sortType:SortType = .byLike
    var refreshControl: UIRefreshControl?
    
    // Constants
    
    let cellPadding:CGFloat = 1.5
    let numberOfItemsPerRow:CGFloat = 3
    let currentWallpaperCategory:WallpaperCategory = .Group
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        initSpinnerAndRefreshControl()
        fetchRecordsFromCloud()
    }
    
    func initSpinnerAndRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = .white
        refreshControl?.tintColor = .gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: UIControl.Event.valueChanged)
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
        default:
            return NSSortDescriptor(key: "modificationDate", ascending: false)
        }
    }
    
    @objc func fetchRecordsFromCloud(){
        wallpapers.removeAll()
        collectionView.reloadData()
        
        //Fetch data using Convienence API
        let cloudContainer = CKContainer.init(identifier: icloudContainerID)
        let publicDatabase = cloudContainer.publicCloudDatabase
        
        let predicate = NSPredicate(format: "issued = 1 AND category = \(currentWallpaperCategory.rawValue)")
        let query = CKQuery(recordType: "Wallpaper", predicate: predicate)
        let sortDescriptor = getSortDescriptor(sortType: sortType)
        query.sortDescriptors = [sortDescriptor]
        
        let queryOperation = CKQueryOperation(query: query)
            queryOperation.desiredKeys = ["image", "likes"]
            queryOperation.queuePriority = .veryHigh
            queryOperation.resultsLimit = 9 * 3
            queryOperation.recordFetchedBlock = { (record) -> Void in
                self.wallpapers.append(record)
            }

            queryOperation.queryCompletionBlock = { [unowned self] (cursor, error) -> Void in
                if let error = error {
                    print("Failed to get data from iCloud - \(error.localizedDescription)")
                    return
                }
                
                print("Successfully retrieve the data from iCloud")
                print("#wallpapers: \(wallpapers.count)")
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.collectionView.reloadData()
                    if let refreshControl = self.refreshControl {
                        if refreshControl.isRefreshing{
                            refreshControl.endRefreshing()
                        }
                    }
                }
            }
            publicDatabase.add(queryOperation)
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
        print("width: \(width), height: \(height)")
        cell.contentView.setNeedsLayout()
        cell.contentView.layoutIfNeeded()
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellPadding,left: cellPadding, bottom: cellPadding,right: cellPadding)
    }
}
