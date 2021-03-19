//
//  SearchViewController.swift
//  shuaci
//
//  Created by Honglei on 7/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//
import UIKit
import SwiftyJSON
import AVFoundation

class SearchViewController: UIViewController {
    var searchResults:[String] = []
    var searchResultsInter:[String] = []
    var AllData:[String:JSON] = [:]
    var AllData_keys:[String] = []
    var Word_indexs_In_Oalecd8:[String:[Int]] = [:]
    var AllInterp_keys:[String] = []
    var searching = false
    var mp3Player: AVAudioPlayer?
    
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
           let data = try Data(contentsOf: DICT_URL, options: [])//.mappedIfSafe
            AllData = try JSON(data: data)["data"].dictionary!
            let key_arr = try JSON(data: data)["keys"].arrayValue
            let oalecd8_arr = try JSON(data: data)["oalecd8"].arrayValue
            for kid in 0..<key_arr.count{
                let key = key_arr[kid].stringValue
                AllData_keys.append(key)
                Word_indexs_In_Oalecd8[key] = [kid, oalecd8_arr[kid].intValue]
                AllInterp_keys.append(AllData[key]!.stringValue)
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
        
        tblView.separatorColor = .clear
        
        let panGestRec: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        panGestRec.delegate = self
        tblView.addGestureRecognizer(panGestRec)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedCells(sender:)))
        swipeRight.direction = .right
        tblView.addGestureRecognizer(swipeRight)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func swipedCells(sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
}

extension SearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
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
        cell.meaningLabel.text = searchResultsInter[indexPath.row].replacingOccurrences(of: "\\n", with: "\n")
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

       return tableView.rowHeight

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected_word:String = searchResults[indexPath.row]
        let indexItem:[Int] = Word_indexs_In_Oalecd8[selected_word]!
        let wordIndex: Int = indexItem[0]
        let hasValueInOalecd8: Int = indexItem[1]
        if hasValueInOalecd8 == 1{
            if Reachability.isConnectedToNetwork(){
                print("pronounce \(selected_word)")
                if let mp3_url = getWordPronounceURL(word: selected_word){
                    playMp3(url: mp3_url)
                }
            }
            
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let WordDetailVC = mainStoryBoard.instantiateViewController(withIdentifier: "WordDetailVC") as! WordDetailViewController
            WordDetailVC.wordIndex = wordIndex
            WordDetailVC.modalPresentationStyle = .overCurrentContext
            DispatchQueue.main.async {
                self.present(WordDetailVC, animated: true, completion: nil)
            }
        }else{
            view.makeToast("无词典解释☹️", duration: 1.0, position: .center)
        }
    }
    
    func playMp3(url: URL)
    {
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async {
            do {
                var downloadTask: URLSessionDownloadTask
                downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (urlhere, response, error) -> Void in
                    if let urlhere = urlhere{
                        do {
                            self.mp3Player = try AVAudioPlayer(contentsOf: urlhere)
                            self.mp3Player?.play()
                        } catch {
                            print("couldn't load file :( \(urlhere)")
                        }
                    }
            })
                downloadTask.resume()
            }}
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
        }
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




