//
//  WeightLogsViewController.swift
//  Heracles
//
//  Created by Ethan Chiang on 11/17/19.
// 
//

import UIKit
import ScrollableGraphView
import FirebaseDatabase
import FirebaseAuth

class WorkourLogsViewController: UIViewController, ScrollableGraphViewDataSource {
    
    @IBOutlet weak var workoutScrollableGraphView: ScrollableGraphView!
    @IBOutlet weak var workoutGoalLabel: UILabel!
    
    private var ref: DatabaseReference!
    
    // MARK: Notification
    @objc func disconnectPaxiSocket(_ notification: Notification) {
        self.loadPage()
        
        // TODO: stop activity indicator
    }
       
    
     // MARK: viewWillAppear
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(true)
        
        workoutScrollableGraphView.dataSource = self
        
        // recieving notification to reload graph
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectPaxiSocket(_:)), name: Notification.Name(rawValue: "disconnectPaxiSockets"), object: nil)
        
        self.loadPage()
        
        // TODO: start activity indicator

    }
    
    
    // MARK: ScrollableGraphView
    
    private func loadPage() {
        
        self.workoutGoalLabel.text = workoutGoal
        
        // grpah visual settings
        self.workoutScrollableGraphView.shouldAdaptRange = true
        
        
        // Setup the plot
        let barPlot = BarPlot(identifier: "bar")
        let referenceLines = ReferenceLines()


        barPlot.barWidth = 25
        barPlot.barLineWidth = 1
        barPlot.barLineColor = UIColor.lightGray
        barPlot.barColor = UIColor.gray
        barPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        barPlot.animationDuration = 1.5
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        self.workoutScrollableGraphView.backgroundFillColor = UIColor.darkGray
        self.workoutScrollableGraphView.shouldAnimateOnStartup = true

        self.workoutScrollableGraphView.addPlot(plot: barPlot)
        self.workoutScrollableGraphView.addReferenceLines(referenceLines: referenceLines)
        
        self.workoutScrollableGraphView.reload()
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        return workoutLogs[pointIndex]
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
