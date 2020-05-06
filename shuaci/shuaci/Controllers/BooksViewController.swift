//
//  BooksViewController.swift
//  shuaci
//
//  Created by 任红雷 on 5/5/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud

class BooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var indicator = UIActivityIndicatorView()
    var books: [Book] = []
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44)))
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = .white
        getBooks()
        getbookImages()
    }
    
    func getbookImages() {
        DispatchQueue.global(qos: .background).async {
        do {
            for (index, book) in self.books.enumerated(){
            let imageFileURL = getDocumentsDirectory().appendingPathComponent("\(book.identifier).jpg")
            if !FileManager.default.fileExists(atPath: imageFileURL.path) {
                let imageData = try Data(contentsOf: imageFileURL)
                if let image = UIImage(data: imageData){
                    self.books[index].cover_image = image
                }
            } else {
                let query = LCQuery(className: "Book")
                _ = query.find { result in
                    switch result {
                    case .success(objects: let results):
                        // Books 是包含满足条件的 (className: "Book") 对象的数组
                        
                        for (index, item) in results.enumerated(){
                            if let cover_image = item.get("cover") as? LCFile {
                                //let imgData = photoData.value as! LCData
                                let url = URL(string: cover_image.url?.stringValue as! String)!
                                let data = try? Data(contentsOf: url)
                                print(url)
                                if let imageData = data {
                                    let image = UIImage(data: imageData)

                                    try? image!.jpegData(compressionQuality: 1.0)?.write(to: imageFileURL)
                                    self.books[index].cover_image = image ?? UIImage()
                                }
                            }
                        }
                        break
                    case .failure(error: let error):
                        print(error)
                    }
                }
                
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
        }
        } catch {
                print(error)
            }
        }
    }
    
    func getBooks(){
    DispatchQueue.global(qos: .background).async {
        do {
            let query = LCQuery(className: "Book")
            _ = query.find { result in
                switch result {
                case .success(objects: let results):
                    // Books 是包含满足条件的 (className: "Book") 对象的数组
                    
                    for (index, item) in results.enumerated(){
                        let identifier = item.get("identifier")?.stringValue
                        let level1_category = item.get("level1_category")?.intValue
                        let level2_category = item.get("level2_category")?.intValue
                        let name = item.get("name")?.stringValue
                        let desc = item.get("description")?.stringValue
                        let word_num = item.get("word_num")?.intValue
                        let recite_user_num = item.get("recite_user_num")?.intValue
                        
                        var book:Book = Book(identifier: identifier ?? "", level1_category: level1_category ?? 0, level2_category: level2_category ?? 0, name: name ?? "", description: desc ?? "", word_num: word_num ?? 0, recite_user_num: recite_user_num ?? 0, cover_image:UIImage() , data: NSData())
                        self.books.append(book)

                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    break
                case .failure(error: let error):
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {

        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "level1_tableview_cell", for: indexPath) as! CategoryTableViewCell
            cell.selectionStyle = .none

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "level2_tableview_cell", for: indexPath) as! CategoryTableViewCell
            cell.selectionStyle = .none

            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "bookItemCell", for: indexPath) as! BookItemTableViewCell
            cell.selectionStyle = .none
            let book = books[indexPath.row - 2]
            cell.name.text = book.name
            cell.introduce.text = book.description
            cell.num_word.text = "\(book.word_num)"
            cell.num_recite.text = "\(Int(Float(book.recite_user_num) / 10000.0))"
            cell.cover.image = book.cover_image
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return book_info_dict.count + 2
    }
}
