//
//  SpreadViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/7/10.
//

import UIKit
import Charts
import DGCharts

class SpreadViewController: UIViewController {

    var lineChartView: LineChartView!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            lineChartView = LineChartView()
            lineChartView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(lineChartView)
            NSLayoutConstraint.activate([
                lineChartView.topAnchor.constraint(equalTo: self.view.topAnchor),
                lineChartView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                lineChartView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                lineChartView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])

            if let filePath = Bundle.main.path(forResource: "spread", ofType: "csv") {
                do {
                    let csvData = try String(contentsOfFile: filePath, encoding: .utf8)
                    let csvLines = csvData.components(separatedBy: "\n").filter { !$0.isEmpty }
                    
                    // Parse the CSV data
                    var dates = [String]()
                    var values = [Double]()
                    if let headerLine = csvLines.first {
                        let headers = headerLine.components(separatedBy: ",")
                        if let awkPoddIndex = headers.firstIndex(of: "AWK-PODD") {
                            for line in csvLines.dropFirst() {
                                let columns = line.components(separatedBy: ",")
                                if columns.count > awkPoddIndex, let value = Double(columns[awkPoddIndex]) {
                                    dates.append(columns[0])
                                    values.append(value)
                                }
                            }
                            setChart(dates: dates, values: values)
                        } else {
                            print("AWK-PODD column not found")
                        }
                    }
                    
                } catch {
                    print("Error reading CSV file: \(error)")
                }
            }
        }
        
        func setChart(dates: [String], values: [Double]) {
            var dataEntries: [ChartDataEntry] = []
            
            for i in 0..<dates.count {
                let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
                dataEntries.append(dataEntry)
            }
            
            let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: "AWK-PODD")
            let lineChartData = LineChartData(dataSet: lineChartDataSet)
            
            lineChartView.data = lineChartData
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
            lineChartView.xAxis.labelPosition = .bottom
            lineChartView.xAxis.granularity = 1
            lineChartView.xAxis.labelRotationAngle = -45
            lineChartView.xAxis.avoidFirstLastClippingEnabled = true
            lineChartView.xAxis.forceLabelsEnabled = true
            lineChartView.xAxis.setLabelCount(dates.count / 5, force: true)
            lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
            lineChartView.setVisibleXRangeMaximum(10)
            lineChartView.moveViewToX(0)
        }
}
