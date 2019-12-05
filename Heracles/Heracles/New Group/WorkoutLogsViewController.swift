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

class WorkoutLogsViewController: UIViewController, ScrollableGraphViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var workoutScrollableGraphView: ScrollableGraphView!

    @IBOutlet weak var workoutGoalLabel: UITextField!
    
    private var ref: DatabaseReference!
    private var isFirstLoad = true
    
    // MARK: Notification
    @objc func dataLoaded(_ notification: Notification) {
        self.workoutScrollableGraphView.reload()
    }
       
     // MARK: viewWillAppear
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        workoutGoalLabel.delegate = self
        workoutScrollableGraphView.dataSource = self
        
        ref = Database.database().reference()
        // recieving notification to reload graph
        NotificationCenter.default.addObserver(self, selector: #selector(dataLoaded(_:)), name: Notification.Name(rawValue: "dataLoaded"), object: nil)
        
        if self.isFirstLoad {
            self.workoutGoalLabel.text = workoutGoal
            self.loadGraphSetup()
            self.isFirstLoad = false
            self.workoutScrollableGraphView.reload()
        }
    }
    
    func updateWorkoutGoal(newWorkoutGoal: String) {
         ref.child("user").child(logClient).child("workoutGoal").setValue(newWorkoutGoal)
     }
     
    /*
     When 'return' is pressed within a textbox, update goal
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
     
     guard let newWorkout = textField.text else {
         return true
     }
     
        updateWorkoutGoal(newWorkoutGoal: newWorkout)
        return true
    }
    
    //added UITapGestureRecognizer to View through interface builder
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }

     // MARK: setGoal
     func setGoal(){
         self.ref.child("user").child(logClient).child("workoutGoal").observeSingleEvent(of: .value, with: { (snapshot) in
             let value = snapshot.value
             if let goal = value as? String {
                 self.workoutGoalLabel.text = goal
             }
          }){ (error) in
              print(error.localizedDescription)
          }
     }
    
    // MARK: loafGraphSetup
    private func loadGraphSetup() {
        
        self.workoutScrollableGraphView.rangeMin = 0
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
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        if pointIndex >= workoutLogs.count {
            return 0.0
        }
        
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
