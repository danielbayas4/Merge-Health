import UIKit

class dayBarTVC: UITableViewCell {
    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var writtenValue: UILabel!
    @IBOutlet var weekDay: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialUI()
        
    }
    
    
    func initialUI(){
        progressView.progressViewStyle = .bar
        progressView.trackTintColor = .gray
        progressView.progressTintColor = UIColor(hex: "161A30")
        
        self.backgroundColor = UIColor(hex: "F0ECE5")
        
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 18)
        progressView.layer.cornerRadius = 9
        progressView.clipsToBounds = true
    }
    
   
    
    func configureProgressColor(isMax: Bool, isMin: Bool) {
        if isMax {
            progressView.progressTintColor = .green
        } else if isMin {
            progressView.progressTintColor = .red
        } else {
            progressView.progressTintColor = UIColor(hex: "161A30") // Default color
        }
    }
    
    func configureProgressColorInverse(isMax: Bool, isMin: Bool) {
        if isMax {
            progressView.progressTintColor = .red
        } else if isMin {
            progressView.progressTintColor = .green
        } else {
            progressView.progressTintColor = UIColor(hex: "161A30") // Default color
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
