//
//  UserDataInformation.swift
//  Merge Health
//
//  Created by Daniel Bayas on 8/3/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct User {
    var name: String
    var email: String
}




class UserDataInformation {
    static let shared = UserDataInformation()
    
    var currentUser: User?
    
    let db = Firestore.firestore()
    
    
    ///To make it a singleton
    private init() {}
    
    func fetchUserData(completion: @escaping (Bool) -> Void){
        
        guard let user = Auth.auth().currentUser else {
            print("There is no user logged in")
            completion(false)
            return
        }
        
        let uid = user.uid
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String ?? ""
                let email = data?["email"] as? String ?? ""
                self.currentUser = User(name: name, email: email)
                completion(true)
        }
            else {
                print ("Document doesn't exist")
                completion(false)
            }
        }
        
        
        
        
    }
    
    

}
