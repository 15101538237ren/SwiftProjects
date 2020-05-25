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

class BooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet private var collectionViews: [UICollectionView]!
    @IBOutlet var mainPanelViewController: MainPanelViewController!
    var indicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    var tempBooks:[Book] = []
    var tempItems:[LCObject] = []
    
    var storedOffsets = [Int: CGFloat]()
    @IBOutlet var tableView: UITableView!
 
    
    func setCollectionViewDataSourceDelegate() {
        for collectionView in collectionViews{
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.reloadData()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1{
            let cell = collectionView.cellForItem(at: indexPath) as! Level1CollectionViewCell
            
            DispatchQueue.main.async {
                cell.level1_category_label.textColor = .lightGray
                cell.indicatorBtn.alpha = 0
            }
        }
        else{
            let cell = collectionView.cellForItem(at: indexPath) as! Level2CollectionViewCell
            DispatchQueue.main.async {
                cell.level2_category_button.backgroundColor = .lightGray
                cell.level2_category_button.setTitleColor(.darkGray, for: .normal)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1{
            currentSelectedCategory = indexPath.row
            category_items = categories[currentSelectedCategory]?["subcategory"] ?? [:]
            let cell = collectionView.cellForItem(at: indexPath) as! Level1CollectionViewCell
            
            DispatchQueue.main.async {
                cell.level1_category_label.textColor = .black
                cell.indicatorBtn.alpha = 1
                self.collectionViews[1].reloadData()
            }
            
            if global_total_books.count != 0 && currentSelectedCategory > 0{
                books = []
                resultsItems = []
                for (index, book) in global_total_books.enumerated(){
                    if book.level1_category == currentSelectedCategory{
                        books.append(book)
                        resultsItems.append(global_total_items[index])
                    }
                }
                DispatchQueue.main.async {
                    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    self.tableView.reloadData()
                }
            }
            else if currentSelectedCategory == 0{
                books = global_total_books
                resultsItems = global_total_items
                
                DispatchQueue.main.async {
                    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
       let indexPath:IndexPath = IndexPath(row: 0, section: 0)
        for collectionView in collectionViews{
            if collectionView.tag == 1{
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                let cell = collectionView.cellForItem(at: indexPath) as! Level1CollectionViewCell
                cell.level1_category_label.textColor = .black
                cell.indicatorBtn.alpha = 1
            }
        }
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1{
            return categories.count
        }
        else{
            return category_items.count
        }
    }
    
    var width_constraint: [Int: NSLayoutConstraint] = [:]
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "level1_collection_cell", for: indexPath) as! Level1CollectionViewCell
            cell.level1_category_label.text = categories[indexPath.row]?["category"]?[0]
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "level2_collection_cell", for: indexPath) as! Level2CollectionViewCell
            let char_number:Int = category_items[indexPath.row]?.count ?? 0
            if let width_cons = width_constraint[indexPath.row]{
                width_cons.isActive = false
            }
            
            cell.level2_category_button.layer.cornerRadius = 9.0
            cell.level2_category_button.layer.masksToBounds = true
            cell.btnTapAction = {
                () in
                currentSelectedSubCategory = indexPath.row
                let cell = collectionView.cellForItem(at: indexPath) as! Level2CollectionViewCell
                DispatchQueue.main.async {
                    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    cell.level2_category_button.backgroundColor = .orange
                    cell.level2_category_button.setTitleColor(.white, for: .normal)
                }
                if global_total_books.count != 0 && currentSelectedSubCategory > 0{
                    books = []
                    resultsItems = []
                    for (index, book) in global_total_books.enumerated(){
                        if (book.level1_category == currentSelectedCategory) && (book.level2_category == currentSelectedSubCategory){
                            books.append(book)
                            resultsItems.append(global_total_items[index])
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                else if global_total_books.count != 0 && currentSelectedCategory > 0{
                    books = []
                    resultsItems = []
                    for (index, book) in global_total_books.enumerated(){
                        if book.level1_category == currentSelectedCategory{
                            books.append(book)
                            resultsItems.append(global_total_items[index])
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            if let item_title = category_items[indexPath.row] {
                cell.level2_category_button.setTitle(item_title, for: .normal)

                if item_title.count > 2{
                    let new_width = 50 + (char_number - 2) * 10
                    let new_constraint = cell.level2_category_button.widthAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(new_width))
                    width_constraint[indexPath.row] = new_constraint
                    new_constraint.isActive = true
                }
                else{
                    let fixed_cons = cell.level2_category_button.widthAnchor.constraint(equalToConstant: 50.0)
                    width_constraint[indexPath.row] = fixed_cons
                    fixed_cons.isActive = true
                }
            }
            return cell
        }
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
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        category_items = [0:"全部"]
        currentSelectedCategory = 0
        currentSelectedSubCategory = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        initActivityIndicator(text: "数据加载中")
        setCollectionViewDataSourceDelegate()
        loadBooks()
    }
    
    func stopIndicator(){
        self.indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
        self.effectView.alpha = 0
        self.strLabel.alpha = 0
    }
    
    func loadBooks()
    {
        if books.count > 0{
            stopIndicator()
            if Reachability.isConnectedToNetwork(){
                DispatchQueue.global(qos: .background).async {
                do {
                    let query = LCQuery(className: "Book")
                    let updated_count = query.count()
                    if books.count != updated_count.intValue {
                        _ = query.find { result in
                            switch result {
                            case .success(objects: let results):
                                // Books 是包含满足条件的 (className: "Book") 对象的数组
                                for item in results{
                                    let identifier = item.get("identifier")?.stringValue
                                    let level1_category = item.get("level1_category")?.intValue
                                    let level2_category = item.get("level2_category")?.intValue
                                    let name = item.get("name")?.stringValue
                                    let desc = item.get("description")?.stringValue
                                    let word_num = item.get("word_num")?.intValue
                                    let recite_user_num = item.get("recite_user_num")?.intValue
                                    
                                    let book:Book = Book(identifier: identifier ?? "", level1_category: level1_category ?? 0, level2_category: level2_category ?? 0, name: name ?? "", description: desc ?? "", word_num: word_num ?? 0, recite_user_num: recite_user_num ?? 0)
                                    self.tempBooks.append(book)
                                    self.tempItems.append(item)
                                }
                                if self.tempBooks.count != books.count{
                                    books = self.tempBooks
                                    resultsItems = self.tempItems
                                    
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
                                    
                                    if global_total_books.count == 0 && books.count != 0{
                                        global_total_books = books
                                        global_total_items = resultsItems
                                    }
                                }
                                break
                            case .failure(error: let error):
                                print(error)
                            }
                        }
                    }
                }
                }
            }else{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
            }
            
        }else{
            DispatchQueue.global(qos: .background).async {
            do {
                let query = LCQuery(className: "Book")
                _ = query.find { result in
                    switch result {
                    case .success(objects: let results):
                        // Books 是包含满足条件的 (className: "Book") 对象的数组
                        for item in results{
                            let identifier = item.get("identifier")?.stringValue
                            let level1_category = item.get("level1_category")?.intValue
                            let level2_category = item.get("level2_category")?.intValue
                            let name = item.get("name")?.stringValue
                            let desc = item.get("description")?.stringValue
                            let word_num = item.get("word_num")?.intValue
                            let recite_user_num = item.get("recite_user_num")?.intValue
                            
                            let book:Book = Book(identifier: identifier ?? "", level1_category: level1_category ?? 0, level2_category: level2_category ?? 0, name: name ?? "", description: desc ?? "", word_num: word_num ?? 0, recite_user_num: recite_user_num ?? 0)
                            self.tempBooks.append(book)
                            self.tempItems.append(item)
                        }
                        books = self.tempBooks
                        resultsItems = self.tempItems
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.stopIndicator()
                        }
                        break
                    case .failure(error: let error):
                        print(error)
                    }
                }
            }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bookItemCell", for: indexPath) as! BookItemTableViewCell
            cell.cover.image = UIImage(named: "english_book")
            cell.selectionStyle = .none
            let index: Int = indexPath.row
            print(books.count)
            if index < books.count{
                let book = books[index]
                cell.identifier = book.identifier
                cell.name.text = book.name
                cell.introduce.text = book.description
                cell.num_word.text = "\(book.word_num)"
                cell.num_recite.text = (book.recite_user_num > 10000) ? "\(Int(Float(book.recite_user_num) / 10000.0))万" : "\(book.recite_user_num)"
                cell.cover.layer.cornerRadius = 9.0
                cell.cover.layer.masksToBounds = true
                // Check if the image is stored in cache
            }
            
        if let image = loadPhoto(name_of_photo: "\(books[indexPath.row].identifier as! NSString).jpg"){
                // Fetch image from cache
                print("Get image from file")
                DispatchQueue.main.async {
                    cell.cover.image = image
                    cell.setNeedsLayout()
                }

            } else {
                if Reachability.isConnectedToNetwork(){
                    DispatchQueue.global(qos: .background).async {
                    do {
                        if let cover_image = resultsItems[index].get("cover") as? LCFile {
                            //let imgData = photoData.value as! LCData
                            let url = URL(string: cover_image.url?.stringValue ?? "")!
                            let data = try? Data(contentsOf: url)
                            print(url)
                            
                            if let imageData = data {
                                if let image_name = cover_image.name?.stringValue
                                {
                                    var components = image_name.components(separatedBy: ".")
                                    if components.count > 1 { // If there is a file extension
                                        components.removeLast()
                                        let image_filename = components.joined(separator: ".")
                                        if let image = UIImage(data: imageData)
                                        {
                                            savePhoto(image: image, name_of_photo: "\(image_filename).jpg")
                                            DispatchQueue.main.async {
                                                cell.cover.image = image
                                                cell.setNeedsLayout()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        }
                    }
                }else{
                    let alertCtl = presentNoNetworkAlert()
                    self.present(alertCtl, animated: true, completion: nil)
                }
            }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  books.count
    }
    
    func downloadBookJson(index: Int){
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async {
            do {
                DispatchQueue.main.async {
                    self.initActivityIndicator(text: "数据下载中")
                }
                if let bookJson = resultsItems[index].get("data") as? LCFile {
                    let url = URL(string: bookJson.url?.stringValue ?? "")!
                    let data = try? Data(contentsOf: url)
                    print(url)
                    
                    if let jsonData = data {
                        savejson(fileName: "current_book", jsonData: jsonData)

                        UserDefaults.standard.set(books[index].identifier, forKey: "current_book")
                        currentbook_json_obj = load_json(fileName: "current_book")
                        update_words()
                        get_words()
                        DispatchQueue.main.async {
                            self.stopIndicator()
                            self.dismiss(animated: true, completion: nil)
                            self.mainPanelViewController.loadLearnController()
                        }
                    }
                }
                }
            }
        }else{
            let alertCtl = presentNoNetworkAlert()
            self.present(alertCtl, animated: true, completion: nil)
        }
        
    }
    
    func downloadAlert(index: Int, bookName: String){
        let alertController = UIAlertController(title: "选择词书", message: "学习\(bookName)?", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "确定", style: .default, handler: { action in
            setCurrentBookId(bookId: books[index].identifier)
            self.downloadBookJson(index: index)
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        downloadAlert(index: indexPath.row, bookName: books[indexPath.row].name)
    }
    
}

extension BooksViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var label = ""
        if collectionView.tag == 1{
            label = categories[indexPath.row]?["category"]?[0] as! String
            return label.size(withAttributes: [
                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        }
        else{
            label = category_items[indexPath.row]!
            let label_size = label.size(withAttributes: [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
            return label_size
        }
    }
}
