//
//  NumWordPerGroupViewController.swift
//  shuaci
//
//  Created by Honglei on 6/18/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class NumWordPerGroupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    let number_of_words: [Int] = [10, 20, 30, 40, 50, 100, 150, 200, 300]
    var setting_tableView: UITableView!
    
    @IBOutlet weak var numVocPickerView: UIPickerView!
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func selectedIndex() -> Int{
        let npg_pref:Int = getPreference(key: "number_of_words_per_group") as! Int
        for i in 0..<number_of_words.count{
            if number_of_words[i] == npg_pref{
                return i
            }
        }
        return 0
    }
    
    func addBlurBackgroundView(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
    }
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            if viewTranslation.y > 0 {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                })
            }
        case .ended:
            if viewTranslation.y < 200 {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numVocPickerView.delegate = self
        numVocPickerView.dataSource = self
        view.backgroundColor = .clear
        addBlurBackgroundView()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        view.isUserInteractionEnabled = true
        let selected_ind:Int = selectedIndex()
        numVocPickerView.selectRow(selected_ind, inComponent: 0, animated: true)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning()
    {
       super.didReceiveMemoryWarning()
       // Dispose of any resources that can be recreated.
    }
    
    // Number of columns of data
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
   }
   
    // The number of rows of data
      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
          return number_of_words.count
      }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(number_of_words[row])
    }
    
    @IBAction func setNumOfWord(_ sender: UIButton) {
        let selected_ind = numVocPickerView.selectedRow(inComponent: 0)
        setPreference(key: "number_of_words_per_group", value: self.number_of_words[selected_ind])
        
        DispatchQueue.main.async {
            let indexPath_in_setting = IndexPath(item: 3, section: 0)
            let cell_in_setting = self.setting_tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath_in_setting) as! SettingTableViewCell
            cell_in_setting.valueLabel?.text = "\(self.number_of_words[selected_ind])"
            self.setting_tableView.reloadRows(at: [indexPath_in_setting], with: .top)
            self.dismiss(animated: true, completion: nil)
        }
        update_words()
    }
    
}
