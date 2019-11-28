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

class WeightLogsViewController: UIViewController, ScrollableGraphViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var weightsScrollableGraphView: ScrollableGraphView!
    @IBOutlet weak var weightGoalLabel: UITextField!
    
    private var ref: DatabaseReference!
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        ref = Database.database().reference()
        
        weightGoalLabel.delegate = self
        weightsScrollableGraphView.dataSource = self
        
        // recieving notification to reload graph
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectPaxiSocket(_:)), name: Notification.Name(rawValue: "disconnectPaxiSockets"), object: nil)
        
        self.loadPage()
        
        // TODO: start activity indicator

    }
    
    // MARK: Notification
    @objc func disconnectPaxiSocket(_ notification: Notification) {
        self.loadPage()
        
        // TODO: stop activity indicator
    }
    
    func updateWeightGoal(newWeightGoal: String) {

        ref.child("user").child(logClient).child("weightGoal").setValue(newWeightGoal)
    }
    
   /*
    When 'return' is pressed within a textbox, update weight goal
    */
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       hideKeyboard()
    
    guard let newWeight = textField.text else {
        return true
    }
    
       updateWeightGoal(newWeightGoal: newWeight)
       return true
   }
   
   //added UITapGestureRecognizer to View through interface builder
   @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
       hideKeyboard()
   }
   
   @objc func hideKeyboard(){
       view.endEditing(true)
   }

    // MARK: ScrollableGraphView
    
    func setGoal(){
        self.ref.child("user").child(logClient).child("weightGoal").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value
            if let goal = value as? String {
                self.weightGoalLabel.text = goal
            }
         }){ (error) in
             print(error.localizedDescription)
         }
    }
    
    private func loadPage() {
        
        setGoal()
        // grpah visual settings
        self.weightsScrollableGraphView.shouldAdaptRange = true
        
        self.weightsScrollableGraphView.reload()
        
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

        self.weightsScrollableGraphView.addReferenceLines(referenceLines: referenceLines)
        self.weightsScrollableGraphView.addPlot(plot: linePlot)
        self.weightsScrollableGraphView.addPlot(plot: dotPlot)
        self.weightsScrollableGraphView.addReferenceLines(referenceLines: referenceLines)
    }
    
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
