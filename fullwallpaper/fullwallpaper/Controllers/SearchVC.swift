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
    
    var searchKeyword:String = ""
    var wallpapers:[Wallpaper] = []
    var NoNetwork: Bool = false
    var minDateOfLastFetch: String? = nil
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    func setup() {
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

        //        collectionView.addLoadMore(action: { [weak self] in
//            self?.handleLoadMore()
//        })
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.searchBar.becomeFirstResponder()
        }
    }
    
    @objc func loadWallpapers()
    {
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

        DispatchQueue.global(qos: .utility).async { [self] in
        do {
            let query = LCQuery(className: "Wallpaper")
            query.whereKey("caption", .matchedSubstring(searchKeyword))
            query.whereKey("createdAt", .descending)

            if (minDateOfLastFetch != nil){
                query.whereKey("createdAt", .lessThan(dateFromString(dateStr: minDateOfLastFetch!)))
            }

            query.limit = wallpaperLimitEachFetch

            _ = query.find { result in
                switch result {
                case .success(objects: let results):
                    if results.count == 0{
                        DispatchQueue.main.async {
                            collectionView.stopLoadMore()
                            collectionView.setLoadMoreEnable(false)

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
                        let date:String = fromLCDateToDateStr(date: res.createdAt!)
                        if let file = res.get("img") as? LCFile {
                            let imgUrl = file.url!.stringValue!
                            let thumbnailUrl = file.thumbnailURL(.scale(thumbnailScale))!.stringValue!
                            let wallpaper = Wallpaper(name: name, category: category, thumbnailUrl: thumbnailUrl, imgUrl: imgUrl, likes: likes, createdAt: date)
                            wallpapers.append(wallpaper)
                        }
                    }
                    
                    minDateOfLastFetch = wallpapers[wallpapers.count - 1].createdAt
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.NoNetwork = false
                        self.reloadEmptyStateForCollectionView(self.collectionView)
                        stopIndicator()
                        if wallpapers.count > wallpaperLimitEachFetch{
                            self.collectionView.stopLoadMore()
                        }
                    }

                    break
                case .failure(error: let error):
                    print(error.localizedDescription)
                }
            }

        }
        }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallpaperCollectionViewCell", for: indexPath) as! WallpaperCollectionViewCell
        let wallpaper:Wallpaper = wallpapers[indexPath.row]
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
            loadDetailVC(imageUrl: imgUrl)
        }
    }
    
    private func handleLoadMore() {
        loadWallpapers()
    }
    
    // MARK: - Empty State Data Source
    
    var emptyStateTitle: NSAttributedString {
            let attrs = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
            let title: String = NoNetwork ? "无网络，请检查设置！" : "没有找到相关壁纸"
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
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
        searchBar.endEditing(true)
        searchKeyword = searchBar.text ?? ""
        loadWallpapers()
    }
}

