//
//  StockDetailViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/5/30.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import Foundation
import Charts
import DGCharts
import Combine

class StockDetailViewController: UIViewController {
    @IBOutlet weak var BuyButton: UIButton!
    @IBOutlet weak var SellButton: UIButton!
    @IBOutlet weak var Stockprice: UILabel!
    @IBOutlet weak var stockName: UILabel!
    @IBOutlet weak var preTime: UILabel!
    @IBOutlet weak var timeChart: UIView!
    @IBOutlet weak var oneYear: UILabel!
    @IBOutlet weak var oneMonth: UILabel!
    @IBOutlet weak var oneWeek: UILabel!
    @IBOutlet weak var oneDay: UILabel!
    
    var stockData: SearchResult?
    
    override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
        setupRoundedLabel(labels: [oneDay,oneWeek,oneMonth,oneYear])
            if let stockData = stockData {
                Stockprice.text = String(format: "%.2f", Double(stockData.price)!)
                stockName.text = stockData.symbol
                preTime.text = "Latest.Trade: " + stockData.day
                setupChart()
                fetchDailyPriceData(for: stockData.symbol)
            }
    }
    
    // UI interface configur
    
    // Set rounded label
    private func setupRoundedLabel(labels: [UILabel]) {
        for label in labels {
            label.layer.cornerRadius = 10 // Adjust the radius as needed
            label.layer.masksToBounds = true
        }
    }
    
    // hightlight the timeline label
    
    private func updatePriceColorAndHighlightLabel(percentageChange: Double) {
        let color: UIColor
            if percentageChange >= 0 {
                color = UIColor(red: 27/255, green: 187/255, blue: 125/255, alpha: 1.0) // Green color
                Stockprice.textColor = color
                oneDay.backgroundColor = color
                oneDay.textColor = .white
            } else {
                color = UIColor(red: 240/255, green: 57/255, blue: 85/255, alpha: 1.0) // Red color
                Stockprice.textColor = color
                oneDay.backgroundColor = color
                oneDay.textColor = .white
            }
    }
    
    // PRICE CHART PART
    
    private let lineChartView: LineChartView = {
            let chartView = LineChartView()
            chartView.translatesAutoresizingMaskIntoConstraints = false
            return chartView
        }()
    
    private var cancellable: AnyCancellable? = nil
    private let apiService = APIService()
    
    private func setupChart() {
        timeChart.addSubview(lineChartView)

        NSLayoutConstraint.activate([
            lineChartView.leadingAnchor.constraint(equalTo: timeChart.leadingAnchor),
                    lineChartView.trailingAnchor.constraint(equalTo: timeChart.trailingAnchor),
                    lineChartView.topAnchor.constraint(equalTo: timeChart.topAnchor),
                    lineChartView.bottomAnchor.constraint(equalTo: timeChart.bottomAnchor)
        ])

        let leftAxis = lineChartView.leftAxis
            leftAxis.enabled = false
            leftAxis.drawLabelsEnabled = false
            leftAxis.drawGridLinesEnabled = true
            leftAxis.gridColor = .lightGray
        
        let rightAxis = lineChartView.rightAxis
            rightAxis.enabled = true
            rightAxis.labelFont = .systemFont(ofSize: 10)
            rightAxis.labelTextColor = .white
            rightAxis.drawGridLinesEnabled = false
            rightAxis.labelCount = 6
            rightAxis.valueFormatter = DefaultAxisValueFormatter(block: { (value, axis) -> String in
            return String(format: "%.2f", value)
        })
        
        let xAxis = lineChartView.xAxis
            xAxis.enabled = false
            xAxis.drawLabelsEnabled = false
            xAxis.drawGridLinesEnabled = false
            xAxis.gridColor = .lightGray
            lineChartView.legend.enabled = false
            lineChartView.chartDescription.enabled = false
            lineChartView.setScaleEnabled(false)
            lineChartView.drawGridBackgroundEnabled = false
    }
    
    private func fetchDailyPriceData(for symbol: String) {
            cancellable = apiService.fetchDailyPricesPublisher(symbol: symbol)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error fetching daily prices: \(error)")
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] prices in
                    //self?.updateChart(with: prices)
                    guard let self = self else { return }
                                let minPrice = prices.min() ?? 0.0
                                let maxPrice = prices.max() ?? 0.0
                                self.updateChart(with: prices, minPrice: minPrice, maxPrice: maxPrice)
                    if let latestPrice = prices.last, prices.count >= 2 {
                                    let previousPrice = prices[prices.count - 2]
                                    let percentageChange = ((latestPrice - previousPrice) / previousPrice) * 100
                        self.updatePriceColorAndHighlightLabel(percentageChange: percentageChange)
                                }
                })
        }
    
    private func updateChart(with prices: [Double], minPrice: Double, maxPrice: Double) {
        guard prices.count >= 2 else {
            // Not enough data to calculate percentage change
            return
        }

        // Calculate percentage change from yesterday
        let yesterdayPrice = prices[prices.count - 2]
        let latestPrice = prices.last!
        let percentageChange = ((latestPrice - yesterdayPrice) / yesterdayPrice) * 100

        // Determine the color based on percentage change
        let lineColor: UIColor
        if percentageChange >= 0 {
            lineColor = UIColor(red: 27/255, green: 187/255, blue: 125/255, alpha: 1.0) // Green color
        } else {
            lineColor = UIColor(red: 240/255, green: 57/255, blue: 85/255, alpha: 1.0) // Red color
        }

        let entries = prices.enumerated().map { index, price in
            return ChartDataEntry(x: Double(index), y: price)
        }

        let dataSet = LineChartDataSet(entries: entries, label: "")

        // Customize the line with specific conditional color
        dataSet.colors = [lineColor]
        dataSet.lineWidth = 1.0
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false

        // Add gradient fill
        let gradientColors = [lineColor.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: nil)
        dataSet.fill = LinearGradientFill(gradient: gradient!, angle: 90)
        dataSet.drawFilledEnabled = true

        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        lineChartView.rightAxis.axisMinimum = minPrice
        lineChartView.rightAxis.axisMaximum = maxPrice
        lineChartView.notifyDataSetChanged()
    }
    
    // BUY AND SELL FUNCTION PART
    
    
    @IBAction func BuyButtonTapped(_ sender: Any) {
        showBuyOptionPopup()
    }
    
    //option for user to buy
    private func showBuyOptionPopup() {
            let alert = UIAlertController(title: "Buy Shares", message: "Choose your buy option:", preferredStyle: .alert)
            
            let marketBuyAction = UIAlertAction(title: "Market Buy", style: .default) { (_) in
                self.showMarketBuyPopup()
            }
            let limitBuyAction = UIAlertAction(title: "Limit Buy", style: .default) { (_) in
                self.showLimitBuyPopup()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(marketBuyAction)
            alert.addAction(limitBuyAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    
    //Function buy using the price now
    private func showMarketBuyPopup() {
        let alert = UIAlertController(title: "Market Buy", message: "Enter the number of shares to buy:", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Number of shares"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let buyAction = UIAlertAction(title: "Buy", style: .default) { (_) in
            if let sharesText = alert.textFields?.first?.text, let sharesAdd = Int(sharesText) {
                let db = Firestore.firestore()
                let orderUuid = UUID().uuidString
                let timeInterval:TimeInterval = Date().timeIntervalSince1970
                let timeStamp = Int(timeInterval)
                let email = Auth.auth().currentUser?.email

                db.collection("OrdersInfo").document(orderUuid).setData([
                    "userEmail": email,
                    "orderID": orderUuid,
                    "stockCode": self.stockName.text,
                    "type": "buy",
                    "quantity": sharesAdd,
                    "price": self.Stockprice.text,
                    "timestamp": timeStamp,
                    "Status":"Done"
                ])

                db.collection("Holdings").document(email!).getDocument { (document, error) in
                    if let document = document, document.exists {
                        var holdings = document.data()?["holdings"] as? [[String: Any]] ?? []
                        
                        // 检查是否已持有该股票
                        var existingHolding: [String: Any]?
                        for holding in holdings {
                            if holding["stockCode"] as? String == self.stockName.text {
                                existingHolding = holding
                                break
                            }
                        }
                        
                        if let existingHoldingIndex = holdings.firstIndex(where: { $0["stockCode"] as? String == self.stockName.text }) {
                            var existingHolding = holdings[existingHoldingIndex]
                            var shares = existingHolding["shares"] as? Int ?? 0
                            var avgCost = existingHolding["avgCost"] as? Double ?? 0.0
                            
                            // 更新平均持仓成本
                            if let stockPrice = Double(self.Stockprice.text ?? "0.0") {
                                let newTotalCost = (Double(shares) * avgCost) + (Double(sharesAdd) * stockPrice)
                                let newTotalShares = shares + sharesAdd
                                avgCost = newTotalCost / Double(newTotalShares)
                            } else {
                                // 處理 Stockprice.text 無法轉換為 Double 的情況
                                let newTotalCost = (Double(shares) * avgCost) + (Double(sharesAdd) * 0.0)
                                let newTotalShares = shares + sharesAdd
                                avgCost = newTotalCost / Double(newTotalShares)
                            }
                            
                            shares += sharesAdd
                            avgCost = round(avgCost * 100) / 100
                            
                            existingHolding["shares"] = shares
                            existingHolding["avgCost"] = avgCost
                            holdings[existingHoldingIndex] = existingHolding
                            
                            // update the records
                            db.collection("Holdings").document(email!).updateData([
                                "holdings": holdings
                            ])
                        } else {
                            // adding the new record
                            holdings.append([
                                "stockCode": self.stockName.text,
                                "shares": sharesAdd,
                                "avgCost": Double(self.Stockprice.text ?? "0.0") ?? 0.0
                            ])
                            
                            // update in Firestore
                            db.collection("Holdings").document(email!).updateData([
                                "holdings": holdings
                            ])
                        }
                    } else {
                        // create a new holding stock index
                        db.collection("Holdings").document(email!).setData([
                            "email": email,
                            "holdings": [
                                ["stockCode": self.stockName.text, "shares": sharesAdd, "avgCost": Double(self.Stockprice.text ?? "0.0") ?? 0.0]
                            ]
                        ])
                    }
                    let alert = UIAlertController(title: "Order made!💰", message: "Successfully purchased this stock!✌️", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(buyAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //set an expected price to buy
    private func showLimitBuyPopup() {
            let alert = UIAlertController(title: "Limit Buy", message: "Enter the price and number of shares to buy:", preferredStyle: .alert)
            
            alert.addTextField { (priceTextField) in
                priceTextField.keyboardType = .decimalPad
                priceTextField.placeholder = "Price per share"
            }
            
            alert.addTextField { (sharesTextField) in
                sharesTextField.keyboardType = .numberPad
                sharesTextField.placeholder = "Number of shares"
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let buyAction = UIAlertAction(title: "Buy", style: .default) { (_) in
                if let priceText = alert.textFields?.first?.text, let sharesText = alert.textFields?.last?.text, let price = Double(priceText), let sharesAdd = Int(sharesText) {
                    let db = Firestore.firestore()
                    let orderUuid = UUID().uuidString
                    let timeInterval:TimeInterval = Date().timeIntervalSince1970
                    let timeStamp = Int(timeInterval)
                    let email = Auth.auth().currentUser?.email

                    
                    if let pricenowText = self.Stockprice.text, let pricenow = Double(pricenowText), pricenow > price {
                        
                        db.collection("OrdersInfo").document(orderUuid).setData([
                                    "userEmail": email,
                                    "orderID": orderUuid,
                                    "stockCode": self.stockName.text,
                                    "type": "buy",
                                    "quantity": sharesAdd,
                                    "price": price,
                                    "timestamp": timeStamp,
                                    "Status":"Waiting"
                                ])
                        //ToDo: to process the order.
                        
                        let alert = UIAlertController(title: "Order made!💰", message: "Waiting for CCP processing. . .", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else{
                        let alert = UIAlertController(title: "Oh, you have set a higher price.", message: "Maybe you can buy now or enter a new price", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }


                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(buyAction)
            
            present(alert, animated: true, completion: nil)
        }

    
    
    
    @IBAction func SellButtonTapped(_ sender: Any) {
        showSellOptionPopup()
    }
    
    //show the option of selling stock
    private func showSellOptionPopup() {
            let alert = UIAlertController(title: "Sell Shares", message: "Choose your sell option:", preferredStyle: .alert)
            
            let marketSellAction = UIAlertAction(title: "Market Sell", style: .default) { (_) in
                self.showMarketSellPopup()
            }
            let limitSellAction = UIAlertAction(title: "Limit Sell", style: .default) { (_) in
                self.showLimitSellPopup()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(marketSellAction)
            alert.addAction(limitSellAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    
    
    //sell the stock using the price now
    private func showMarketSellPopup() {
            let alert = UIAlertController(title: "Market Sell", message: "Enter the number of shares to sell:", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.keyboardType = .numberPad
                textField.placeholder = "Number of shares"
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let sellAction = UIAlertAction(title: "Sell", style: .default) { (_) in
                if let sharesText = alert.textFields?.first?.text, let sharesAdd = Int(sharesText) {
                    let db = Firestore.firestore()
                    let orderUuid = UUID().uuidString
                    let timeInterval:TimeInterval = Date().timeIntervalSince1970
                    let timeStamp = Int(timeInterval)
                    let email = Auth.auth().currentUser?.email

                    db.collection("OrdersInfo").document(orderUuid).setData([
                                "userEmail": email,
                                "orderID": orderUuid,
                                "stockCode": self.stockName.text,
                                "type": "sell",
                                "quantity": sharesAdd,
                                "price": self.Stockprice.text,
                                "timestamp": timeStamp,
                                "Status":"Done"
                            ])
                    
                    
                    db.collection("Holdings").document(email!).getDocument { (document, error) in
                            if let document = document, document.exists {
                                var holdings = document.data()?["holdings"] as? [[String: Any]] ?? []
                                
                                // 检查是否已持有该股票
                                if let existingHoldingIndex = holdings.firstIndex(where: { $0["stockCode"] as? String == self.stockName.text }) {
                                    var existingHolding = holdings[existingHoldingIndex]
                                    var shares = existingHolding["shares"] as? Int ?? 0
                                    var avgCost = existingHolding["avgCost"] as? Double ?? 0.0
                                    
                                    // 如果持有股数大于等于要卖出的数量
                                    if shares >= sharesAdd {
                                        
                                        let totalValue = Double(shares) * avgCost
                                        shares -= sharesAdd
                                        let newAvgCost = (totalValue-(Double(sharesAdd) * (Double(self.Stockprice.text!) ?? 0.0))) / Double(shares)
                                        
                                        existingHolding["avgCost"] = round(newAvgCost * 100) / 100
                                        existingHolding["shares"] = shares
                                        
                                        // 如果卖出后股票数量为 0,从持仓列表中删除
                                        if shares == 0 {
                                            holdings.remove(at: existingHoldingIndex)
                                        } else {
                                            holdings[existingHoldingIndex] = existingHolding
                                        }
                                        
                                        // 更新持仓信息到 Firestore
                                        db.collection("Holdings").document(email!).updateData([
                                            "holdings": holdings
                                        ])
                                        let alert = UIAlertController(title: "Order made!💰", message: "Successfully sold this stock!✌️", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)

                                    } else {
                                        let alert = UIAlertController(title: "It doesn't look good...", message: "It seems you don't hold enough shares.", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                } else {
                                    let alert = UIAlertController(title: "Oh...", message: "You do not own this stock.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)

                                }
                            } else {
                                let alert = UIAlertController(title: "Sorry!🧎", message: "You do not own no holdings.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    
                    
                    
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(sellAction)
            
            present(alert, animated: true, completion: nil)
        }
     
    
    //set an expected price to sell
    private func showLimitSellPopup() {
            let alert = UIAlertController(title: "Limit Sell", message: "Enter the price and number of shares to sell:", preferredStyle: .alert)
            
            alert.addTextField { (priceTextField) in
                priceTextField.keyboardType = .decimalPad
                priceTextField.placeholder = "Price per share"
            }
            
            alert.addTextField { (sharesTextField) in
                sharesTextField.keyboardType = .numberPad
                sharesTextField.placeholder = "Number of shares"
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let sellAction = UIAlertAction(title: "Sell", style: .default) { (_) in
                if let priceText = alert.textFields?.first?.text, let sharesText = alert.textFields?.last?.text, let price = Double(priceText), let sharesAdd = Int(sharesText) {
                    
                    let db = Firestore.firestore()
                    let orderUuid = UUID().uuidString
                    let timeInterval:TimeInterval = Date().timeIntervalSince1970
                    let timeStamp = Int(timeInterval)
                    let email = Auth.auth().currentUser?.email
                    
                    

                    
                    if let pricenowText = self.Stockprice.text, let pricenow = Double(pricenowText), pricenow < price {
                        db.collection("Holdings").document(email!).getDocument { (document, error) in
                            if let document = document, document.exists {
                                var holdings = document.data()?["holdings"] as? [[String: Any]] ?? []
                                
                                // 检查是否已持有该股票
                                if let existingHoldingIndex = holdings.firstIndex(where: { $0["stockCode"] as? String == self.stockName.text }) {
                                    var existingHolding = holdings[existingHoldingIndex]
                                    var shares = existingHolding["shares"] as? Int ?? 0
                                    
                                    // 如果持有股数大于等于要卖出的数量
                                    if shares >= sharesAdd {
                                        
                                        db.collection("OrdersInfo").document(orderUuid).setData([
                                            "userEmail": email,
                                            "orderID": orderUuid,
                                            "stockCode": self.stockName.text,
                                            "type": "sell",
                                            "quantity": sharesAdd,
                                            "price": price,
                                            "timestamp": timeStamp,
                                            "Status":"Waiting"
                                        ])
                                        
                                        let alert = UIAlertController(title: "Order made!💰", message: "Waiting for CCP processing. . .", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                        
                                        
                                        
                                    } else {
                                        let alert = UIAlertController(title: "It doesn't look good...", message: "It seems you don't hold enough shares.", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                } else {
                                    let alert = UIAlertController(title: "Oh...", message: "You do not own this stock.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    
                                }
                            } else {
                                let alert = UIAlertController(title: "Sorry!🧎", message: "You do not own no holdings.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    else{
                        let alert = UIAlertController(title: "Oh, you have set a lower price.", message: "You can sell now or enter a new price.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK👌", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    
                    
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(sellAction)
            
            present(alert, animated: true, completion: nil)
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
