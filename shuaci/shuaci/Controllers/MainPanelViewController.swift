//
//  MainPanelViewController.swift
//  shuaci
//
//  Created by 任红雷 on 4/25/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud
import AVFoundation

class MainPanelViewController: UIViewController {
    @IBOutlet var mainPanelUIView: MainPanelUIView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var meaningLabel: UILabel!
    @IBOutlet var todayImageView: UIImageView!
    
    var words: [Word] = [
    Word(wordHead: "sea", trans: [["tranCn":"n.海；海洋", "pos": "n"]], usphone: "siː", ukphone: "siː", usspeech: "sea_0", ukspeech: "sea_1", remMethod: "", relWords: [], phrases: [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n.海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
    Word(wordHead: "beach", trans: [["tranCn":"n.海滩，沙滩", "tranOther":"an area of sand or small stones at the edge of the sea or a lake", "pos":"n"]], usphone: "bitʃ", ukphone: "biːtʃ", usspeech: "beach_0", ukspeech: "beach_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
    Word(wordHead: "Paris", trans: [["tranCn":"n.巴黎","pos":"n"]], usphone: "'pærɪs", ukphone: "'pærɪs", usspeech: "Paris_0", ukspeech: "Paris_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
    Word(wordHead: "aurora", trans: [["tranCn":"n.极光；曙光","pos":"n"]], usphone: "ɔ:'rɔ:rə", ukphone: "ɔ:'rɔ:rə", usspeech: "aurora_0", ukspeech: "aurora_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
    Word(wordHead: "pharmacy", trans: [["tranCn":"n.药房；药学；制药业", "tranOther":"a shop or a part of a shop where medicines are prepared and sold", "pos":"n"]], usphone: "'fɑrməsi", ukphone: "'fɑːməsɪ", usspeech: "pharmacy_0", ukspeech: "pharmacy_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]])]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = .white
        // Do any additional setup after loading the view.
        
        if let user = LCApplication.default.currentUser {
            // 跳到首页
            let word = words[2]
            wordLabel.text = word.wordHead
            meaningLabel.text = word.trans[0]["tranCn"]!
            todayImageView?.image = UIImage(named: word.wordHead)
        } else {
            // 显示注册或登录页面
            showLoginScreen()
        }
    }
    func showLoginScreen() {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "LoginReg", bundle:nil)
        let mainScreenViewController = LoginRegStoryBoard.instantiateViewController(withIdentifier: "StartScreen") as! MainScreenViewController
        DispatchQueue.main.async {
            self.present(mainScreenViewController, animated: true, completion: nil)
        }
    }

}
