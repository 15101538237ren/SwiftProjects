//
//  WordDetailViewController.swift
//  shuaci
//
//  Created by Honglei on 8/27/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import WebKit
import LeanCloud

class WordDetailViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    var indicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    var wordIndex: Int!
    
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
    
    func stopIndicator(){
        self.indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
        self.effectView.alpha = 0
        self.strLabel.alpha = 0
    }
    
    let en_prounce = "<img src=\"/symbols/uk_pron.png\" class=\"fayin\"/>"
    let us_prounce = "<img src=\"/symbols/us_pron.png\" class=\"fayin\"/>"
    
    let html_first_half = "<html><head>\n    <title>Dict</title>\n    <meta charset=\"utf-8\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n<style>* {\n  box-sizing: inherit;\n}\nbody,\nhtml {\n  margin: 0;\n  height: 100%;\n  overscroll-behavior-y: contain;\n}\ninput {\n  border: none;\n  background-image: none;\n  background-color: transparent;\n  box-shadow: none;\n}\ninput:focus {\n  outline: none;\n}\ndiv:focus {\n  outline: none;\n}\n.root {\n  font-family: 'MyFont', 'Menlo', '华文细黑', '黑体';\n  height: 100%;\n  box-sizing: border-box;\n}\n.root .main {\n  padding: 10%;\n  word-break: keep-all;\n  word-wrap: break-word;\n  overflow-y: scroll;\n}\n.root .mainfocus {\n  border-top-color: #666;\n}\n.root .main h2 {\n  margin-block-start: 0;\n}\n.root .main .help h4,\n.root .main .help table,\n.root .main .help p,\n.root .main .help a {\n  margin-left: 2em;\n}\n.root .main table {\n  border-collapse: collapse;\n}\n.root .main table,\n.root .main th,\n.root .main td {\n  border: 1px solid #000;\n}\n.root .main th,\n.root .main td {\n  padding: 2px 10px;\n}\n.root .main td:nth-child(1) {\n  text-align: center;\n}\n.root .desktop .main {\n  width: 100%;\n  height: 100%;\n}\n.root .mobile {\n  height: 100%;\n  display: flex;\n  flex-direction: column-reverse;\n}\n.root .mobile .main {\n  height: 100%;\n  width: 100%;\n  flex-grow: 1;\n  flex-shrink: 1;\n}\n.root .main.EN_OALD .word-root {\n  margin-bottom: 1rem;\n  font-weight: bold;\n}\n.root .main.EN_OALD .Media {\n  cursor: pointer;\n}\n.root .main.EN_OALD .d .chn {\n  font-weight: bold;\n}\n.root .main.EN_OALD .gl:after {\n  content: ' ';\n}\n.root .main.EN_OALD a {\n  text-decoration: none;\n}\n.root .main.EN_OALD .top-g .z {\n  display: none;\n}\n.root .main.EN_OALD .pos {\n  display: block;\n  color: #d11000;\n  margin-top: 1rem;\n  font-weight: bold;\n  font-size: 1.2rem;\n}\n.root .main.EN_OALD .fayin {\n  display: inline;\n}\n.root .main.EN_OALD .sd {\n  display: block;\n  font-weight: bold;\n  margin-top: 1rem;\n}\n.root .main.EN_OALD .cf {\n  color: #0070c0;\n}\n.root .main.EN_OALD .cf .swung-dash {\n  margin-right: 0.4em;\n}\n.root .main.EN_OALD .cf[display=\"block\"] {\n  display: block;\n}\n.root .main.EN_OALD .pv,\n.root .main.EN_OALD .id {\n  display: block;\n  color: #0070c0;\n  font-weight: bold;\n}\n.root .main.EN_OALD .tx:before {\n  content: '　';\n}\n.root .main.EN_OALD img {\n  border: 0;\n  max-width: 700px;\n}\n.root .main.EN_OALD img.fayin {\n  width: 15px;\n  height: 15px;\n}\n.root .main.EN_OALD img.img {\n  width: 1em;\n  height: 1em;\n  margin-left: -4px;\n  margin-bottom: -2px;\n}\n.root .main.EN_OALD img.Media {\n  clear: both;\n}\n.root .main.EN_OALD .h-g .top-g .h {\n  font-size: 2.5rem;\n  display: block;\n  margin-bottom: 20px;\n}\n.root .main.EN_OALD .id-g {\n  display: inline;\n}\n.root .main.EN_OALD .revout + .id-g,\n.root .main.EN_OALD .z + .pv-g {\n  display: block;\n}\n.root .main.EN_OALD .revout {\n  font-weight: bold;\n  margin-top: 1rem;\n  display: block;\n}\n.root .main.EN_OALD .revout:before {\n  content: \"【\";\n}\n.root .main.EN_OALD .revout:after {\n  content: \"】\";\n}\n.root .main.EN_OALD span.arbd1,\n.root .main.EN_OALD span.dhb,\n.root .main.EN_OALD span.fm,\n.root .main.EN_OALD span.unei,\n.root .main.EN_OALD .ndv,\n.root .main.EN_OALD .cl,\n.root .main.EN_OALD .ei {\n  padding-right: 0.2em;\n}\n.root .main.EN_OALD span.unsyn,\n.root .main.EN_OALD span.unfm,\n.root .main.EN_OALD .eb {\n  padding-right: 0.2em;\n  text-transform: uppercase;\n  font-size: smaller;\n  color: #c76e06;\n}\n.root .main.EN_OALD .ungi,\n.root .main.EN_OALD .gi,\n.root .main.EN_OALD .g {\n  color: #008000;\n  font-style: italic;\n}\n.root .main.EN_OALD .label-g {\n  color: #008000;\n}\n.root .main.EN_OALD .label-g .chn {\n  display: inline;\n}\n.root .main.EN_OALD .label-g .chn:before {\n  content: \"\";\n}\n.root .main.EN_OALD .dr-g {\n  display: block;\n}\n.root .main.EN_OALD .phon-gb,\n.root .main.EN_OALD .phon-us {\n  color: #f00;\n}\n.root .main.EN_OALD .z_phon-us {\n  display: none;\n}\n.root .main.EN_OALD .alt[q=\"also\"] {\n  display: block;\n}\n.root .main.EN_OALD .n-g {\n  display: block;\n  margin-bottom: 2rem;\n}\n.root .main.EN_OALD .x-g {\n  display: block;\n  margin-left: 2em;\n}\n.root .main.EN_OALD .n-g .xr-g {\n  margin-left: 2em;\n}\n.root .main.EN_OALD .xr-g {\n  display: block;\n}\n.root .main.EN_OALD .z_ei-g {\n  display: none;\n}\n.root .main.EN_OALD .sense-g {\n  display: block;\n}\n.root .main.EN_OALD .block-g {\n  display: block;\n}\n.root .main.EN_OALD .ids-g,\n.root .main.EN_OALD .pvs-g {\n  display: block;\n}\n.root .main.EN_OALD .infl {\n  display: block;\n}\n.root .main.EN_OALD .para {\n  display: block;\n}\n.root .main.EN_OALD .wordbox {\n  display: block;\n  margin-left: 18px;\n  margin-right: 18px;\n  padding: 5px 16px;\n  border-radius: 10px;\n  border-color: #c76e06;\n  border-style: ridge;\n  clear: both;\n}\n.root .main.EN_OALD .word {\n  display: table-cell;\n  background-color: #c76e06;\n  color: #fafafa;\n  text-transform: uppercase;\n}\n.root .main.EN_OALD .wfw {\n  display: inline;\n}\n.root .main.EN_OALD .unbox {\n  display: block;\n  padding-left: 2px;\n}\n.root .main.EN_OALD .tab {\n  display: table-cell;\n  background-color: #c76e06;\n  color: #fafafa;\n  text-transform: uppercase;\n  text-align: left;\n}\n.root .main.EN_OALD .title {\n  display: block;\n  text-transform: uppercase;\n  font-size: small;\n}\n.root .main.EN_OALD .table {\n  display: table;\n  margin: 12px 0 8px 0;\n}\n.root .main.EN_OALD .tr {\n  display: table-row;\n}\n.root .main.EN_OALD .td {\n  display: table-cell;\n  margin-right: 10px;\n}\n.root .main.EN_OALD .th {\n  display: table-cell;\n  color: #c76e06;\n  text-transform: uppercase;\n}\n.root .main.EN_OALD .althead {\n  text-transform: uppercase;\n}\n.root .main.EN_OALD .patterns {\n  display: block;\n  clear: both;\n}\n.root .main.EN_OALD .patterns .althead {\n  display: table-cell;\n  margin: 0px auto 0px auto;\n  text-transform: uppercase;\n}\n.root .main.EN_OALD .patterns .para {\n  -ms-word-break: break-all;\n  word-break: break-word;\n  -webkit-hyphens: auto;\n  -moz-hyphens: auto;\n  hyphens: auto;\n}\n.root .main.EN_OALD .help {\n  display: block;\n}\n.root .main.EN_OALD .symbols-coresym {\n  color: #008000;\n  display: inline-block;\n}\n.root .main.EN_OALD .symbols-small_coresym {\n  color: #008000;\n  display: inline-block;\n  font-size: 70%;\n  top: -0.1em;\n  margin-right: 0.15em;\n}\n.root .main.EN_OALD .symbols-xsym {\n  display: none;\n}\n.root .main.EN_OALD .symbols-xrsym {\n  font-style: normal;\n  color: #555;\n  margin-right: 0.25em;\n}\n.root .main.EN_OALD .symbols-helpsym,\n.root .main.EN_OALD .symbols-synsym,\n.root .main.EN_OALD .symbols-awlsym,\n.root .main.EN_OALD .symbols-oppsym,\n.root .main.EN_OALD .symbols-etymsym,\n.root .main.EN_OALD .symbols-notesym {\n  color: #fff;\n  background: #b78032;\n  font-size: 65%;\n  padding: 1px 3px 2px;\n  display: inline-block;\n  margin: 0 0.4em 0 0;\n  text-transform: uppercase;\n  top: -1px;\n  line-height: 1em;\n  border-radius: 1px;\n}\n.root .main.EN_OALD .symbols-oppsym {\n  background: #8b0000;\n}\n.root .main.EN_OALD .symbols-drsym {\n  font-size: 70%;\n  color: #000;\n}\n.root .main.EN_OALD .symbols-para_square {\n  color: #505050;\n  font-size: 65%;\n}\n.root .main.EN_OALD .symbols-synsep {\n  color: #505050;\n  font-size: 65%;\n}\n.root .main.EN_OALD span#wx {\n  text-decoration: line-through;\n}\n.root .main.EN_OALD span#unwx {\n  text-decoration: line-through;\n}\n.root .main.EN_OALD swung-dash {\n  visibility: hidden;\n}\n.root .main.EN_OALD swung-dash::after {\n  visibility: visible;\n  content: \"\007E \0020\";\n}\n.root .main.EN_OALD .pv-g .swung-dash {\n  visibility: hidden;\n}\n.root .main.EN_OALD .pv-g .swung-dash::after {\n  visibility: visible;\n  content: \"\007E \0020\";\n}\n.root .main.EN_OALD .z_n {\n  display: none;\n}\n.root .main.EN_OALD .symbols-small_coresym {\n  display: none;\n}\n.root .main.EN_OALD .z_ab {\n  color: #008000;\n}\n.root .main.EN_OALD .gr,\n.root .main.EN_OALD .subject {\n  color: #008000;\n}\n.root .main.EN_OALD .dr {\n  color: #00f;\n}\n.root .main.EN_OALD #cigencizui-content .word {\n  display: unset;\n  background-color: unset;\n  color: unset;\n  text-transform: unset;\n}\n</style></head>\n<body>\n    <div class=\"root\">\n      <div class=\"desktop\">\n        <div class=\"main EN_OALD\" tabindex=\"3\" style=\"border-top-color: rgb(102, 102, 102); border-right-color: rgb(102, 102, 102); border-bottom-color: rgb(102, 102, 102);\">\n   "
    
    let html_second_half = "\n        </div>\n      </div>\n    </div>\n</body></html>"
    override func viewDidLoad() {
        super.viewDidLoad()
        loadHTML()
//        self.webView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }
    func loadHTML(){
        initActivityIndicator(text: "获取单词中..")
        
        let connected = Reachability.isConnectedToNetwork()
        if connected{
            DispatchQueue.global(qos: .background).async {
            do {
                let query = LCQuery(className: "OALECD8")
                query.whereKey("word_id" , .equalTo(self.wordIndex))
                _ = query.getFirst { result in
                    switch result {
                    case .success(object: let word):
                        if var html_content = word.get("html_content")?.stringValue
                        {
                            html_content = html_content.replacingOccurrences(of: self.en_prounce, with: "英")
                            html_content = html_content.replacingOccurrences(of: self.us_prounce, with: "美")
                            let html_final = "\(self.html_first_half)\(html_content)\(self.html_second_half)"
                            self.webView.loadHTMLString(html_final, baseURL: nil)
                            self.stopIndicator()
                        }else{
                            self.stopIndicator()
                            self.dismiss(animated: true, completion: nil)
                        }
                        break
                    case .failure(error: let error):
                        print(error)
                    }
                }
                }}
        }else{
            if non_network_preseted == false{
                let alertCtl = presentNoNetworkAlert()
                self.present(alertCtl, animated: true, completion: nil)
                non_network_preseted = true
            }
        }
    }
}
