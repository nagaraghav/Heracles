//
//  CalorieLogsViewController.swift
//  Heracles
//
//  Created by Ethan Chiang on 11/27/19.
//  Copyright © 2019 Shivam Desai. All rights reserved.
//

import UIKit
import ScrollableGraphView
import FirebaseDatabase

class CalorieLogsViewController: UIViewController, ScrollableGraphViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var calorieScrollableGraphView: ScrollableGraphView!
    
    
    @IBOutlet weak var calorieGoalLabel: UITextField!
    
    private var ref: DatabaseReference!
    
    // MARK: Notification
    @objc func disconnectPaxiSocket(_ notification: Notification) {
        self.loadPage()
        
        // TODO: stop activity indicator
    }
    
    // MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        calorieGoalLabel.delegate = self
        
        ref = Database.database().reference()
        calorieScrollableGraphView.dataSource = self
        
        // recieving notification to reload graph
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectPaxiSocket(_:)), name: Notification.Name(rawValue: "disconnectPaxiSockets"), object: nil)
        
        self.loadPage()
        
        // TODO: start activity indicator
        
    }
    
    func updateCalorieGoal(newCalorieGoal: String) {
        
        ref.child("user").child(logClient).child("calorieGoal").setValue(newCalorieGoal)
    }
    
    /*
     When 'return' is pressed within a textbox, update weight goal
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        
        guard let newCalorie = textField.text else {
            return true
        }
        
        updateCalorieGoal(newCalorieGoal: newCalorie)
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
        self.ref.child("user").child(logClient).child("calorieGoal").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value
            if let goal = value as? String {
                self.calorieGoalLabel.text = goal
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    // MARK: ScrollableGraphView
    
    private func loadPage() {
        
        setGoal()
        
        self.calorieScrollableGraphView.shouldAnimateOnStartup = true
        
        // grpah visual settings
        //self.calorieScrollableGraphView.shouldAdaptRange = true
        self.calorieScrollableGraphView.rangeMax = 3000
        self.calorieScrollableGraphView.rangeMin = 0
        
        
        
        
        //print("\(dates.count) : \(weightsLogs.count)")
        
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
        self.calorieScrollableGraphView.backgroundFillColor = UIColor.darkGray
        self.calorieScrollableGraphView.shouldAnimateOnStartup = true
        
        
        
        
        self.calorieScrollableGraphView.addPlot(plot: linePlot)
        self.calorieScrollableGraphView.addPlot(plot: dotPlot)
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
