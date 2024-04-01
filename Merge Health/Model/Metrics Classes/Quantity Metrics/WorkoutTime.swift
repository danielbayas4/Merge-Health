
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
    

    
    
    
    
    
    
    
    
    
    override func fetchDays(completion: @escaping ([Int], [String], String) -> Void) {
        
    }

    
    override func fetchWeeks(completion: @escaping ([Int], [String], String) -> Void){
        let number_weeks: Int = 10
        let weekValues = [1]
    }



    override func fetchMonths(completion: @escaping ([Int], [String], String) -> Void) {
        let number_monthts: Int = 10
        let monthValues = [1]
        
    }
    
    override func fetchYears(completion: @escaping ([Int], [String], String) -> Void){
        
    }
    

    
    override func barChartDays() {
        //fatalError("Implementation needed")
    }
    
    override func barChartWeeks()  {
        //fatalError("Implementation needed")
    }
    
    override func barChartMonths() {
        //fatalError("Implementation needed")
    }
}
