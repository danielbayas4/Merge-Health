//
//  DayBarTVCTests.swift
//  Merge HealthTests
//
//  Created by Daniel Bayas on 5/4/24.
//

import XCTest
@testable import Merge_Health

final class DayBarTVCTests: XCTestCase {

    var cell: dayBarTVC!

    override func setUp() {
            super.setUp()
            cell = dayBarTVC(style: .default, reuseIdentifier: "dayBarTVC")
            cell.progressView = UIProgressView(progressViewStyle: .bar)
            cell.contentView.addSubview(cell.progressView)

            cell.progressView.frame = CGRect(x: 10, y: 10, width: 200, height: 20)
            
        
            cell.initialUI()
        }

      func testConfigureProgressColorWithMax() {
          cell.configureProgressColor(isMax: true, isMin: false)
          XCTAssertEqual(cell.progressView.progressTintColor, UIColor.green, "Progress color should be green when isMax is true")
      }

      func testConfigureProgressColorWithMin() {
          cell.configureProgressColor(isMax: false, isMin: true)
          XCTAssertEqual(cell.progressView.progressTintColor, UIColor.red, "Progress color should be red when isMin is true")
      }

      func testConfigureProgressColorWithNeitherMaxNorMin() {
          cell.configureProgressColor(isMax: false, isMin: false)
          XCTAssertEqual(cell.progressView.progressTintColor, UIColor(hex: "161A30"), "Progress color should be default color when neither isMax nor isMin is true")
      }

      func testConfigureProgressColorInverseWithMax() {
          cell.configureProgressColorInverse(isMax: true, isMin: false)
          XCTAssertEqual(cell.progressView.progressTintColor, UIColor.red, "Inverse progress color should be red when isMax is true")
      }
    
    
    
}
