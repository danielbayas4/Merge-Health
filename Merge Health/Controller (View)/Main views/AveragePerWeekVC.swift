
import UIKit

class AveragePerWeekVC: UIViewController {
    
    
    
    //MARK: - Variables
    var weekDays: [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var individualMetric: QuantityMetric = QuantityMetric()
    
    //MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!
    
    
    //tableView.register(UINib(nibName: "dayBarTVC", bundle: nil), forCellReuseIdentifier: "day")
    
    
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
        100
    }
    
}

extension AveragePerWeekVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "dayBarTVC") as? dayBarTVC else {
            fatalError("Cell is not dequed correctly")
        }
        
        var valuesPerWeekDay: [Int] = individualMetric.valuesPerWeekday
        var comparedToMaximum = individualMetric.comparedToMaximum
        
        
        cell.weekDay.text = weekDays[indexPath.row]
        cell.writtenValue.text = "Value: \(valuesPerWeekDay) | Compared to maximum: \(comparedToMaximum)"
        
        if cell.weekDay.text == "Monday" {
            cell.progressView.progress = 0.5
            //Se actualiza de igual manera el
            //cell.writtenValue = el primer valor del array que vaya a crear
        }
        if cell.weekDay.text == "Tuesday" {
            cell.progressView.progress = 0.2
        }
        if cell.weekDay.text == "Wednesday" {
            cell.progressView.progress = 1
        }
        if cell.weekDay.text == "Thursday" {
            cell.progressView.progress = 0.3
        }
        
        
        return cell
        
    }
    
    
}
