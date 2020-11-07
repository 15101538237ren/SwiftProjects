//
//  CategoryVC.swift
//  fullwallpaper
//
//  Created by Honglei on 10/29/20.
//

import UIKit
import LeanCloud
import SwiftyJSON
import Nuke


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
        initActivityIndicator()
        loadCategories()
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
                                categories.append(category)
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.stopIndicator()
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
        let imgUrl = URL(string: categories[row].coverUrl)!
        Nuke.loadImage(with: imgUrl, options: options, into: cell.imageV)
        return cell
    }
}
