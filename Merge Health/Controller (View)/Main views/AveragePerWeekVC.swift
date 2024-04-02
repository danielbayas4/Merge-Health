
import UIKit

class AveragePerWeekVC: UIViewController {
    
    
    
    //MARK: - Variables
    var weekDays: [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var individualMetric: QuantityMetric = QuantityMetric()
    
    //MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
        
        tableView.register(UINib(nibName: "dayBarTVC", bundle: nil), forCellReuseIdentifier: "dayBarTVC")
        
    }
    
    func initialUI(){
        view.backgroundColor = UIColor(hex: "F0ECE5")
    }
    

}



extension AveragePerWeekVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        115
    }
    
}

extension AveragePerWeekVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let maxIndex = individualMetric.valueForProgressView.indices.max(by: { individualMetric.valueForProgressView[$0] < individualMetric.valueForProgressView[$1] })
        
        let minIndex = individualMetric.valueForProgressView.indices.min(by: { individualMetric.valueForProgressView[$0] < individualMetric.valueForProgressView[$1] })
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dayBarTVC") as? dayBarTVC else {
            fatalError("Cell is not dequed correctly")
        }
        
        let isMax = indexPath.row == maxIndex
        let isMin = indexPath.row == minIndex
        
        
        
        
        
        
        cell.weekDay.text = weekDays[indexPath.row]
         cell.progressView.progress = individualMetric.valueForProgressView[indexPath.row]
        cell.writtenValue.text = "\(individualMetric.unitName): \(individualMetric.valuesPerWeekday[indexPath.row]) | Compared to maximum: \(individualMetric.comparedToMaximumString[indexPath.row])"
        
        
        
        if individualMetric.exposingName == "Resting Heart Rate" {
            cell.configureProgressColorInverse(isMax: isMax, isMin: isMin)
        }
        else {
            cell.configureProgressColor(isMax: isMax, isMin: isMin)
        }
        
        
        
        return cell
        
    }
    
    
}
