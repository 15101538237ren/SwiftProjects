//
//  VIPBenifitsVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/10/20.
//

import UIKit

class VIPBenefitsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var durations:[String] = ["3个月", "1年", "1个月"]
    var prices:[Int] = [18, 48, 15]
    var pastPrices:[Int] = [36, 99, 30]
    let borderWidth:CGFloat = 1.5
    
    let cellBorderColor = UIColor(red: 240, green: 240, blue: 240, alpha: 1)
    let cellBgColor = UIColor.white
    
    let selectedCellBorderColor = UIColor(red: 211, green: 200, blue: 174, alpha: 1.0)
    let selectedCellBgColor = UIColor(red: 253, green: 249, blue: 242, alpha: 1.0)
    
    var selectedIndex: Int = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Variables
    var showHint: Bool = false
    
    @IBOutlet weak var pastPriceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var headerView: UIView!{
        didSet{
            headerView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    @IBOutlet weak var upperView: UIView!{
        didSet{
            upperView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    
    @IBOutlet weak var midView: UIView!{
        didSet{
            midView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    
    @IBOutlet weak var bottomView: UIView!{
        didSet{
            bottomView.theme_backgroundColor = "TableCell.BackGroundColor"
        }
    }
    
    
    @IBOutlet var upperDimUIView: UIView!{
        didSet{
            upperDimUIView.theme_alpha = "VIPPageDimView.Alpha"
        }
    }
    
    @IBOutlet var bottomDimUIView: UIView!{
        didSet{
            bottomDimUIView.theme_alpha = "VIPPageDimView.Alpha"
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.theme_textColor = "VIP.TextColor"
        }
    }
    
    @IBOutlet weak var vipLabel: UILabel!{
        didSet{
            vipLabel.theme_textColor = "VIP.TextColor"
        }
    }
    
    @IBOutlet weak var cardImgView: UIImageView!{
        didSet{
            cardImgView.layer.cornerRadius = 12.0
            cardImgView.layer.masksToBounds = true
        }
    }
    
    func checkHint(){
        var hintNum:Int = 0
        let uploadHintKey:String = "ProWallpaperHint"
        if isKeyPresentInUserDefaults(key: uploadHintKey){
            hintNum = UserDefaults.standard.integer(forKey: uploadHintKey)
        }
        if hintNum < 3 {
            self.view.makeToast("这是一张会员专属壁纸哦~", duration: 1.0, position: .center)
        }
        
        UserDefaults.standard.set(hintNum + 1, forKey: uploadHintKey)
    }
    
    override func viewDidLoad() {
        view.theme_backgroundColor = "View.BackgroundColor"
        super.viewDidLoad()
        setupCollectionView()
        if showHint{
            checkHint()
        }
    }
    
    func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return durations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "membershipCollectionViewCell", for: indexPath) as! MembershipCollectionViewCell
        let row:Int = indexPath.row
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "¥ \(pastPrices[row]).00")
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        
        if row != selectedIndex {
            cell.layer.borderColor = cellBorderColor.cgColor
            cell.layer.backgroundColor = cellBgColor.cgColor
        }else{
            cell.layer.borderColor = selectedCellBorderColor.cgColor
            cell.layer.backgroundColor = selectedCellBgColor.cgColor
            priceLabel.text = "¥ \(prices[row]).00"
            pastPriceLabel.attributedText = attributeString
        }
        
        cell.layer.borderWidth = borderWidth
        
        cell.durationLabel.text = "\(durations[row])"
        
        cell.priceLabel.text = "\(prices[row])"
        
        cell.pastPriceLabel.attributedText = attributeString
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.size.width - (numberOfItemsPerRow - 1) * cellSpacing) / numberOfItemsPerRow
        let height:CGFloat = 120.0
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.reloadData()
    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
