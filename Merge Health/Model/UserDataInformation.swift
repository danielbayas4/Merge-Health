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
    var age: Int
}


class UserDataInformation {
    
    
    var currentUser: User?
    
    let db = Firestore.firestore()
    
    
    
    ///To make it a singleton
    static let shared = UserDataInformation()
    
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
                let age = data?["age"] as? Int ?? -1
                self.currentUser = User(name: name, email: email, age: age)
                completion(true)
        }
            else {
                print ("Document doesn't exist")
                completion(false)
            }
        }
        
        
        
        
    }
    
    
    
    
    
    
    func updateUserData(name: String, email: String, age: Int, completion: @escaping (Bool) -> Void){
        guard let user = Auth.auth().currentUser else {
            print("There is no user logged in")
            completion(false)
            return
        }
        
        let uid = user.uid
        
        let updatedData = ["name": name, "email": email]
        
        db.collection("users").document(uid).updateData(updatedData) { error in
            if let error = error {
                print("There was an error updating the document: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Document succesfully updated")
                self.currentUser = User(name: name, email: email, age: age)
                completion(true)
            }
        }
    }
    
    

}
