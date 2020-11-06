//
//  CategoryVC.swift
//  fullwallpaper
//
//  Created by Honglei on 10/29/20.
//

import UIKit
import LeanCloud
import SwiftyJSON

class CategoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Variables
    var indicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    var categories:[Category] = []
    
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .clear
        initActivityIndicator(text: loadingTxt)
        loadCategories()
    }
    
    func initActivityIndicator(text: String) {
        strLabel.removeFromSuperview()
        indicator.removeFromSuperview()
        effectView.removeFromSuperview()
        let height:CGFloat = 46.0
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 180, height: height))
        strLabel.text = text
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = .darkGray
        strLabel.alpha = 1.0
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: height)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        effectView.backgroundColor = UIColor(red: 244, green: 244, blue: 245, alpha: 1.0)
        
        effectView.alpha = 1.0
        indicator = .init(style: .medium)
        indicator.frame = CGRect(x: 0, y: 0, width: height, height: height)
        indicator.alpha = 1.0
        indicator.startAnimating()

        effectView.contentView.addSubview(indicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    func stopIndicator(){
        self.indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
        self.effectView.alpha = 0
        self.strLabel.alpha = 0
    }
    
    func loadCategoryFromLocal(){
        do {
            if let jsonData = loadJson(fileName: categoryJsonFileName){
                let jsonDecoder = JSONDecoder()
                categories = try jsonDecoder.decode([Category].self, from: jsonData)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func encodeSaveJson(){
        let jsonEncoder = JSONEncoder()
        do {
            print(categories)
            let jsonData = try jsonEncoder.encode(categories)
            if let jsonStr = String(data: jsonData, encoding: String.Encoding.utf16){
                saveJson(fileName: categoryJsonFileName, jsonStr: jsonStr)
            }
        }
        catch {
            print("Error in Saving image : \(error)")
        }
    }
    
    func loadImagesFromCloud(results: [LCObject]){
        for rid in 0..<results.count{
            let res = results[rid]
            if let cover_file = res.get("cover") as? LCFile {
                let name = res.get("name")?.stringValue ?? ""
                let url = URL(string: cover_file.url?.stringValue ?? "")!
                let data = try? Data(contentsOf: url)
                if let imageData = data {
                    if let image = UIImage(data: imageData){
                        savePhoto(image: image, photoName: "\(name).jpg")
                        let indexPath = IndexPath(row: rid, section: 0)
                        DispatchQueue.main.async {
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                }
            }
        }
    }
    
    func loadCategories()
    {
        loadCategoryFromLocal()
        
        if !Reachability.isConnectedToNetwork(){
            let alertCtl = presentNoNetworkAlert()
            self.stopIndicator()
            self.present(alertCtl, animated: true, completion: nil)
            return
        }
        
        DispatchQueue.global(qos: .background).async { [self] in
        do {
            let query = LCQuery(className: "Category")
            let updated_count = query.count()
            print(updated_count)
            if categories.count != updated_count.intValue{
                _ = query.find() { result in
                    switch result {
                    case .success(objects: let results):
                        categories = []
                        for rid in 0..<results.count{
                            let res = results[rid]
                            let name = res.get("name")?.stringValue ?? ""
                            let eng = res.get("eng")?.stringValue ?? ""
                            let category = Category(name: name, eng: eng)
                            categories.append(category)
                        }
                        encodeSaveJson()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.stopIndicator()
                        }
                        loadImagesFromCloud(results: results)
                        break
                    case .failure(error: let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        }
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryTableViewCell", for: indexPath) as! CategoryTableViewCell
        let row: Int = indexPath.row
        cell.titleLabel.text = categories[row].name
        
        if let image = loadPhoto(cacheType: .image, photoName: "\(categories[row].name).jpg"){
            DispatchQueue.main.async {
                cell.imgPlaceholder.alpha = 0
                cell.imageV.alpha = 1
                cell.titleLabel.alpha = 1
                cell.imageV.image = image
                cell.setNeedsLayout()
            }
        }
        
        return cell
    }
}
