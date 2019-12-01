//
//  WeightLogsViewController.swift
//  Heracles
//
//  Created by Ethan Chiang on 11/19/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import ScrollableGraphView
import FirebaseDatabase
import FirebaseAuth

class WeightLogsViewController: UIViewController, ScrollableGraphViewDataSource {
    
    @IBOutlet weak var weightsScrollableGraphView: ScrollableGraphView!
    @IBOutlet weak var weightGoalLabel: UILabel!
    
    private var ref: DatabaseReference!
    
    // MARK: Notification
    @objc func reloadPage(_ notification: Notification) {
        self.loadPage()
        
        // TODO: stop activity indicator
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // set up notificationCenter observer
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPage(_:)), name: Notification.Name(rawValue: "reloadPage"), object: nil)
        weightsScrollableGraphView.dataSource = self
        
        if isDataLoaded {
            self.loadPage()
        }
        
        
        // TODO: start activity indicator

    }
    
    
    // MARK: loadPage
    
    private func loadPage() {
        
        self.weightGoalLabel.text = weightGoal
        
        // grpah visual settings
        
        let linePlot = LinePlot(identifier: "darkLine")
        let referenceLines = ReferenceLines()
        
        linePlot.lineWidth = 1
        linePlot.lineColor = UIColor.lightGray
        linePlot.lineStyle = ScrollableGraphViewLineStyle.smooth

        linePlot.shouldFill = true
        linePlot.fillType = ScrollableGraphViewFillType.gradient
        linePlot.fillGradientType = ScrollableGraphViewGradientType.linear
        linePlot.fillGradientStartColor = UIColor.gray
        linePlot.fillGradientEndColor = UIColor.lightGray
        linePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        let dotPlot = DotPlot(identifier: "darkLineDot") // Add dots as well.
        dotPlot.dataPointSize = 2
        dotPlot.dataPointFillColor = UIColor.white
        dotPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        
        
        
        self.weightsScrollableGraphView.backgroundFillColor = UIColor.darkGray
        self.weightsScrollableGraphView.shouldAnimateOnStartup = true

        self.weightsScrollableGraphView.rangeMax = 300
        self.weightsScrollableGraphView.rangeMin = 100
        self.weightsScrollableGraphView.addReferenceLines(referenceLines: referenceLines)
        self.weightsScrollableGraphView.addPlot(plot: linePlot)
        self.weightsScrollableGraphView.addPlot(plot: dotPlot)
        self.weightsScrollableGraphView.addReferenceLines(referenceLines: referenceLines)
        
        self.weightsScrollableGraphView.reload()
    }
    
    // MARK: ScrollableGraphView
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        // Return the data for each plot.
        return weightsLogs[pointIndex]
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
