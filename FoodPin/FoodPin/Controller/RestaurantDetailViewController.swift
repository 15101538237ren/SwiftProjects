//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by 任红雷 on 3/25/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class RestaurantDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: RestaurantDetailHeaderView!
    
    @IBAction func close(segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    func annimation_handler(rating: String){
        self.headerView.ratingImageView.image = UIImage(named: rating)
        let scaleTransform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
        self.headerView.ratingImageView.transform = scaleTransform
        self.headerView.ratingImageView.alpha = 0

            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.2, options: [], animations: {
            self.headerView.ratingImageView.transform = .identity
            self.headerView.ratingImageView.alpha = 1
            }, completion: nil)
    }
    @IBAction func rateRestaurant(segue: UIStoryboardSegue){
        dismiss(animated: true, completion:     {
            if let rating = segue.identifier {
                self.restaurant.rating = rating
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate){
                    appDelegate.saveContext()
                }
                self.annimation_handler(rating: rating)
            }
        })
    }
    var restaurant: RestaurantMO!
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure header view
        if let rating = restaurant.rating{
            headerView.ratingImageView.image = UIImage(named: rating)
        }
        
        headerView.nameLabel.text = restaurant.name
        headerView.typeLabel.text = restaurant.type
        if let restaurantImage = restaurant.image {
            headerView.headerImageView.image = UIImage(data: restaurantImage as Data)
        }
        
        headerView.heartImageView.isHidden = (restaurant.isVisited) ? false : true
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = .white
        tableView.contentInsetAdjustmentBehavior = .never
        if let rating:String = restaurant.rating{
            self.annimation_handler(rating: rating)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {

        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailIconTextCell.self), for: indexPath) as! RestaurantDetailIconTextCell
            cell.iconImageView.image = UIImage(systemName: "phone")?.withTintColor(.black, renderingMode: .alwaysOriginal)
            cell.shortTextLabel.text = restaurant.phone
            cell.selectionStyle = .none

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailIconTextCell.self), for: indexPath) as! RestaurantDetailIconTextCell
            cell.iconImageView.image = UIImage(systemName: "map")?.withTintColor(.black, renderingMode: .alwaysOriginal)
            cell.shortTextLabel.text = restaurant.location
            cell.selectionStyle = .none

            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailTextCell.self), for: indexPath) as! RestaurantDetailTextCell
            cell.descriptionLabel.text = restaurant.summary
            cell.selectionStyle = .none

            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailSeparatorCell.self), for: indexPath) as! RestaurantDetailSeparatorCell
            cell.titleLabel.text = "HOW TO GET HERE"
            cell.selectionStyle = .none
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailMapCell.self), for: indexPath) as! RestaurantDetailMapCell
            cell.selectionStyle = .none
            if let restaurantLocation = restaurant.location {
                cell.configure(location: restaurantLocation)
            }
            return cell
        default:
            fatalError("Failed to instantiate the table view cell for detail view controller")
            }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap"{
            let destinationController = segue.destination as! MapViewController
            destinationController.restaurant = restaurant
        } else if segue.identifier == "showReview" {
            let destinationController = segue.destination as! ReviewViewController
            destinationController.restaurant = restaurant
        }
    }
    
    
}
