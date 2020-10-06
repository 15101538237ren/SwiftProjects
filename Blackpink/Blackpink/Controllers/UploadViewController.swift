//
//  UploadViewController.swift
//  Blackpink
//
//  Created by Honglei on 10/5/20.
//

import UIKit

class UploadViewController: UIViewController {
    
    @IBOutlet var imgV: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func unwind(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
