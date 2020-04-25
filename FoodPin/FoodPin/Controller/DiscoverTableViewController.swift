//
//  DiscoverTableViewController.swift
//  FoodPin
//
//  Created by 任红雷 on 4/12/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {
    
    var restaurants:[CKRecord] = []
    var spinner = UIActivityIndicatorView()
    private var imageCache = NSCache<CKRecord.ID, NSURL>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = .white
        refreshControl?.tintColor = .gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: UIControl.Event.valueChanged)
        spinner.style = .medium
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        //Define layout constraints for the spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200.0), spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        spinner.startAnimating()
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.tableFooterView = UIView()
        
        let navigationBar = navigationController?.navigationBar
        
        navigationBar?.prefersLargeTitles = true
        
        navigationBar?.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor(red: 231, green: 76, blue: 60, alpha: 1.0)]
        fetchRecordsFromCloud()
    }
    
    @objc func fetchRecordsFromCloud(){
        restaurants.removeAll()
        tableView.reloadData()
        
        //Fetch data using Convienence API
        let cloudContainer = CKContainer.init(identifier: "iCloud.iClould.com.Honglei.FoodPinDB")
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let queryOperation = CKQueryOperation(query: query)
            queryOperation.desiredKeys = ["name", "type", "location", "phone",  "description"]
            queryOperation.queuePriority = .veryHigh
            queryOperation.resultsLimit = 50
            queryOperation.recordFetchedBlock = { (record) -> Void in
                self.restaurants.append(record)
            }

            queryOperation.queryCompletionBlock = { [unowned self] (cursor, error) -> Void in
                if let error = error {
                    print("Failed to get data from iCloud - \(error.localizedDescription)")
                    return
                }
                
                print("Successfully retrieve the data from iCloud")
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.tableView.reloadData()
                    if let refreshControl = self.refreshControl {
                        if refreshControl.isRefreshing{
                            refreshControl.endRefreshing()
                        }
                    }
                }
            }

            // Execute the query
            publicDatabase.add(queryOperation)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath) as! DiscoverTableViewCell

        let restaurant = restaurants[indexPath.row]
        cell.nameLabel.text = restaurant.object(forKey: "name") as? String
        cell.typeLabel.text = restaurant.object(forKey: "type") as? String
        cell.locationLabel.text = restaurant.object(forKey: "location") as? String
        cell.phoneLabel.text = restaurant.object(forKey: "phone") as? String
        cell.descriptionLabel.text = restaurant.object(forKey: "description") as? String
        cell.thumbnailImageView.image = UIImage(named: "photo")
        
        if let imageFileURL = imageCache.object(forKey: restaurant.recordID) {
            print("Get image from cache")
            
            if let imageData = try? Data.init(contentsOf: imageFileURL as URL) {
                cell.thumbnailImageView.image = UIImage(data: imageData)
            }
        } else{
            let cloudContainer = CKContainer.init(identifier: "iCloud.iClould.com.Honglei.FoodPinDB")
            let publicDatabase = cloudContainer.publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .veryHigh
            
            fetchRecordsImageOperation.perRecordCompletionBlock = {
                    (record, recordID, error) -> Void in
                    if let error = error {
                        print("Failed to get restaurant image: \(error.localizedDescription)")
                        return
                    }

                    if let restaurantRecord = record,
                        let image = restaurantRecord.object(forKey: "image"),
                        let imageAsset = image as? CKAsset {

                        if let imageData = try? Data.init(contentsOf: imageAsset.fileURL!) {

                            // Replace the placeholder image with the restaurant image
                            DispatchQueue.main.async {
                                cell.thumbnailImageView.image = UIImage(data:imageData)
                                cell.setNeedsLayout()
                            }
                            self.imageCache.setObject(imageAsset.fileURL! as NSURL, forKey: restaurant.recordID)
                        }
                    }
                }
            publicDatabase.add(fetchRecordsImageOperation)
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
