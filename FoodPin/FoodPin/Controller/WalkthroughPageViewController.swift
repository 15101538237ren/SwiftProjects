//
//  WalkthroughPageViewController.swift
//  FoodPin
//
//  Created by 任红雷 on 4/2/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

protocol WalkthroughPageViewControllerDelegate: class {
    func didUpdatePageIndex(currentIndex: Int)
}

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    weak var walkthroughDelegate: WalkthroughPageViewControllerDelegate?
    
    var pageHeadings = [NSLocalizedString("CREATE YOUR OWN FOOD GUIDE", comment: "CREATE YOUR OWN FOOD GUIDE") , NSLocalizedString("SHOW YOU THE LOCATION", comment: "SHOW YOU THE LOCATION") , NSLocalizedString("DISCOVER GREAT RESTAURANTS", comment: "DISCOVER GREAT RESTAURANTS")]
    var pageSubHeadings = [
        NSLocalizedString("Pin your favorite restaurants and create your own food guide", comment: "Pin your favorite restaurants and create your own food guide"),
        NSLocalizedString("Search and locate your favourite restaurant on Maps", comment: "Search and locate your favourite restaurant on Maps"),
        NSLocalizedString("Find restaurants shared by your friends and other foodies", comment: "Find restaurants shared by your friends and other foodies")]
    
    var pageImages = ["onboarding-1", "onboarding-2", "onboarding-3"]
    
    var currentIndex = 0
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = currentIndex - 1
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = currentIndex + 1
        return contentViewController(at: index)
    }
    
    func contentViewController(at index:Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= pageHeadings.count{
            return nil
        }
        let storyBoard = UIStoryboard(name: "Onboarding", bundle: nil)
        
        if let pageContentViewController = storyBoard.instantiateViewController(identifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.subHeading = pageSubHeadings[index]
            return pageContentViewController
        }
        return nil
    }
    
    func forwardPage() {
        currentIndex += 1
        if let nextViewController = contentViewController(at: currentIndex) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if completed {
            
            currentIndex += 1
            if let contentViewController = contentViewController(at: currentIndex) {
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            }

        }
    }

}
