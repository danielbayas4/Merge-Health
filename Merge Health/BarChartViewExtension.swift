//
//  BarChartViewExtension.swift
//  Merge Health
//
//  Created by Daniel Bayas on 31/3/24.
//



import Foundation
import DGCharts

extension BarChartView {
    func copyAllSettings(from chart: BarChartView) {
        self.data = chart.data
        
        self.xAxis.labelCount = chart.xAxis.labelCount
        self.xAxis.valueFormatter = chart.xAxis.valueFormatter
        
        
        
        
//        self.xAxis.granularity = chart.xAxis.granularity
//        self.xAxis.labelPosition = chart.xAxis.labelPosition
//        self.xAxis.labelRotationAngle = chart.xAxis.labelRotationAngle
//        self.xAxis.wordWrapEnabled = chart.xAxis.wordWrapEnabled
//        self.xAxis.avoidFirstLastClippingEnabled = chart.xAxis.avoidFirstLastClippingEnabled
//        self.xAxis.drawLabelsEnabled = chart.xAxis.drawLabelsEnabled
//        self.xAxis.drawAxisLineEnabled = chart.xAxis.drawAxisLineEnabled

    }
}
