//
//  WeightLogsViewController.swift
//  Heracles
//
//  Created by Ethan Chiang on 11/19/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import ScrollableGraphView


class WeightLogsViewController: UIViewController, ScrollableGraphViewDataSource {
    
    @IBOutlet weak var weightsScrollableGraphView: ScrollableGraphView!
    
    private var prevVC : String = "trainer"
    
    let linePlotData : [Double] = [5,6,7,8,9,1,2,3,4,10,22,50]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.pageControl.backgroundColor = UIColor.clear
//        self.pageControl.currentPageIndicatorTintColor = UIColor.darkGray
//        self.pageControl.pageIndicatorTintColor = UIColor.gray
        
        weightsScrollableGraphView.dataSource = self
        
//        
        self.createGraph()
    }
    
    
    // MARK: ScrollableGraphView
    
    func createGraph() {
        
        let linePlot = LinePlot(identifier: "line") // Identifier should be unique for each plot.
        let referenceLines = ReferenceLines()

        self.weightsScrollableGraphView.addPlot(plot: linePlot)
    self.weightsScrollableGraphView.addReferenceLines(referenceLines: referenceLines)
        
        
        print("plot")
        //self.view.addSubview(graphView)
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        // Return the data for each plot.
        switch(plot.identifier) {
        case "line":
            return self.linePlotData[pointIndex]
        default:
            return 0
        }
    }

    func label(atIndex pointIndex: Int) -> String {
        return "FEB \(pointIndex)"
    }

    func numberOfPoints() -> Int {
        return self.linePlotData.count
    }
    
    
    // MARK: back button
    
    @IBAction func backPress() {
        
        self.dismiss(animated: true) {
                   return
        }
    }
    
}
