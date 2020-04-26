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
    
    @IBAction func close(segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
//        if let user = LCApplication.default.currentUser {
//            // 跳到首页
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let mainPanelViewController = storyBoard.instantiateViewController(withIdentifier: "mainPanelViewController") as! MainPanelViewController
//
//            DispatchQueue.main.async {
//                self.present(mainPanelViewController, animated: true, completion: nil)
//            }
//        }
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {

        let card = sender.view! as! CardUIView
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        
        let alpha = max(1.5 * (abs(xFromCenter) / view.center.x), 1.0)
        
        let scale = min(0.35 * view.frame.width / abs(xFromCenter), 1.0)
        card.transform = CGAffineTransform(rotationAngle: 0.61 * xFromCenter / view.center.x).scaledBy(x: scale, y: scale)
        if xFromCenter > 0
        {
            card.rememberImageView.image = UIImage(named: "bushou")
        }
        else
        {
            card.rememberImageView.image = UIImage(named: "huile")
        }
        card.rememberImageView.alpha = alpha
        
        
        if sender.state == UIGestureRecognizer.State.ended
        {
            if card.center.x < (0.25 * view.frame.width)
            {
                UIView.animate(withDuration: 0.3, animations:
                {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                })
                return
            }
            else if card.center.x > (0.75 * view.frame.width)
            {
                UIView.animate(withDuration: 0.3, animations:
                {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                })
                return
            }
            resetCard()
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        resetCard()
    }
    
    func resetCard()
    {
        UIView.animate(withDuration: 0.2, animations:
        {
            self.card.center = self.view.center
            self.card.alpha = 1
        })
        self.card.rememberImageView.alpha = 0
        card.transform = .identity
    }
}

