//
//  MenuViewController.swift
//  Blackpink
//
//  Created by Honglei on 10/5/20.
//

import UIKit
import MessageUI

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let menuItems:[MenuItem] = [
        MenuItem(icon_name: "upload", name: UploadBtnTxt),
        MenuItem(icon_name: "heart-fill-icon", name: LikedTxt),
        MenuItem(icon_name: "like", name: RateUsTxt),
        MenuItem(icon_name: "feedback", name: FeedBackTxt),
    ]
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        view.isOpaque = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItemCell", for: indexPath) as! MenuItemTableViewCell
        cell.backgroundColor = .clear
        let menuItem:MenuItem = menuItems[row]
        cell.iconImgV?.image = menuItem.icon
        cell.nameLabel?.text = menuItem.name
        return cell
        
    }
    
    func loadLikedVC(){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let likedVC = mainStoryBoard.instantiateViewController(withIdentifier: "likedVC") as! LikedViewController
        
        let transition = getTransitionFromRight()
        view.window!.layer.add(transition, forKey: kCATransition)
        likedVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(likedVC, animated: false, completion: nil)
        }
    }
    
    func loadUploadVC(){
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let uploadVC = mainStoryBoard.instantiateViewController(withIdentifier: "uploadVC") as! UploadViewController
        
        let transition = getTransitionFromRight()
        view.window!.layer.add(transition, forKey: kCATransition)
        uploadVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(uploadVC, animated: false, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            loadUploadVC()
        case 1:
            loadLikedVC()
        case 3:
            showFeedBackMailComposer()
        default:
            break
        }
    }
    
    func showFeedBackMailComposer(){
        guard MFMailComposeViewController.canSendMail() else{
            let ac = UIAlertController(title: SendFailedTxt, message: SendFailedMsg, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: OKMsg, style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["blackpink_wp@outlook.com"])
        composer.setSubject(EmailTheme)
        composer.setMessageBody("", isHTML: false)
        present(composer, animated: true)
    }

}

extension MenuViewController : MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true, completion: nil)
        }
        var feedback_sent = false
        switch result {
        case .cancelled:
            print("User Canceled")
        case .failed:
            print("Send Failed")
        case .saved:
            print("Draft Saved")
        case .sent:
            print("Send Successful!")
            feedback_sent = true
        default:
            print("")
        }
        controller.dismiss(animated: true, completion: {
            if feedback_sent == true{
                let ac = UIAlertController(title: SendSuccessTxt, message: SendSuccessMsg, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: OKMsg, style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
        })
    }
}

