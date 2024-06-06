//
//  AccountsViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/6/1.
//

import UIKit
import Charts
import DGCharts

class AccountsViewController: UIViewController {

    
    @IBOutlet weak var ChartsView: UIView!
    
    @IBOutlet weak var shareCounts: UILabel!
    
    @IBOutlet weak var marketValue: UILabel!
    
    @IBOutlet weak var costValue: UILabel!
    
    @IBOutlet weak var portRate: UILabel!
    
    @IBOutlet weak var todayReturnRate: UILabel!
    
    @IBOutlet weak var todayReturnValue: UILabel!
    
    @IBOutlet weak var totalReturnValue: UILabel!
    
    @IBOutlet weak var totalReturnRate: UILabel!
    


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCharts()
    }
    
    
    private func setupCharts() {
            // 设置饼状图
        let pieChartView = PieChartView(frame: ChartsView.bounds)
        ChartsView.addSubview(pieChartView)

        let holdingData = getHoldingData()
        var dataEntries: [PieChartDataEntry] = []
        for (stockName, value) in holdingData {
            dataEntries.append(PieChartDataEntry(value: value, label: stockName))
        }

        let dataSet = PieChartDataSet(entries: dataEntries)
        dataSet.colors = cusColors
        pieChartView.holeColor = .black
        dataSet.valueColors = [.white]
        pieChartView.legend.enabled = false
        let pieChartData = PieChartData(dataSet: dataSet)
        pieChartView.data = pieChartData
        
        }
    
    let cusColors: [UIColor] = [
        UIColor(red: 13/255.0, green: 126/255.0, blue: 156/255.0, alpha: 1.0),
        UIColor(red: 24/255.0, green: 90/255.0, blue: 86/255.0, alpha: 1.0),
        UIColor(red: 253/255.0, green: 116/255.0, blue: 45/255.0, alpha: 1.0),
        UIColor(red: 83/255.0, green: 88/255.0, blue: 154/255.0, alpha: 1.0),
        UIColor(red: 251/255.0, green: 205/255.0, blue: 8/255.0, alpha: 1.0),
        UIColor(red: 54/255.0, green: 54/255.0, blue: 54/255.0, alpha: 1.0),
        UIColor(red: 127/255.0, green: 169/255.0, blue: 31/255.0, alpha: 1.0),
        UIColor(red: 213/255.0, green: 186/255.0, blue: 159/255.0, alpha: 1.0),
        UIColor(red: 0/255.0, green: 50/255.0, blue: 77/255.0, alpha: 1.0),
        UIColor(red: 184/255.0, green: 144/255.0, blue: 118/255.0, alpha: 1.0),
        UIColor(red: 220/255.0, green: 60/255.0, blue: 20/255.0, alpha: 1.0),
        UIColor(red: 0/255.0, green: 206/255.0, blue: 209/255.0, alpha: 1.0)
    ]
    

        private func getHoldingData() -> [String: Double] {
            // 从数据源获取持仓数据
            return ["Stock A": 5.0, "Stock B": 18.0, "Stock C": 15.0, "Stock D": 12.0, "Stock E": 10.0,"Stock F": 10.0,"Stock G": 10.0]
        }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}
