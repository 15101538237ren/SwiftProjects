//
//  ViewController.swift
//  fullwallpaper
//
//  Created by Honglei on 10/28/20.
//

import UIKit
import LeanCloud
import Nuke

class WallpaperVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    //Variables
    var indicator = UIActivityIndicatorView()
    
    var wallpapers:[Wallpaper] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0)
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        initActivityIndicator()
        loadWallpapers()
    }
    
    func initActivityIndicator() {
        indicator.removeFromSuperview()
        let height:CGFloat = 46.0
        indicator = .init(style: .medium)
        indicator.color = .lightGray
        indicator.frame = CGRect(x: view.frame.midX - height/2, y: view.frame.midY - height/2, width: height, height: height)
        indicator.alpha = 1.0
        indicator.startAnimating()
        view.addSubview(indicator)
    }
    
    func stopIndicator(){
        self.indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
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
            let alertCtl = presentNoNetworkAlert()
            self.stopIndicator()
            self.present(alertCtl, animated: true, completion: nil)
            return
        }
        
        DispatchQueue.global(qos: .utility).async { [self] in
        do {
            let query = LCQuery(className: "Wallpaper")
            let updated_count = query.count()
            print(updated_count)
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
                            self.stopIndicator()
                        }
                        
                        break
                    case .failure(error: let error):
                        print(error.localizedDescription)
                    }
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
        Nuke.loadImage(with: imgUrl, options: options, into: cell.imageV)
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
}

