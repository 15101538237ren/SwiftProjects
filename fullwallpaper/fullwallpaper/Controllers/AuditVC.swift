//
//  AuditVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/5/20.
//

import UIKit
import LeanCloud
import Nuke
import UIEmptyState
import Refreshable
import PopMenu

class AuditVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    enum Mode {
        case view
        case select
    }
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.theme_textColor = "BarTitleColor"
        }
    }
    
    @IBOutlet weak var selectBtn: UIButton!
    
    @IBOutlet weak var actionBtn: UIButton!{
        didSet {
            actionBtn.layer.cornerRadius = 10.0
            actionBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var NoNetWork: Bool = false
    var switched: Bool = false
    var minDateOfLastLatestWallpaperFetches: [Int: String?] = [0:nil, 1:nil, 2:nil]
    var wallpapers:[Int : [WallpaperInReview]] = [0:[], 1:[], 2:[]]
    var selectedIndexPathDict:[IndexPath:Bool] = [:]
    
    var currentMode: Mode = .view{
        didSet{
            switch currentMode {
            case .select:
                DispatchQueue.main.async { [self] in
                    selectBtn.setTitle("取消", for: .normal)
                    selectBtn.setTitleColor( .systemBlue, for: .normal)
                    collectionView.allowsMultipleSelection = true
                    actionBtn.backgroundColor = .systemGreen
                    actionBtn.isEnabled = true
                }
            case .view:
                DispatchQueue.main.async { [self] in
                    selectBtn.setTitle("选择", for: .normal)
                    selectBtn.setTitleColor(.darkGray, for: .normal)
                    collectionView.allowsMultipleSelection = false
                    actionBtn.backgroundColor = .lightGray
                    actionBtn.isEnabled = false
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
    
    func setSegmentedControl(){
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray], for: .normal)
        segmentedControl.theme_backgroundColor = "SegmentedCtrlTintColor"
        segmentedControl.theme_selectedSegmentTintColor = "SegmentedCtrlSelectedTintColor"
    }
    
    func setupCollectionView() {
        
        collectionView.theme_backgroundColor = "View.BackgroundColor"
        currentMode = .view
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
        setSegmentedControl()
        setupCollectionView()
        initIndicator(view: self.view)
        loadWallpapers(selectedIdx: 0)
    }
    
    private func handleLoadMore() {
        loadWallpapers(selectedIdx: segmentedControl.selectedSegmentIndex)
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
    
    
    func loadWallpapers(selectedIdx: Int)
    {
        if !Reachability.isConnectedToNetwork(){
            self.NoNetWork = true
            self.reloadEmptyStateForCollectionView(self.collectionView)
            stopIndicator()
            return
        }
        
        if categories.count == 0{
            initIndicator(view: self.view)
            loadCategories(completion: {})
        }
        
        DispatchQueue.global(qos: .utility).async { [self] in
        do {
            let query = LCQuery(className: "Wallpaper")
            if selectedIdx == 0{
                query.whereKey("status", .equalTo(0))
                query.whereKey("status", .included)
                query.whereKey("dependent", .notExisted)
            } else if selectedIdx == 1{
                query.whereKey("status", .equalTo(0))
                query.whereKey("status", .included)
                query.whereKey("dependent", .existed)
                query.whereKey("dependent", .included)
            }else{
                query.whereKey("status", .greaterThan(1))
                query.whereKey("status", .included)
            }
            
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
                            collectionView.stopLoadMore()
                            collectionView.setLoadMoreEnable(false)
                            if (switched){
                                collectionView.reloadData()
                                switched = false
                            }
                            self.reloadEmptyStateForCollectionView(self.collectionView)
                            
                            stopIndicator()
                        }
                        return
                    }
                    print("Fetched \(results.count) wallpapers")
                    for rid in 0..<results.count{
                        let res = results[rid]
                        let caption = res.get("caption")?.stringValue ?? ""
                        let status = res.get("status")?.intValue ?? 0
                        let pro = res.get("pro")?.boolValue ?? false
                        let category = res.get("category")?.stringValue ?? ""
                        var collectionName:String = ""
                        
                        if let dependent = res.get("dependent") as? LCObject{
                            collectionName = dependent.get("name")?.stringValue ?? ""
                        }
                        
                        let date:String = fromLCDateToDateStr(date: res.createdAt!)
                        
                        if let file = res.get("img") as? LCFile {
                            let imgUrl = file.url!.stringValue!
                            let thumbnailUrl = file.thumbnailURL(.scale(thumbnailScale))!.stringValue!
                            let wallpaper = WallpaperInReview(objectId: res.objectId!.stringValue!, caption: caption, status: status, category: category, collectionName: collectionName, thumbnailUrl: thumbnailUrl, imgUrl: imgUrl, createdAt: date, isPro: pro)
                            wallpapers[selectedIdx]!.append(wallpaper)
                        }
                    }
                    
                    minDateOfLastLatestWallpaperFetches[selectedIdx] = wallpapers[selectedIdx]![wallpapers[selectedIdx]!.count - 1].createdAt
                    
                    let first = wallpapers[selectedIdx]!.count == wallpaperLimitEachFetch
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.NoNetWork = false
                        if (switched){
                            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                        at: .top,
                                                        animated: true)
                            switched = false
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
        for (indexPath, selected) in selectedIndexPathDict{
            if selected{
                collectionView.deselectItem(at: indexPath, animated: false)
            }}
        selectedIndexPathDict = [:]
        currentMode = .view
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                initIndicator(view: self.view)
                switched = true
                loadWallpapers(selectedIdx: 0)
            case 1:
                initIndicator(view: self.view)
                switched = true
                loadWallpapers(selectedIdx: 1)
            case 2:
                initIndicator(view: self.view)
                switched = true
                loadWallpapers(selectedIdx: 2)
            default:
                break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers[segmentedControl.selectedSegmentIndex]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "auditCollectionViewCell", for: indexPath) as! AuditCollectionViewCell
        let wallpaper:WallpaperInReview = wallpapers[segmentedControl.selectedSegmentIndex]![indexPath.row]
        if segmentedControl.selectedSegmentIndex == 2{
            cell.statusImageView.tintColor = statusColor(status: wallpaper.status)
            cell.statusImageView.alpha = 1
        }else{
            cell.statusImageView.alpha = 0
        }
        
        let categoryName:String = categoryENtoCN[wallpaper.category] ?? wallpaper.category
        if wallpaper.collectionName != "" {
            cell.categoryLabel.text = "\(categoryName): \(wallpaper.collectionName)"
        }else{
            cell.categoryLabel.text = categoryName
        }
        cell.proBtn.alpha = wallpaper.isPro ? 1 : 0
        cell.descriptionLabel.text = wallpaper.caption
        let thumbnailUrl = URL(string: wallpaper.thumbnailUrl)!
        Nuke.loadImage(with: thumbnailUrl, options: wallpaperLoadingOptions, into: cell.imageV)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch currentMode {
        case .view:
            let wallpaper:WallpaperInReview = wallpapers[segmentedControl.selectedSegmentIndex]![indexPath.row]
            if let imgUrl = URL(string: wallpaper.imgUrl){
                loadDetailVC(imageUrl: imgUrl, wallpaperObjectId: wallpaper.objectId)
            }
        case .select:
            break
        }
        selectedIndexPathDict[indexPath] = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedIndexPathDict[indexPath] = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.size.width - (numberOfItemsPerRow - 1) * cellSpacing) / numberOfItemsPerRow
        let height = width * cellHeightWidthRatio
        return CGSize(width: width, height: height)
    }
    
    @IBAction func actions(sender: UIButton){
        if selectedIndexPathDict.count > 0{
            let iconWidthHeight:CGFloat = 20
            
            let approveAction = PopMenuDefaultAction(title: "通过", image: UIImage(named: "approve"), color: UIColor.lightGray)
            let proAction = PopMenuDefaultAction(title: "加PRO", image: UIImage(named: "membership"), color: UIColor.lightGray)
            let rejectAction = PopMenuDefaultAction(title: "拒绝", image: UIImage(named: "reject"), color: UIColor.lightGray)
            let deleteAction = PopMenuDefaultAction(title: "删除", image: UIImage(named: "delete"), color: UIColor.lightGray)
            
            approveAction.iconWidthHeight = iconWidthHeight
            proAction.iconWidthHeight = iconWidthHeight
            rejectAction.iconWidthHeight = iconWidthHeight
            deleteAction.iconWidthHeight = iconWidthHeight
            
            let menuVC = PopMenuViewController(sourceView: actionBtn, actions: [approveAction, proAction, rejectAction, deleteAction])
            menuVC.delegate = self
            menuVC.appearance.popMenuFont = .systemFont(ofSize: 15, weight: .regular)
            
            menuVC.appearance.popMenuColor.backgroundColor = .solid(fill: UIColor(red: 128, green: 128, blue: 128, alpha: 1))
            self.present(menuVC, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectBtnTapped(_ sender: UIButton) {
        currentMode = currentMode == .view ? .select : .view
        for (indexPath, selected) in selectedIndexPathDict{
        if selected{
            collectionView.deselectItem(at: indexPath, animated: false)
        }}
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
}


extension AuditVC: PopMenuViewControllerDelegate {

    func wallpaperStatusSetting(wallpaperObjs: [LCObject], code: Int, popMenuViewController: PopMenuViewController, indexPathsToDelete:[IndexPath], withPro: Bool = false){
        do{
            let tempWallpaperObjs = wallpaperObjs
            
            for wallpaperObj in tempWallpaperObjs{
                try wallpaperObj.set("status", value: code)
                if withPro {
                    try wallpaperObj.set("pro", value: true)
                }
            }
            
            _ = LCObject.save(tempWallpaperObjs, completion: { [self] (result) in
                switch result {
                case .success:
                    stopIndicator()
                    DispatchQueue.main.async { [self] in
                        popMenuViewController.dismiss(animated: true, completion: nil)
                        collectionView.deleteItems(at: indexPathsToDelete)
                        view.makeToast("操作成功!", duration: 1.0, position: .center)
                    }
                    
                    for indexPath in indexPathsToDelete{
                        wallpapers[segmentedControl.selectedSegmentIndex]!.remove(at: indexPath.row)
                    }
                    
                    selectedIndexPathDict = [:]
                    currentMode = .view
                case .failure(error: let error):
                    stopIndicator()
                    self.view.makeToast(error.reason, duration: 1.0, position: .center)
                }
            })
            
        } catch {
            stopIndicator()
            view.makeToast(error.localizedDescription, duration: 1.0, position: .center)
        }
    }
    
    func deleteSelectedWallpapers(wallpaperObjs: [LCObject], popMenuViewController: PopMenuViewController, indexPathsToDelete:[IndexPath]){
        _ = LCObject.delete(wallpaperObjs, completion: { [self] (result) in
            switch result {
            case .success:
                stopIndicator()
                DispatchQueue.main.async { [self] in
                    popMenuViewController.dismiss(animated: true, completion: nil)
                    collectionView.deleteItems(at: indexPathsToDelete)
                    view.makeToast("删除成功!", duration: 1.0, position: .center)
                }
                
                for indexPath in indexPathsToDelete{
                    wallpapers[segmentedControl.selectedSegmentIndex]!.remove(at: indexPath.row)
                }
                
                selectedIndexPathDict = [:]
                currentMode = .view
            case .failure(error: let error):
                stopIndicator()
                self.view.makeToast(error.reason, duration: 1.0, position: .center)
            }
        })
    }
    
    // This will be called when a pop menu action was selected
    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        if currentMode == .select {
            
            initIndicator(view: self.view)
            
            var wallpaperObjs:[LCObject] = []
            var indexPathsToDelete:[IndexPath] = []
            
            for (indexPath, selected) in selectedIndexPathDict{
                if selected{
                    let wallpaper:WallpaperInReview = wallpapers[segmentedControl.selectedSegmentIndex]![indexPath.row]
                    print(wallpaper.caption)
                    let wallpaperObj = LCObject(className: "Wallpaper", objectId: wallpaper.objectId)
                    wallpaperObjs.append(wallpaperObj)
                    
                    indexPathsToDelete.append(indexPath)
                }
            }
            
            indexPathsToDelete = indexPathsToDelete.sorted(by: {$0.item > $1.item})
            
            if Reachability.isConnectedToNetwork(){
                if index == 0{
                    wallpaperStatusSetting(wallpaperObjs: wallpaperObjs, code: 1, popMenuViewController: popMenuViewController, indexPathsToDelete: indexPathsToDelete)
                }else if index == 1{
                    wallpaperStatusSetting(wallpaperObjs: wallpaperObjs, code: 1, popMenuViewController: popMenuViewController, indexPathsToDelete: indexPathsToDelete, withPro: true)
                }else if index == 2{
                    wallpaperStatusSetting(wallpaperObjs: wallpaperObjs, code: -1, popMenuViewController: popMenuViewController,  indexPathsToDelete: indexPathsToDelete)
                }
                else{
                    deleteSelectedWallpapers(wallpaperObjs: wallpaperObjs, popMenuViewController: popMenuViewController,  indexPathsToDelete: indexPathsToDelete)
                }
                
                
            }else{
                self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            }
        } else{
            self.view.makeToast("请先选择壁纸!", duration: 1.0, position: .center)
        }
    }
}
