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
    
    func loadCategoryFromLocal(){
        if let json_objects = loadJson(fileName: categoryJsonFileName){
            categories = []
            let json_arr = json_objects.arrayValue
            for json_obj in json_arr{
                let coverUrl = json_obj["coverUrl"].stringValue
                let name = json_obj["name"].stringValue
                let eng = json_obj["eng"].stringValue
                let category = Category(name: name, eng: eng, coverUrl: coverUrl)
                categories.append(category)
            }
            self.tableView.reloadData()
            self.stopIndicator()
        }
    }
    
    func encodeSaveJson(){
        do {
            let jsonData: Data = try JSONEncoder().encode(categories)
            if let jsonString = String(data: jsonData, encoding: .utf8){
                saveStringTo(cacheType: .json, fileName: categoryJsonFileName, jsonStr: jsonString)
            }else{
                print("Error in Saving json, Nil Json String!")
            }
        }catch {
            print(error.localizedDescription)
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
        
        DispatchQueue.global(qos: .utility).async { [self] in
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
                            
                            if let file = res.get("cover") as? LCFile {
                                let category = Category(name: name, eng: eng, coverUrl: file.url!.stringValue!)
                                
                                if let imageData = file.dataValue {
                                    if let image = UIImage(data: imageData){
                                        savePhoto(image: image, photoName: "\(categories[rid].eng).jpg")
                                        let indexPath = IndexPath(row: rid, section: 0)
                                        DispatchQueue.main.async {
                                            self.tableView.reloadRows(at: [indexPath], with: .none)
                                        }
                                    }
                                }
                                categories.append(category)
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.stopIndicator()
                        }
                        
                        for cid in 0..<categories.count{
                            let category = categories[cid]
                            URLSession.shared.dataTask(with: NSURL(string: category.coverUrl)! as URL, completionHandler: { (data, response, error) -> Void in

                                if let error = error {
                                    print(error.localizedDescription)
                                }
                                if let data = data{
                                    if let image = UIImage(data: data){
                                        savePhoto(image: image, photoName: "\(category.eng).jpg")
                                        
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            let indexPath = IndexPath(row: cid, section: 0)
                                            DispatchQueue.main.async {
                                                self.tableView.reloadRows(at: [indexPath], with: .none)
                                            }
                                        })
                                    }
                                }
                                
                            }).resume()
                        }
                        
                        encodeSaveJson()
                        
                        break
                    case .failure(error: let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        }
    }

    func loadImageWithObjId(row:Int, nameOfCategory: String, objId: String){
        DispatchQueue.global(qos: .utility).async { [self] in
            do {
                let query = LCQuery(className: "_File")
                let _ = query.get(objId) { (result) in
                    switch result {
                    case .success(object: let file):
                        let url = URL(string: file.url?.stringValue ?? "")!
                        let data = try? Data(contentsOf: url)
                        if let imageData = data {
                            if let image = UIImage(data: imageData){
                                savePhoto(image: image, photoName: "\(nameOfCategory).jpg")
                                let indexPath = IndexPath(row: row, section: 0)
                                DispatchQueue.main.async {
                                    self.tableView.reloadRows(at: [indexPath], with: .none)
                                }
                            }
                        }
                    case .failure(error: let error):
                        print(error.localizedDescription)
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
        
        if let image = loadPhoto(cacheType: .image, photoName: "\(categories[row].eng).jpg"){
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
