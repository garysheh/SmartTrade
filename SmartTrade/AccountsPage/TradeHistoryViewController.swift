//
//  TradeHistoryViewController.swift
//  SmartTrade
//
//  Created by Frank Leung on 25/6/2024.
//


import UIKit
import Firebase
import DGCharts
import FirebaseCore
import FirebaseFirestore

class TradeHistoryViewController: UIViewController {
    
    var tabBarIndex: Int?
    var stockSymbol: String?
    var stockData: [TradeOrder] = []
    
    
    @IBOutlet weak var ChartView: UIView!
    private var currentBarChartView: BarChartView?
    
    
    
    
    struct TradeOrder: Codable {
        let symbol: String
        let quantity: Double
        let timestamp: Timestamp
        let email: String
        let type: String
    }
    
    let segmentedControl = UISegmentedControl(items: ["Buy", "Sell"])
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSegmentedControl()
        }

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupCustomBackButton()
        setBarChartBuy()
      
    }
    
    //setting the segmented controller
    private func setupSegmentedControl() {
            segmentedControl.selectedSegmentIndex = 0
            view.addSubview(segmentedControl)
            
            // add constraint
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            
            // set style
            segmentedControl.backgroundColor = .black
            segmentedControl.selectedSegmentTintColor = .systemGreen
            let font = UIFont.systemFont(ofSize: 16, weight: .medium)
            segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.white], for: .normal)
            segmentedControl.setTitleTextAttributes([.font: font, .foregroundColor: UIColor.white], for: .selected)
            
            segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        }
    
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
            // 处理选中选项变化的逻辑
            switch sender.selectedSegmentIndex {
            case 0:
                if let currentBarChartView = currentBarChartView {
                        currentBarChartView.removeFromSuperview()
                    }
                setBarChartBuy()
            case 1:
                if let currentBarChartView = currentBarChartView {
                        currentBarChartView.removeFromSuperview()
                    }
                setBarChartSell()
            default:
                break
            }
        }
    
    
    //----------------------------------- sell ----------------------------------
    private func setBarChartBuy() {
        let barChartView = BarChartView(frame: ChartView.bounds)
//        ChartView.addSubview(barChartView)
        let categories = ["2020", "2021", "2022", "2023", "2024"]
        let data = [45.0, 62.0, 78.0, 90.0, 100.0]
        
        let dataSet = BarChartDataSet(entries: data.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element) }, label: "Buy")
        dataSet.colors = [UIColor.systemBlue]

        // 設置 BarChartData
        let chartData = BarChartData(dataSet: dataSet)
        chartData.barWidth = 0.5 // 調整柱子寬度

        // 設置 BarChartView 的屬性
        barChartView.data = chartData
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: categories)
//            barChartView.xAxis.granularity = 1 // 設置 x 軸標籤間隔
//        barChartView.xAxis.labelPosition = .bottom // 設置 x 軸標籤位置
        barChartView.leftAxis.axisMinimum = 0 // 設置 y 軸最小值
        barChartView.leftAxis.axisMaximum = 120 // 設置 y 軸最大值
        barChartView.leftAxis.labelCount = 6 // 設置 y 軸標籤數量
        
        //style
        barChartView.leftAxis.labelTextColor = UIColor.white

        //animation of the bar
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)

        //the current price line add
        let targetLine = ChartLimitLine(limit: 70, label: "Current Price")
        targetLine.lineColor = UIColor.green
        targetLine.lineWidth = 1.5
        targetLine.valueTextColor = UIColor.green
        targetLine.valueFont = .systemFont(ofSize: 10)
        barChartView.leftAxis.addLimitLine(targetLine)
        
        
        //reset the chart
        currentBarChartView = barChartView
        ChartView.addSubview(barChartView)

    }

    private func setBarChartSell() {
        let barChartView = BarChartView(frame: ChartView.bounds)
//        ChartView.addSubview(barChartView)
        let categories = ["2020", "2021", "2022", "2023", "2024"]
        let data = [49.0, 92.0, 38.0, 95.0, 133.0]
        
        let dataSet = BarChartDataSet(entries: data.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element) }, label: "Sell")
        dataSet.colors = [UIColor.systemRed]
        dataSet.drawValuesEnabled = true

        // 設置 BarChartData
        let chartData = BarChartData(dataSet: dataSet)
        chartData.barWidth = 0.5 // 調整柱子寬度

        // 設置 BarChartView 的屬性
        barChartView.data = chartData
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: categories)
        barChartView.xAxis.granularity = 1 // 設置 x 軸標籤間隔
        barChartView.xAxis.labelPosition = .bottom // 設置 x 軸標籤位置
        barChartView.leftAxis.axisMinimum = 0 // 設置 y 軸最小值
        barChartView.leftAxis.axisMaximum = 120 // 設置 y 軸最大值
        barChartView.leftAxis.labelCount = 6 // 設置 y 軸標籤數量
        
        //style
        barChartView.leftAxis.labelTextColor = UIColor.white
        
            
        //animation of the bar
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
        
        //the current price line add
        let targetLine = ChartLimitLine(limit: 70, label: "Current Price")
        targetLine.lineColor = UIColor.green
        targetLine.lineWidth = 1.5
        targetLine.valueTextColor = UIColor.green
        targetLine.valueFont = .systemFont(ofSize: 10)
        barChartView.leftAxis.addLimitLine(targetLine)

        
        
        currentBarChartView = barChartView
        ChartView.addSubview(barChartView)

    }
    
    
    
    private func setDefault(){
        print(stockSymbol)
        let db = Firestore.firestore()
        let email = Auth.auth().currentUser?.email
        
        
        
    }
    

    

    // Navigation part
    
    
//    private func setupCustomBackButton() {
//            let backButton = UIButton(type: .system)
//            let backButtonImage = UIImage(systemName: "house")
//            backButton.setImage(backButtonImage, for: .normal)
//            backButton.tintColor = .white
//            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//            let backBarButtonItem = UIBarButtonItem(customView: backButton)
//            navigationItem.leftBarButtonItem = backBarButtonItem
//            print("Custom back button set up")
//        }
//    
//    @objc private func backButtonTapped() {
//            print("Back button tapped")
//            loadTabBarController(atIndex: 0)
//        }
//        
//        private func loadTabBarController(atIndex index: Int) {
//            self.tabBarIndex = index
//            self.performSegue(withIdentifier: "showTabBar", sender: self)
//        }
//
//        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if segue.identifier == "showTabBar" {
//                if let tabBarController = segue.destination as? UITabBarController {
//                    tabBarController.selectedIndex = self.tabBarIndex ?? 0
//                }
//            }
//        }
}
