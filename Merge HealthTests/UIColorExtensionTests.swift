


import XCTest
@testable import Merge_Health

final class UIColorExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testUIColorWithValidHexStrings() {
        
            let colorMappings: [String: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)] = [
                "F0ECE5": (red: 0.94, green: 0.93, blue: 0.90, alpha: 1.0),
                "161A30": (red: 0.09, green: 0.10, blue: 0.19, alpha: 1.0),
                "B6BBC4": (red: 0.71, green: 0.73, blue: 0.77, alpha: 1.0)
            ]
            
            for (hex, expectedComponents) in colorMappings {
                
                let color = UIColor(hex: hex)
                
                guard let components = color?.cgColor.components, components.count >= 3 else {
                    XCTFail("The UIColor created from hex string \(hex) does not have RGB components.")
                    continue
                }
                
                XCTAssertEqual(components[0], expectedComponents.red, accuracy: 0.01, "Red component for \(hex) does not match.")
                XCTAssertEqual(components[1], expectedComponents.green, accuracy: 0.01, "Green component for \(hex) does not match.")
                XCTAssertEqual(components[2], expectedComponents.blue, accuracy: 0.01, "Blue component for \(hex) does not match.")
                XCTAssertEqual(color?.cgColor.alpha, expectedComponents.alpha, "Alpha component for \(hex) does not match.")
            }
        }
    
    func testUIColorWithHexF0ECE5() {
            let hexString = "F0ECE5"
            let expectedColor = UIColor(red: 0.94, green: 0.93, blue: 0.90, alpha: 1.0)
            
            testColor(hexString: hexString, expectedColor: expectedColor)
        }
        
        func testUIColorWithHex161A30() {
            let hexString = "161A30"
            let expectedColor = UIColor(red: 0.09, green: 0.10, blue: 0.19, alpha: 1.0)
            
            testColor(hexString: hexString, expectedColor: expectedColor)
        }
        
        func testUIColorWithHexB6BBC4() {
            let hexString = "B6BBC4"
            let expectedColor = UIColor(red: 0.71, green: 0.73, blue: 0.77, alpha: 1.0)
            
            testColor(hexString: hexString, expectedColor: expectedColor)
        }
        
    private func testColor(hexString: String, expectedColor: UIColor) {
        let color = UIColor(hex: hexString)
        guard let components = color?.cgColor.components, components.count >= 3 else {
            XCTFail("The UIColor created from hex string \(hexString) does not have RGB components.")
            return
        }
        

        guard let expectedComponents = expectedColor.cgColor.components else {
            XCTFail("Expected color does not have RGB components.")
            return
        }
        
        XCTAssertEqual(components[0], expectedComponents[0], accuracy: 0.01, "Red component for \(hexString) does not match.")
        XCTAssertEqual(components[1], expectedComponents[1], accuracy: 0.01, "Green component for \(hexString) does not match.")
        XCTAssertEqual(components[2], expectedComponents[2], accuracy: 0.01, "Blue component for \(hexString) does not match.")
    }

}
