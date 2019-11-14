# Milestone 1

## Mockups
Balsamiq sketches https://github.com/ECS189E/project-f19-team/blob/master/Mockups/Mockups-11:112019.pdf

## Third party libraries/APIs
* Facebook SDK - for logging in a user
* Firebase - authentication and storing user information
* https://github.com/philackm/ScrollableGraphView - for visualization of logs
* https://github.com/MxABC/swiftScan - to scan QR codes and allow trainers to add clients


## Models
User  
> --Account_type : String 
  --clientID : String  
  --firstName : String  
  --lastName : String  
  --Height : Int (inches)  
  --calorieGoal : Int  
  --proteinGoal : Int  
  --sleepGoal : float  
  --weightGoal : Int  
  --workoutGoal : Int  
  --Logs  
 >> -- logs {key = date, value = entry for each of the fields -> “calorie = 1500”}  
 << --clientList (only for trainer)  
 >>   --List of clients for a specific trainer  

## ViewControllers
* Login
* Client Home
* Trainer Home
* Add Client
* Client QR Code 
* Client Info Page
* Settings page
* Calendar page
* Specific category page
