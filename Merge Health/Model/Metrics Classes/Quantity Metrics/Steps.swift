
import Foundation
import HealthKit
import DGCharts

class Steps: QuantityMetric {
    
    static let shared = Steps()
    private override init() {
        super.init()
    }
    
    
    override var todayTVC_Name: String {
        return todayTVC_Names.steps
    }

    override func fetchLastValue(completion: @escaping (String) -> Void) {
        //return "Implementation needed"
    }
    
    override func fetchAverageToday(completion: @escaping (String) -> Void) {
        //return "Implementation needed"
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
