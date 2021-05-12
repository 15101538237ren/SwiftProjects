//
//  PolicyVC.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/18/20.
//

import UIKit
import WebKit

class PolicyVC: UIViewController {
    @IBOutlet var webView: WKWebView!
    var url: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.theme_backgroundColor = "View.BackgroundColor"
        webView.theme_backgroundColor = "View.BackgroundColor"
        initVC()
    }
    func initVC() {
        if !Reachability.isConnectedToNetwork(){
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?){
        if traitCollection.userInterfaceStyle == .light {
            setTheme(theme: .day)
        } else {
            setTheme(theme: .night)
        }
    }
}
