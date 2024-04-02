//

import XCTest
import FirebaseAuth
@testable import Merge_Health


class MockAuth {
    var mockUser: FirebaseAuth.User?
    
    func currentUser() -> FirebaseAuth.User? {
        return mockUser
    }
}

class MockFirestore {
    var documentData: [String: Any]?
    var documentExists = false
    var updateError: Error?
    
    func collection(_ collectionPath: String) -> MockCollectionReference {
        return MockCollectionReference(firestore: self)
    }
    
    class MockCollectionReference {
        let firestore: MockFirestore
        
        init(firestore: MockFirestore) {
            self.firestore = firestore
        }
        
        func document(_ documentPath: String) -> MockDocumentReference {
            return MockDocumentReference(firestore: firestore)
        }
    }
    
    class MockDocumentReference {
        let firestore: MockFirestore
        
        init(firestore: MockFirestore) {
            self.firestore = firestore
        }
        
        func updateData(_ documentData: [String: Any], completion: @escaping (Error?) -> Void) {
            firestore.documentData = documentData
            completion(firestore.updateError)
        }
    }
}



class UserDataInformationTests: XCTestCase {
    
    var mockAuth: MockAuth!
    var mockFirestore: MockFirestore!
    var userDataInformation: UserDataInformation!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        //des: Iniitialization of the objects
        mockAuth = MockAuth()
        mockFirestore = MockFirestore()
        userDataInformation = UserDataInformation.shared
    }
    
    func testFetchUserDataSuccess() throws {

        
        //des: I am simulating the data
        mockFirestore.documentData = ["name": "Test User", "email": "test@example.com", "age": 30]
        mockFirestore.documentExists = true
        
        
        let fetchUserDataExpectation = expectation(description: "fetchUserData")
        
        userDataInformation.fetchUserData { success in
            XCTAssertTrue(success, "fetchUserData should succeed when document exists")
            XCTAssertNotNil(self.userDataInformation.currentUser, "currentUser should not be nil after fetchUserData")
            XCTAssertEqual(self.userDataInformation.currentUser?.name, "Test User", "Name should match the mock data")
            XCTAssertEqual(self.userDataInformation.currentUser?.email, "test@example.com", "Email should match the mock data")
            XCTAssertEqual(self.userDataInformation.currentUser?.age, 30, "Age should match the mock data")
            fetchUserDataExpectation.fulfill()
        }
        
        wait(for: [fetchUserDataExpectation], timeout: 5.0)
    }
}
