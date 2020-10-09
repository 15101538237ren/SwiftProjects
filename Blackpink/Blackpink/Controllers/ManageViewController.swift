//
//  LikedViewController.swift
//  Blackpink
//
//  Created by Honglei on 10/5/20.
//

import UIKit
import CloudKit
import UILoadControl

class ManageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    enum Mode {
        case view
        case select
    }
    
    // Outlet Variables
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectBtn: UIButton!{
        didSet{
            selectBtn.setTitle(SelectTxt, for: .normal)
        }
    }
    
    @IBOutlet var rejectBtn: UIButton!{
        didSet{
            rejectBtn.layer.cornerRadius = 10.0
            rejectBtn.layer.masksToBounds = true
            rejectBtn.setTitleColor( UIColor.systemRed, for: .normal)
            rejectBtn.setTitleColor(.lightGray, for: .disabled)
            rejectBtn.layer.borderWidth = 3
            rejectBtn.layer.borderColor = UIColor.systemRed.cgColor
            rejectBtn.setTitle(RejectTxt, for: .normal)
        }
    }
    
    @IBOutlet var approveBtn: UIButton!{
        didSet{
            approveBtn.layer.cornerRadius = 10.0
            approveBtn.layer.masksToBounds = true
            approveBtn.setTitleColor(UIColor.systemGreen, for: .normal)
            approveBtn.setTitleColor(.lightGray, for: .disabled)
            approveBtn.layer.borderWidth = 3
            approveBtn.layer.borderColor = UIColor.systemGreen.cgColor
            approveBtn.setTitle(ApproveTxt, for: .normal)
        }
    }
    
    // Variables
    var spinner = UIActivityIndicatorView()
    var wallpapers:[CKRecord] = []
    
    var selectedIndexPathDict:[IndexPath:Bool] = [:]
    
    private let refreshControl = UIRefreshControl()
    var queryCursor: CKQueryOperation.Cursor? = nil
    var loaded: Bool = false
    var currentMode: Mode = .view{
        didSet{
            switch currentMode {
            case .select:
                DispatchQueue.main.async { [self] in
                    selectBtn.setTitle(CancelTxt, for: .normal)
                    selectBtn.setTitleColor( UIColor.systemBlue, for: .normal)
                    collectionView.allowsMultipleSelection = true
                }
            case .view:
                DispatchQueue.main.async { [self] in
                    selectBtn.setTitle(SelectTxt, for: .normal)
                    selectBtn.setTitleColor( UIColor.black, for: .normal)
                    collectionView.allowsMultipleSelection = false
                }
            }
            var indexToDelete:[IndexPath] = []
            for (indexPath, selected) in selectedIndexPathDict{
                if selected{
                    indexToDelete.append(indexPath)
                }
            }
            DispatchQueue.main.async { [self] in
                collectionView.deleteItems(at: indexToDelete)
            }
            selectedIndexPathDict = [:]
        }
    }
    
    // Constants
    let cloudContainer = CKContainer.init(identifier: icloudContainerID)
    
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
            print("\(ErrorPrefix): \(error?.localizedDescription ?? "")")
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
            if (loaded && queryCursor == nil){
                self.completionHandlerAfterLoad(error: nil, cursor: nil)
                return
            }
            collectionView.reloadData()
            //Fetch data using Convienence API
            let publicDatabase = cloudContainer.publicCloudDatabase
            let predicate = NSPredicate(format: "issued = 0")
            let query = CKQuery(recordType: "Wallpaper", predicate: predicate)
            let sortDescriptor = NSSortDescriptor(key: "modificationDate", ascending: false)
            query.sortDescriptors = [sortDescriptor]
            let queryOperation = queryCursor == nil ? CKQueryOperation(query: query): CKQueryOperation(cursor: queryCursor!)
            
            queryOperation.desiredKeys = ["likes", "issued", "category"]
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers.count
    }
    
    func setCellImageCompletionHandler(cell: ManageCollectionViewCell?, image: UIImage, record: CKRecord) -> Void{
        if let cell = cell{
            cell.imageV.image = image
            cell.setNeedsLayout()
        }
    }
    
    func  getCellWallpaperByRecordID(cell:ManageCollectionViewCell?, recordId: CKRecord.ID, record: CKRecord, completion: @escaping (ManageCollectionViewCell?, UIImage, CKRecord) -> Void){
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "manageCollectionViewCell", for: indexPath) as! ManageCollectionViewCell
        
        cell.layer.borderColor = BlackPinkBlack.cgColor
        cell.layer.borderWidth = cellBoarder
        let wallpaper = wallpapers[indexPath.row]
        
        let recordId = wallpaper.recordID
        let category = wallpaper.object(forKey: "category") as! Int
        let imgName = getSoloImageNameByInt(category: category)
        if let image = UIImage(named: imgName){
            cell.categoryV.image = image
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
    
    @objc func loadPreviewVC(cell: ManageCollectionViewCell?, image: UIImage, record: CKRecord) -> Void{
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let previewVC = mainStoryBoard.instantiateViewController(withIdentifier: "previewVC") as! ImagePreviewVC
        previewVC.image = image
        previewVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(previewVC, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch currentMode {
        case .view:
            let wallpaper = wallpapers[indexPath.row]
            let recordId = wallpaper.recordID
            getCellWallpaperByRecordID(cell: nil, recordId: recordId, record: wallpaper, completion: loadPreviewVC(cell:image:record:))
        case .select:
            break
        }
        selectedIndexPathDict[indexPath] = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedIndexPathDict[indexPath] = false
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectBtnTapped(_ sender: UIButton) {
        currentMode = currentMode == .view ? .select : .view
    }
    
    @IBAction func rejectBtnTapped(_ sender: UIButton) {
        if currentMode == .select{
            var recordIds:[CKRecord.ID] = []
            var indexPathsToDelete:[IndexPath] = []
            for (indexPath, selected) in selectedIndexPathDict{
                if selected{
                    indexPathsToDelete.append(indexPath)
                    recordIds.append(wallpapers[indexPath.row].recordID)
                }
            }
            
            indexPathsToDelete = indexPathsToDelete.sorted(by: {$0.item > $1.item})
            
            // selectedIndexPathDict = [:]
            let connected = Reachability.isConnectedToNetwork()
            if connected{
                let publicDatabase = cloudContainer.publicCloudDatabase
                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIds)
                operation.modifyRecordsCompletionBlock = { [self]_, _, error in
                    if error == nil{
                        DispatchQueue.main.async { [self] in
                            collectionView.deleteItems(at: indexPathsToDelete)
                        }
                        
                        for indexPath in indexPathsToDelete{
                            self.wallpapers.remove(at: indexPath.row)
                        }
                    }
                    DispatchQueue.main.async { [self] in
                        let ac = UIAlertController(title: selectedItemDeletedTxt, message: "", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: OKMsg, style: .default))
                        self.present(ac, animated: true)
                    }
                    self.selectedIndexPathDict = [:]
                    self.currentMode = .view
                }
                publicDatabase.add(operation)
            }else{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
            }
        }else{
            let ac = UIAlertController(title: pleaseClickSelectTxt, message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: OKMsg, style: .default))
            self.present(ac, animated: true)
        }
    }
    
    
    @IBAction func approveBtnTapped(_ sender: UIButton) {
        if currentMode == .select{
            var records:[CKRecord] = []
            var indexPathsToDelete:[IndexPath] = []
            for (indexPath, selected) in selectedIndexPathDict{
                if selected{
                    indexPathsToDelete.append(indexPath)
                    wallpapers[indexPath.row]["issued"] = 1
                    records.append(wallpapers[indexPath.row])
                }
            }
            
            indexPathsToDelete = indexPathsToDelete.sorted(by: {$0.item > $1.item})
            
            // selectedIndexPathDict = [:]
            let connected = Reachability.isConnectedToNetwork()
            if connected{
                let publicDatabase = cloudContainer.publicCloudDatabase
                let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
                operation.modifyRecordsCompletionBlock = { [self]_, _, error in
                    if error == nil{
                        DispatchQueue.main.async { [self] in
                            collectionView.deleteItems(at: indexPathsToDelete)
                        }
                        
                        for indexPath in indexPathsToDelete{
                            self.wallpapers.remove(at: indexPath.row)
                        }
                    }
                    
                    DispatchQueue.main.async { [self] in
                        let ac = UIAlertController(title: selectedItemApprovedTxt, message: "", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: OKMsg, style: .default))
                        self.present(ac, animated: true)
                    }
                    self.selectedIndexPathDict = [:]
                    self.currentMode = .view
                }
                publicDatabase.add(operation)
            }else{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
            }
        } else{
            let ac = UIAlertController(title: pleaseClickSelectTxt, message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: OKMsg, style: .default))
            self.present(ac, animated: true)
        }
    }
    
}
