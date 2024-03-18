
//  HealthProfile.swift
//  Merge Health

import UIKit

class HealthProfile: Codable {
    var username: String
    var password: String
    
    init(username: String, password: String) {
            self.username = username
            self.password = password
        }
    
    
    
}
