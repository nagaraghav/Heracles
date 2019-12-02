//
//  PageViewController.swift
//  Heracles
//
//  Created by Ethan Chiang on 11/18/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FBSDKLoginKit

var weightGoal: String = ""
var calorieGoal: String = ""
var workoutGoal: String = ""
var dates: [String] = []
var weightsLogs: [Double] = []
var calorieLogs: [Double] = []
var workoutLogs: [Double] = []

class PageViewController: UIPageViewController,UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private lazy var VCs: [UIViewController] = {
        return [self.VCInstance(name: "CALORIE"),
                self.VCInstance(name: "WEIGHT"),
                self.VCInstance(name: "WORKOUT")]
    }()
    
    
    private func VCInstance(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    public var clientID : String = ""
    private var ref: DatabaseReference!
    let dispatchGroup = DispatchGroup()
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("At PageViewController!")

        self.dataSource = self
        self.delegate = self
        
        
        self.getData()
        
        
        // Set first page
        if let calorieVC = self.VCs.first {
            self.setViewControllers([calorieVC], direction: .forward, animated: true, completion: nil)
        }
        
       
        
    }
    
    // MARK: UIPageControl
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            }
            else if view is UIPageControl {
                view.backgroundColor = UIColor.lightGray
                view.frame.size.width = 60
                view.frame.size.height = 30
                view.center = CGPoint(x: self.view.frame.size.width  / 2,
                                      y: self.view.frame.size.height - 40)
                view.layer.cornerRadius = 10
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
    
    // MARK: getData
    private func getData(){
     
        
        ref = Database.database().reference()
        self.ref.child("user").child(self.clientID).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                
                // MARK: get goals
                weightGoal = value?["weightGoal"] as? String ?? ""
                calorieGoal = value?["calorieGoal"] as? String ?? ""
                workoutGoal = value?["workoutGoal"] as? String ?? ""
            
                // MARK: get logs
                let logs = value?["logs"] as? NSDictionary
                
                var logDates = logs?.allKeys as? [String]
                logDates = logDates?.sorted()
                
                logDates?.forEach { date in
                    let log = logs?[date] as? NSDictionary
                    
                    // There should be dates to cast as string, or else database is broken
                    let date = Array(date)
                    dates.append("\(date[3])\(date[4])/\(date[0])\(date[1])")
                    
                    let categories = log?.allKeys
                    
                    categories?.forEach { category in
                        if let category = category as? String {
                            if category == "weight" {
                                // There should always be data to cast as Double
                                let val_log = log?[category] as? String
                                if let val = val_log {
                                    
                                    weightsLogs.append(Double(val)!)
                                }
                            }
                            if category == "calorie" {
                                let val_log = log?[category] as? String
                                if let val = val_log {
                                    calorieLogs.append(Double(val)!)
                                }
                            }
                            if category == "workout" {
                                let val_log = log?[category] as? String
                                if let val = val_log {
                                    workoutLogs.append(Double(val)!)
                                }
                            }
                            //print("working")
                        }
                    }
                }
            
            
                // MARK: notification
                NotificationCenter.default.post(name: Notification.Name(rawValue: "dataLoaded"), object: nil)
                
                
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
