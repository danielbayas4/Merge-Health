//
//  QuantityMetricProtocol.swift
//  Merge Health
//
//  Created by Daniel Bayas on 27/3/24.
//

import Foundation
import DGCharts

protocol QuantityMetricProtocol {
    //func fetchLastValue(completion: @escaping (String) -> Void)
    //func fetchAverageToday(completion: @escaping (String) -> Void)
    
    
    func fetchAverageLastDays(completion: @escaping (String) -> Void)
    
    func fetchWeeks(completion: @escaping ([Int]) -> Void)
    func fetchDays(completion: @escaping ([Int]) -> Void)
    func fetchMonths(completion: @escaping ([Int]) -> Void)
    func fetchValuesPerWeekDay(completion: @escaping ([Int]) -> Void)
    
    func barChartWeek() -> BarChartView
    func barChartMonth() -> BarChartView
    func barChartYear() -> BarChartView
    

    
}
