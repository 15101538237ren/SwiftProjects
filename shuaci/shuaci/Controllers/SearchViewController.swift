//
//  SearchViewController.swift
//  shuaci
//
//  Created by Honglei on 7/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//
import UIKit
import SwiftyJSON

class SearchViewController: UIViewController {
    var searchResults:[String] = []
    var AllData:[String:JSON] = [:]
    var AllData_keys:[String] = []
    var searching = false
    let maxNumOfResult = 50
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!{
        didSet{
            searchBar.theme_backgroundColor = "Global.viewBackgroundColor"
            searchBar.theme_barTintColor = "Global.viewBackgroundColor"
            searchBar.searchBarStyle = .minimal
            searchBar.autocapitalizationType = .none
        }
    }
   
    @IBOutlet weak var tblView: UITableView!
    private var DICT_URL: URL = Bundle.main.url(forResource: "DICT.json", withExtension: nil)!
    
    
    func load_DICT(){
        do {
           let data = try Data(contentsOf: DICT_URL, options: .mappedIfSafe)
           AllData = try JSON(data: data)["data"].dictionary!
           AllData_keys = Array(AllData.keys)
           print("Load \(DICT_URL) successful!")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let textFieldInSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            textFieldInSearchBar.theme_textColor = "SearchVC.searchBarTextColor" 
        }
        
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        tblView.theme_backgroundColor = "Global.viewBackgroundColor"
        
        searchBar.delegate = self
        load_DICT()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.searchBar.becomeFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func processMeaningText(meaning: String) -> String{
        let numberOfNewlines:Int = meaning.components(separatedBy: "\n").count - 1
        var meaningLabelTxt:String = meaning
        if numberOfNewlines > 3{
            var finalStringArr:[String] = []
            let meaningArr:[String] = meaningLabelTxt.components(separatedBy: "\n")
            for mi in 0..<meaningArr.count - 1{
                if let firstChr = meaningArr[mi + 1].unicodeScalars.first{
                    if firstChr.isASCII{
                        finalStringArr.append("\(meaningArr[mi])\n")
                    }else{
                        finalStringArr.append("\(meaningArr[mi])；")
                    }
                }
            }
            meaningLabelTxt = finalStringArr.joined(separator: "")
        }
        return meaningLabelTxt
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordcell") as! SearchWordTableViewCell
        cell.backgroundColor = .clear
        let key = searchResults[indexPath.row]
        cell.wordLabel.text = key
        cell.meaningLabel.text = AllData[key]!.stringValue
        
        return cell
    }
    
    
}
extension SearchViewController: UISearchBarDelegate, UISearchControllerDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0{
            searchResults = AllData_keys .filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
            searchResults = Array(searchResults.prefix(maxNumOfResult))
            searching = true
        }else{
            searching = false
            searchBar.text = ""
            searchResults = []
        }
        tblView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        searchResults = []
        tblView.reloadData()
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
        let searchText:String = searchBar.text ?? ""
        print(searchText)
        if searchText.count > 0{
            searchResults = AllData_keys .filter({$0.lowercased() == searchText.lowercased()})
            searching = true
            tblView.reloadData()
        }
        
        searchBar.endEditing(true)
    }
}




