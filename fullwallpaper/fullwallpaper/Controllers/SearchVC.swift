//
//  SearchVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 11/21/20.
//

import UIKit
import LeanCloud
import Nuke
import UIEmptyState
import Refreshable

class SearchVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate {
    var NoMoreData:Bool = false
    var searchKeyword:String = ""
    var wallpapers:[Wallpaper] = []
    var NoNetwork: Bool = false
    var minDateOfLastFetch: String? = nil
    var viewTranslation = CGPoint(x: 0, y: 0)
    fileprivate var timeOnThisPage: Int = 0
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    func setup() {
        view.theme_backgroundColor = "View.BackgroundColor"
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
        searchBar.delegate = self
        let gestRec: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        gestRec.delegate = self
        collectionView.addGestureRecognizer(gestRec)

        collectionView.addLoadMore(action: { [weak self] in
            self?.handleLoadMore()
        })
        enableEdgeSwipeGesture()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tictoc), userInfo: nil, repeats: true)
        setup()
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
                transition.duration = fadeDuration
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
        var info = ["Um_Key_PageName": "搜索页", "Um_Key_Duration": timeOnThisPage] as [String : Any]
        if let user = LCApplication.default.currentUser{
            let userId = user.objectId!.stringValue!
            info["Um_Key_UserID"] = userId
        }
        UMAnalyticsSwift.event(eventId: "Um_Event_PageView", attributes: info)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.searchBar.becomeFirstResponder()
        }
    }
    
    @objc func loadWallpapers()
    {
        if !switchesLoaded{
            loadSwitchesSetting { [self] in
                loadWallpapers()
            }
            return
        }
        collectionView.setLoadMoreEnable(false)
        
        DispatchQueue.main.async { [self] in
            collectionView.stopLoadMore()
        }
        
        if searchKeyword == ""{
            stopIndicator()
            NoNetwork = false
            self.reloadEmptyStateForCollectionView(self.collectionView)
            return
        }
        
        if !Reachability.isConnectedToNetwork(){
            stopIndicator()
            NoNetwork = true
            self.reloadEmptyStateForCollectionView(self.collectionView)
            return
        }
        if !NoMoreData {
            DispatchQueue.global(qos: .utility).async { [self] in
            do {
                let query = LCQuery(className: "Wallpaper")
                query.whereKey("test", .equalTo(testMode))
                query.whereKey("caption", .matchedSubstring(searchKeyword))
                query.whereKey("createdAt", .descending)

                if (minDateOfLastFetch != nil){
                    query.whereKey("createdAt", .lessThan(dateFromString(dateStr: minDateOfLastFetch!)))
                }

                query.limit = wallpaperLimitEachFetch

                _ = query.find { result in
                    switch result {
                    case .success(objects: let results):
                        
                        var info = ["Um_Key_SearchKeyword": searchKeyword] as [String : Any]
                        if let user = LCApplication.default.currentUser{
                            let userId = user.objectId!.stringValue!
                            info["Um_Key_UserID"] = userId
                        }
                        UMAnalyticsSwift.event(eventId: "Um_Event_SearchSuc", attributes: info)
                        
                        if results.count == 0{
                            NoMoreData = true
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
                                let thumbnailUrl = file.thumbnailURL(.scale(thumbnailScale))!.stringValue!
                                let wallpaper = Wallpaper(objectId: res.objectId!.stringValue!, name: name, category: category, thumbnailUrl: thumbnailUrl, imgUrl: imgUrl, likes: likes, createdAt: date, isPro: pro)
                                wallpapers.append(wallpaper)
                            }
                        }
                        
                        minDateOfLastFetch = wallpapers[wallpapers.count - 1].createdAt
                        
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
        }
        else{
            stopIndicator()
            self.NoNetwork = false
            self.reloadEmptyStateForCollectionView(self.collectionView)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallpaperCollectionViewCell", for: indexPath) as! WallpaperCollectionViewCell
        let wallpaper:Wallpaper = wallpapers[indexPath.row]
        let liked  = userLikedWPs.contains(wallpaper.objectId)
        cell.proBtn.alpha = wallpaper.isPro ? 1 : 0
        cell.heartV.image = liked ? UIImage(systemName: "heart.fill") ?? UIImage(named: "heart-fill-icon") : UIImage(systemName: "heart") ?? UIImage(named: "heart-icon")
        cell.likeLabel.text = "\(wallpaper.likes)"
        let thumbnailUrl = URL(string: wallpaper.thumbnailUrl)!
        Nuke.loadImage(with: thumbnailUrl, options: wallpaperLoadingOptions, into: cell.imageV)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.size.width - (numberOfItemsPerRow - 1) * cellSpacing) / numberOfItemsPerRow
        let height = width * cellHeightWidthRatio
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wallpaper:Wallpaper = wallpapers[indexPath.row]
        
        if let imgUrl = URL(string: wallpaper.imgUrl){
            loadDetailVC(imageUrl: imgUrl, wallpaperObjectId: wallpaper.objectId, pro: wallpaper.isPro)
        }
        
    }
    
    private func handleLoadMore() {
        loadWallpapers()
    }
    
    // MARK: - Empty State Data Source
    
    var emptyStateTitle: NSAttributedString {
            let attrs = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
            let title: String = NoNetwork ? NoNetworkStr :  noWallpaperFindText
            return NSAttributedString(string: title, attributes: attrs)
        }
    
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        emptyView.contentView.layer.borderColor = UIColor.clear.cgColor
        emptyView.contentView.layer.backgroundColor = UIColor.clear.cgColor
    }

    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SearchVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }
}

extension SearchVC: UISearchBarDelegate, UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if wallpapers.count > 0{
            wallpapers = []
            minDateOfLastFetch = nil
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
        searchBar.endEditing(true)
        searchKeyword = searchBar.text ?? ""
        NoMoreData = false
        loadWallpapers()
    }
}

