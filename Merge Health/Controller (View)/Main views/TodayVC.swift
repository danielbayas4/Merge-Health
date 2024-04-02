

import UIKit
import HealthKit

class TodayVC: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    let healthStore = HKHealthStore()
    
    
    
    var quantityMetrics: [QuantityMetric] = [RestingHeartRateM.shared, HeartRateVariability.shared, RespiratoryRate.shared, Steps.shared, WalkingRunningDistance.shared]

    
     override func viewDidLoad() {
         //the table is loaded at the initial load, so it does not know about the modification of the variables that populates it
         super.viewDidLoad()
         
         
         
         self.tableView.reloadData()
         
         for quantityMetric in quantityMetrics {
             //quantityMetric.fetchAllData()
             tableView.register(UINib(nibName: quantityMetric.todayTVC_Name, bundle: nil), forCellReuseIdentifier: quantityMetric.todayTVC_Name)
             quantityMetric.fetchAllData()
         }
         
         self.navigationItem.rightBarButtonItem = self.editButtonItem
     }
    
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

        
        self.tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
}

extension TodayVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let currentMetricTVC = quantityMetrics[indexPath.row].todayTVC_Name
        
        
        if currentMetricTVC == todayTVC_Names.restingHeartRate {
            //Based on the units size in the storyboard
            return 230
        }
        
        else if currentMetricTVC == todayTVC_Names.respiratoryRate {
            return 230
        }
                    
        else if currentMetricTVC == todayTVC_Names.steps || currentMetricTVC == todayTVC_Names.walkingRunningDistance {
            return 280
        }
        else if currentMetricTVC == todayTVC_Names.workoutTime {
            
        }
        
        else if currentMetricTVC == todayTVC_Names.heartRateVariability {
            return 230
        }
        
        return 200
        
    }
}


extension TodayVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        quantityMetrics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let authorizationGranted = UserDefaults.standard.bool(forKey: "authorization_granted")
        
        guard authorizationGranted == true else {
            let cell = UITableViewCell()
            return cell
        }
        
        let quantityMetric = quantityMetrics[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: quantityMetric.todayTVC_Name, for: indexPath)
        return cell
        

    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
           return true
       }
       
       func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
           // Update your data model array here
           let movedObject = self.quantityMetrics[sourceIndexPath.row]
           quantityMetrics.remove(at: sourceIndexPath.row)
           quantityMetrics.insert(movedObject, at: destinationIndexPath.row)
       }
}
