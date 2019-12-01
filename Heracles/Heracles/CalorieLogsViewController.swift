//
//  CalorieLogsViewController.swift
//  Heracles
//
//  Created by Ethan Chiang on 11/27/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import ScrollableGraphView

class CalorieLogsViewController: UIViewController, ScrollableGraphViewDataSource {
    
    @IBOutlet weak var calorieScrollableGraphView: ScrollableGraphView!
    @IBOutlet weak var calorieGoalLabel: UILabel!
    
    
    // MARK: Notification
    @objc func reloadPage(_ notification: Notification) {
        self.loadPage()
        
        // TODO: stop activity indicator
    }
       
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        calorieScrollableGraphView.dataSource = self
        
        // recieving notification to reload graph
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPage(_:)), name: Notification.Name(rawValue: "reloadPage"), object: nil)
        
        if isDataLoaded {
            self.loadPage()
        }
        
        // TODO: start activity indicator

    }
    
    
    // MARK: ScrollableGraphView
    
    private func loadPage() {
        
        self.calorieGoalLabel.text = calorieGoal
        
        self.calorieScrollableGraphView.shouldAnimateOnStartup = true
        
        // grpah visual settings
        //self.calorieScrollableGraphView.shouldAdaptRange = true
        self.calorieScrollableGraphView.rangeMax = 3000
        self.calorieScrollableGraphView.rangeMin = 1000
        
        
        
        let linePlot = LinePlot(identifier: "line") // Identifier should be unique for each plot.
        let referenceLines = ReferenceLines()
        
        //print("\(dates.count) : \(weightsLogs.count)")

        self.calorieScrollableGraphView.addPlot(plot: linePlot)
        self.calorieScrollableGraphView.addReferenceLines(referenceLines: referenceLines)
        
        self.calorieScrollableGraphView.reload()
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        return calorieLogs[pointIndex]
    }

    func label(atIndex pointIndex: Int) -> String {
        return dates[pointIndex]
        //return self.labels[pointIndex]
    }

    func numberOfPoints() -> Int {
        return dates.count
    }
    
    
    // MARK: back button
    @IBAction func backPress() {
        
        self.dismiss(animated: true) {
                   return
        }
    }
}
