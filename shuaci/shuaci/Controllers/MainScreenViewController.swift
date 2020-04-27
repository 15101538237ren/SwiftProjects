//
//  ViewController.swift
//  shuaci
//
//  Created by 任红雷 on 4/23/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud

class MainScreenViewController: UIViewController {
    @IBOutlet var card: CardUIView!
    var words: [Word] = [
        Word(wordHead: "sea", trans: [["tranCn":"n. 海；海洋；许多；大量", "pos": "n"]], usphone: "siː", ukphone: "siː", usspeech: "sea_0", ukspeech: "sea_1", remMethod: "", relWords: [], phrases: [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "beach", trans: [["tranCn":"海滩， 沙滩", "tranOther":"an area of sand or small stones at the edge of the sea or a lake", "pos":"n"]], usphone: "bitʃ", ukphone: "biːtʃ", usspeech: "beach_0", ukspeech: "beach_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "Paris", trans: [["tranCn":"n.巴黎","pos":"n"]], usphone: "'pærɪs", ukphone: "'pærɪs", usspeech: "Paris_0", ukspeech: "Paris_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "aurora", trans: [["tranCn":"[地物] 极光；曙光","pos":"n"]], usphone: "ɔ:'rɔ:rə", ukphone: "ɔ:'rɔ:rə", usspeech: "aurora_0", ukspeech: "aurora_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]]),
        Word(wordHead: "pharmacy", trans: [["tranCn":"药房；配药学，药剂学；制药业；一批备用药品", "tranOther":"a shop or a part of a shop where medicines are prepared and sold", "pos":"n"]], usphone: "'fɑrməsi", ukphone: "'fɑːməsɪ", usspeech: "pharmacy_0", ukspeech: "pharmacy_1", remMethod: "pharma (药) + cy (学科) → 药剂学", relWords: [], phrases:  [["pContent":"china sea", "pCn": "中国海"]], synoWords: [["pos": ["n"], "tran":["n. [海洋][地理]海；海洋；许多；大量"], "hwds":["ocean", "lots of", "wealth"]]], sentences: [["sContent": "Sea and sky seemed to blend.", "sCn": "大海和蓝天似乎相融合。"]])]
    @IBAction func close(segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


