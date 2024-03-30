
import Foundation
import HealthKit
import DGCharts

class WorkoutTime: QuantityMetric {
    
    var last_workout_length: String
    var current_total_time: String
    override var todayTVC_Name: String {
        return todayTVC_Names.workoutTime
    }
    override var exposingName: String {
        return exposingNames.workoutTime
    }
    
    
    static let shared = WorkoutTime()
    private override init() {
        last_workout_length = "N/A"
        current_total_time = "N/A"
        super.init()
    }
    
    override func fetchAllData() {
        
        self.fetchAverageLastDays { _ in
            
        }
        self.fetchExpectedTotalValueUntilNow { _ in
            
        }
        
        self.fetchSumUntilNow { _ in
            
        }
        
        self.fetchLastValue { _ in
            
        }
        
    }
    
    override func fetchAverageLastDays(completion: @escaping (String) -> Void) {
        
    }

    override func fetchLastValue(completion: @escaping (String) -> Void) {
        //return "Implementation needed"
    }
    
    override func fetchExpectedTotalValueUntilNow(completion: @escaping (String) -> Void) {
        
    }
    
    override func fetchSumUntilNow(completion: @escaping (String) -> Void) {
        
    }
    

    
    
    
    
    
    
    
    
    
    override func fetchWeeks(completion: @escaping ([Int]) -> Void) {
        

    }
    
    override func fetchDays(completion: @escaping ([Int]) -> Void) {
        
        
    }
    
    override func fetchMonths(completion: @escaping ([Int]) -> Void){

 
    }
    
    override func barChartWeek() -> BarChartView {
        fatalError("Implementation needed")
    }
    
    override func barChartMonth() -> BarChartView {
        fatalError("Implementation needed")
    }
    
    override func barChartYear() -> BarChartView {
        fatalError("Implementation needed")
    }
}
