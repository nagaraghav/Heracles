# Milestone 1

## Mockups
Balsamiq sketches https://github.com/ECS189E/project-f19-team/blob/master/Mockups/Mockups-11:112019.pdf

## Third party libraries/APIs
* Facebook SDK - for logging in a user
* Firebase - authentication and storing user information
* https://github.com/philackm/ScrollableGraphView - for visualization of logs
* https://github.com/MxABC/swiftScan - to scan QR codes and allow trainers to add clients


## Models
Client 
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
 
Trainer  
> --same as client (withpout logs)
  --clientList (only for trainer)  
 >> --List of clients for a specific trainer  

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

## Trello Board
https://trello.com/ethanyichiang/boards

## Link to project home page
https://github.com/ECS189E/project-f19-team

## Testing Plan
* Ask local trainers to use the app and get feedback
* Ask friend, classmate, relative to try the app and get user feedback
