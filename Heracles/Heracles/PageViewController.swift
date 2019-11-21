//
//  PageViewController.swift
//  Heracles
//
//  Created by Ethan Chiang on 11/18/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController,UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private lazy var VCs: [UIViewController] = {
        return [self.VCInstance(name: "WEIGHT"),
                self.VCInstance(name: "CALORIE"),
                self.VCInstance(name: "WORKOUT")]
    }()
    
    private func VCInstance(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        // Set first page
        if let weightVC = self.VCs.first {
            self.setViewControllers([weightVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            }
            else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    // MARK: pageVC data source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = VCs.firstIndex(of: viewController) else {
            print("VC index out of bound")
            return nil
        }
        
        let prevIndex = viewControllerIndex - 1
        
        guard prevIndex >= 0 else {
            return VCs.last
        }
        
        guard VCs.count > prevIndex else {
            return nil
        }
        
        return VCs[prevIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = VCs.firstIndex(of: viewController) else {
                   print("VC index out of bound")
                   return nil
               }
               
               let nextIndex = viewControllerIndex + 1
               
        guard nextIndex < VCs.count else {
                   return VCs.first
               }
               
               guard VCs.count > nextIndex else {
                   return nil
               }
               
               return VCs[nextIndex]
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return VCs.count
    }
    

    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstVC = viewControllers?.first, let firstVCIndex = VCs.firstIndex(of: firstVC) else {
            return 0
        }
        
        return firstVCIndex
    }
}
