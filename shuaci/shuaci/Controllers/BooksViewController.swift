//
//  BooksViewController.swift
//  shuaci
//
//  Created by 任红雷 on 5/5/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud
import SwiftyJSON

class BooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var indicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    func initActivityIndicator() {
        strLabel.removeFromSuperview()
        indicator.removeFromSuperview()
        effectView.removeFromSuperview()

        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = "加载数据中"
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = .darkGray

        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        effectView.backgroundColor = UIColor(red: 244, green: 244, blue: 245, alpha: 1.0)

        indicator = .init(style: .medium)
        indicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        indicator.startAnimating()

        effectView.contentView.addSubview(indicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var userPhotoBtn: UIButton!{
        didSet {
            userPhotoBtn.layer.cornerRadius = userPhotoBtn.layer.frame.width/2.0
            userPhotoBtn.layer.masksToBounds = true
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        initActivityIndicator()
    }
    
    func loadBooks()
    {
//        if fileM.fileExists(atPath: book_json_path.path) {
//            do{
//                let data = try Data(contentsOf: book_json_path, options: .alwaysMapped)
//                let books = try JSON(data: data)
//                for book in books{
//
//                }
//            }catch let error as Error{
//                print(error)
//            }
//
//        } else {
//            print("FILE NOT AVAILABLE")
//        }
        if books.count > 0{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                self.effectView.alpha = 0
                self.strLabel.alpha = 0
            }
        }
        else{
            fetchBooks()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {

        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "level1_tableview_cell", for: indexPath) as! Level1CategoryTableViewCell
            cell.selectionStyle = .none

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "level2_tableview_cell", for: indexPath) as! Level2CategoryTableViewCell
            cell.selectionStyle = .none

            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "bookItemCell", for: indexPath) as! BookItemTableViewCell
            cell.selectionStyle = .none
            let index: Int = indexPath.row - 2
            if books.count > 0 {
                let book = books[index]
                cell.identifier = book.identifier
                cell.name.text = book.name
                cell.introduce.text = book.description
                cell.num_word.text = "\(book.word_num)"
                cell.num_recite.text = (book.recite_user_num > 10000) ? "\(Int(Float(book.recite_user_num) / 10000.0))万" : "\(book.recite_user_num)"
                cell.cover.image = UIImage(named: "english_book")
                cell.cover.layer.cornerRadius = 9.0
                cell.cover.layer.masksToBounds = true
                // Check if the image is stored in cache
                if let imageFileURL = imageCache.object(forKey: cell.identifier as! NSString) {
                    // Fetch image from cache
                    print("Get image from cache")
                    if let imageData = try? Data.init(contentsOf: imageFileURL as URL) {
                        DispatchQueue.main.async {
                            cell.cover.image = UIImage(data: imageData)
                            cell.setNeedsLayout()
                        }
                    }

                } else {
                    DispatchQueue.global(qos: .background).async {
                    do {
                        if let cover_image = resultsItems[index].get("cover") as? LCFile {
                            //let imgData = photoData.value as! LCData
                            let url = URL(string: cover_image.url?.stringValue as! String)!
                            let data = try? Data(contentsOf: url)
                            print(url)
                            if let imageData = data {
                                let image = UIImage(data: imageData)
                                let imageFileURL = getDocumentsDirectory().appendingPathComponent("\(book.identifier).jpg")
                                try? image!.jpegData(compressionQuality: 1.0)?.write(to: imageFileURL)
                                imageCache.setObject(imageFileURL as! NSURL, forKey: cell.identifier as! NSString)
                                DispatchQueue.main.async {
                                    cell.cover.image = image!
                                    cell.setNeedsLayout()
                                }
                            }
                        }
                        }
                    }
                }
            }
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  books.count + 2
    }
}
