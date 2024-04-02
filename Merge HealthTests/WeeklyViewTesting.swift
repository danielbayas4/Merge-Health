
import XCTest
@testable import Merge_Health



final class WeeklyViewTesting: XCTestCase {
    
    func testNormalArray() {
        let instance = RestingHeartRateM.shared
        
            let averageArray1 = [56, 79, 54, 57, 66, 87, 56]
            let expectedValuesForProgressView1: [Float] = [0.64, 0.91, 0.62, 0.66, 0.76, 1.00, 0.64]
            let expectedAveragesString1 = ["64%", "91%", "62%", "66%", "76%", "100%", "64%"]

            var result = instance.simplifiedUnifyWeekDaysForTesting(from: averageArray1)
            XCTAssertEqual(result.maxValue, 87)
            XCTAssertEqual(result.valuesForProgressView, expectedValuesForProgressView1)
            XCTAssertEqual(result.averagesString, expectedAveragesString1)
        }
    
    func testUnifyDatesWithEmptyArray() {
        let instance = RestingHeartRateM.shared
        let averageArray = [Int]()
        let expectedValuesForProgressView: [Float] = []
        let expectedAveragesString: [String] = []

        let result = instance.simplifiedUnifyWeekDaysForTesting(from: averageArray)
        XCTAssertEqual(result.maxValue, 0)
        XCTAssertEqual(result.valuesForProgressView, expectedValuesForProgressView)
        XCTAssertEqual(result.averagesString, expectedAveragesString)
    }


    func testUnifyDatesWithIdenticalValues() {
        let instance = RestingHeartRateM.shared
        let averageArray = [70, 70, 70, 70, 70, 70, 70]
        let expectedValuesForProgressView: [Float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
        let expectedAveragesString = ["100%", "100%", "100%", "100%", "100%", "100%", "100%"]

        let result = instance.simplifiedUnifyWeekDaysForTesting(from: averageArray)
        XCTAssertEqual(result.maxValue, 70)
        XCTAssertEqual(result.valuesForProgressView, expectedValuesForProgressView)
        XCTAssertEqual(result.averagesString, expectedAveragesString)
    }


    func testUnifyDatesWithZeros() {
        let instance = RestingHeartRateM.shared
        let averageArray = [0, 0, 0, 0, 0, 0, 87]
        let expectedValuesForProgressView: [Float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9]
        let expectedAveragesString = ["0%", "0%", "0%", "0%", "0%", "0%", "100%"]

        let result = instance.simplifiedUnifyWeekDaysForTesting(from: averageArray)
        XCTAssertEqual(result.maxValue, 87)
        XCTAssertEqual(result.valuesForProgressView, expectedValuesForProgressView)
        XCTAssertEqual(result.averagesString, expectedAveragesString)
    }
    
}
