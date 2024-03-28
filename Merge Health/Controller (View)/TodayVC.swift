

import UIKit
import HealthKit

class TodayVC: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    let healthStore = HKHealthStore()
    
   // var quantityMetrics: [QuantityMetric] = [RestingHeartRateM.shared, Steps.shared, WorkoutTime.shared, HeartRateVariability.shared]
    
    var quantityMetrics: [QuantityMetric] = [RestingHeartRateM.shared]

    
     override func viewDidLoad() {
         //the table is loaded at the initial load, so it does not know about the modification of the variables that populates it
         super.viewDidLoad()
         
         self.tableView.reloadData()
         
         for quantityMetric in quantityMetrics {
             quantityMetric.fetchAllData()
             tableView.register(UINib(nibName: quantityMetric.todayTVC_Name, bundle: nil), forCellReuseIdentifier: quantityMetric.todayTVC_Name)
         }
     }
    
    func getAllAverageToday(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for quantity_metric in quantityMetrics {
            group.enter()
            quantity_metric.fetchAverageToday { averageToday in
                DispatchQueue.main.async {
                    quantity_metric.today_average = averageToday
                    group.leave()
                }
            }
            
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    

    
}

extension TodayVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let currentMetricTVC = quantityMetrics[indexPath.row].todayTVC_Name
        
        
        if currentMetricTVC == todayTVC_Names.restingHeartRate {
            //Based on the units size in the storyboard
            return 230
        }
        else if currentMetricTVC == todayTVC_Names.steps {
            
        }
        else if currentMetricTVC == todayTVC_Names.workoutTime {
            
        }
        
        else if currentMetricTVC == todayTVC_Names.heartRateVariability {
            
        }
        
        return 200
        
    }
}


extension TodayVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        quantityMetrics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let quantityMetric = quantityMetrics[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: quantityMetric.todayTVC_Name, for: indexPath)
        return cell
    }
}
