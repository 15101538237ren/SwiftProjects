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
    var searchResultsInter:[String] = []
    var AllData:[String:JSON] = [:]
    var AllData_keys:[String] = []
    var AllInterp_keys:[String] = []
    var searching = false
    let maxNumOfResult = 50
    var isSearchTextAscii = true
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
            for val in AllData.values{
                AllInterp_keys.append(val.stringValue)
            }
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
        cell.wordLabel.text = searchResults[indexPath.row]
        cell.meaningLabel.text = searchResultsInter[indexPath.row]
        return cell
    }
    
    
}
extension SearchViewController: UISearchBarDelegate, UISearchControllerDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0{
            var isSearchTextAsciiTmp = true
            for scalar in searchText.unicodeScalars {
                if !scalar.isASCII{
                    isSearchTextAsciiTmp = false
                }
            }
            isSearchTextAscii = isSearchTextAsciiTmp
            searchResults = []
            searchResultsInter = []
            for ik in 0..<AllData_keys.count{
                if searchResults.count > maxNumOfResult{
                    break
                }
                if isSearchTextAscii{
                    let key = AllData_keys[ik]
                    if key.lowercased().prefix(searchText.count) == searchText.lowercased(){
                        searchResults.append(key)
                        searchResultsInter.append(AllInterp_keys[ik])
                    }
                }else{
                    let key = AllInterp_keys[ik]
                    if key.contains(searchText){
                        searchResults.append(AllData_keys[ik])
                        searchResultsInter.append(key)
                    }
                }
            }
            searching = true
        }else{
            searching = false
            searchBar.text = ""
            searchResults = []
            searchResultsInter = []
        }
        tblView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        searchResults = []
        searchResultsInter = []
        tblView.reloadData()
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
        let searchText:String = searchBar.text ?? ""
        print(searchText)
        if searchText.count > 0{
            var isSearchTextAsciiTmp = true
            for scalar in searchText.unicodeScalars {
                if !scalar.isASCII{
                    isSearchTextAsciiTmp = false
                }
            }
            isSearchTextAscii = isSearchTextAsciiTmp

            if isSearchTextAscii{
                searchResults = []
                searchResultsInter = []
                for ik in 0..<AllData_keys.count{
                    if searchResults.count > maxNumOfResult{
                        break
                    }
                    let key = AllData_keys[ik]
                    if key.lowercased() == searchText.lowercased(){
                        searchResults.append(key)
                        searchResultsInter.append(AllInterp_keys[ik])
                    }
                }
                searching = true
                tblView.reloadData()
            }
        }
        
        searchBar.endEditing(true)
    }
}




