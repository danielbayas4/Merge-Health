//
//  QuantityMetricProtocol.swift
//  Merge Health
//
//  Created by Daniel Bayas on 27/3/24.
//

import Foundation
import DGCharts

protocol QuantityMetricProtocol {
    
func fetchSpecificWeekDay(pastDays: Int, weekDay: Int, completion: @escaping (Int, String) -> Void)
    func fetchWeeks(completion: @escaping ([Int], [String], String) -> Void)
    func fetchDays(completion: @escaping ([Int], [String], String) -> Void)
    func fetchMonths(completion: @escaping ([Int], [String], String) -> Void)
    func fetchYears(completion: @escaping ([Int], [String], String) -> Void)
    func fetchCustomDays(userinput: Int, completion: @escaping ([Int], [String], String) -> Void)
    
    func fetchValuesPerWeekDay(completion: @escaping ([Int]) -> Void)
    
    func barChartDays()
    func barChartCustomDays(userinput: Int)
    func barChartWeeks()
    func barChartMonths()
}
