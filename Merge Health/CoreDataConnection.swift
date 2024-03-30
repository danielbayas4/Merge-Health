import UIKit
import CoreData



class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<Heart> = Heart.fetchRequest()

        do {
                // Execute Fetch Request
                let result = try context.fetch(fetchRequest)

                // Iterate through the fetched objects and access their properties
                for heart in result {
                    let name = heart.name // Assuming 'name' is an optional string
                    let heartRate = heart.heart_rate // Directly access 'heart_rate'
                    print("Name: \(name ?? "Unknown"), Heart Rate: \(heartRate)")
                }
            } catch {
                print("Unable to fetch data, \(error)")
            }
        
        //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let newHeart = NSEntityDescription.insertNewObject(forEntityName: "Heart", into: context) as! Heart

        newHeart.name = "Jose Alvarado"
        newHeart.heart_rate = Int32(64)

        do {
            try context.save()
            print("Saved!")

        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

