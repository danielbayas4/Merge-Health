import Foundation
import HealthKit
import DGCharts

class WalkingRunningDistance: QuantityMetric {
    
    static let shared = WalkingRunningDistance()
    override var todayTVC_Name: String {
        return todayTVC_Names.walkingRunningDistance
    }
    override var exposingName: String {
        return exposingNames.walkingRunningDistance
    }
    
    
    private override init() {
        super.init()
    }
    
    override func fetchAllData() {
        
        self.fetchAverageLastDays { _ in
            
        }
        self.fetchExpectedTotalValueUntilNow { _ in
            
        }
        
        self.fetchSumUntilNow { _ in
            
        }
        
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
