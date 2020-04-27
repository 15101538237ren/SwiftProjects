//
//  ViewController.swift
//  shuaci
//
//  Created by 任红雷 on 4/23/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import Koloda
import LeanCloud
import pop

private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class MainScreenViewController: UIViewController, KolodaViewDelegate, KolodaViewDataSource {
    @IBOutlet weak var kolodaView: CustomKolodaView!
    
    @IBOutlet var wordLabel: UILabel!
    
    @IBOutlet var meaningLabel: UILabel!{
        didSet {
            meaningLabel.numberOfLines = 0
        }
    }
    @IBOutlet var accentLabel: UILabel!
    @IBOutlet var phoneticLabel: UILabel!
    @IBOutlet var audioButton: UIButton!
    
    
    
    var words: [Word] = [
        Word(wordHead: "sea", trans: [["tranCn":"n. 海；海洋；许多；大量", "pos": "n"]], usphone: "siː", ukphone: "siː", usspeech: "sea_0", ukspeech: "sea_1", remMethod: "", relWords: [], phrases: [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "beach", trans: [["tranCn":"海滩， 沙滩", "tranOther":"an area of sand or small stones at the edge of the sea or a lake", "pos":"n"]], usphone: "bitʃ", ukphone: "biːtʃ", usspeech: "beach_0", ukspeech: "beach_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "Paris", trans: [["tranCn":"n.巴黎","pos":"n"]], usphone: "'pærɪs", ukphone: "'pærɪs", usspeech: "Paris_0", ukspeech: "Paris_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "aurora", trans: [["tranCn":"[地物] 极光；曙光","pos":"n"]], usphone: "ɔ:'rɔ:rə", ukphone: "ɔ:'rɔ:rə", usspeech: "aurora_0", ukspeech: "aurora_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "pharmacy", trans: [["tranCn":"药房；配药学，药剂学；制药业；一批备用药品", "tranOther":"a shop or a part of a shop where medicines are prepared and sold", "pos":"n"]], usphone: "'fɑrməsi", ukphone: "'fɑːməsɪ", usspeech: "pharmacy_0", ukspeech: "pharmacy_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]])]
    
    @IBAction func close(segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        UIApplication.shared.open(URL(string: "https://yalantis.com/")!)
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return words.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let word = words[index]
        
        wordLabel.text = word.wordHead
        meaningLabel.text = word.trans[0]["tranCn"]
        accentLabel.text = "美"
        phoneticLabel.text = word.usphone
        return UIImageView(image: UIImage(named: word.wordHead))
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
    }
}

