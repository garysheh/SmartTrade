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

class StockDetailViewController: UIViewController {
    @IBOutlet weak var BuyButton: UIButton!
    @IBOutlet weak var SellButton: UIButton!
    @IBOutlet weak var Stockprice: UILabel!
    @IBOutlet weak var stockName: UILabel!
    @IBOutlet weak var preTime: UILabel!
    
    var stockData: SearchResult?
    
    override func viewDidLoad() {
            super.viewDidLoad()

            // Do any additional setup after loading the view.
            if let stockData = stockData {
                Stockprice.text = stockData.high
                stockName.text = stockData.symbol
                preTime.text = "Latest.Trade" + stockData.day
            }
        }
    
    @IBAction func BuyButtonTapped(_ sender: Any) {
        showBuyOptionPopup()
    }
    
    
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
                                        shares += sharesAdd
                                        existingHolding["shares"] = shares
                                        holdings[existingHoldingIndex] = existingHolding
                                        
                                        // 更新持仓信息到 Firestore
                                        db.collection("Holdings").document(email!).updateData([
                                            "holdings": holdings
                                        ])
                                    }else {
                                        // 添加新的持仓记录
                                        holdings.append([
                                            "stockCode": self.stockName.text,
                                            "shares": sharesAdd
                                        ])
                                        
                                        // 更新持仓信息到 Firestore
                                        db.collection("Holdings").document(email!).updateData([
                                            "holdings": holdings
                                        ])
                                    }
                                } else {
                                    // 如果用户尚未持有任何股票,创建一个新的持仓记录
                                    db.collection("Holdings").document(email!).setData([
                                        "email": email,
                                        "holdings": [
                                            ["stockCode": self.stockName.text, "shares": sharesAdd]
                                        ]
                                    ])
                                }
                            }
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(buyAction)
            
            present(alert, animated: true, completion: nil)
        }
    
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
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(buyAction)
            
            present(alert, animated: true, completion: nil)
        }

    
    
    
    @IBAction func SellButtonTapped(_ sender: Any) {
        showSellOptionPopup()
    }
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
                                    
                                    // 如果持有股数大于等于要卖出的数量
                                    if shares >= sharesAdd {
                                        shares -= sharesAdd
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
                                    } else {
                                        // 股票数量不足,无法完成卖出
                                        print("Insufficient shares to sell.")
                                    }
                                } else {
                                    // 用户未持有该股票,无法卖出
                                    print("You do not own this stock.")
                                }
                            } else {
                                // 用户尚未持有任何股票
                                print("No holdings found.")
                            }
                        }
                    
                    
                    
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(sellAction)
            
            present(alert, animated: true, completion: nil)
        }
        
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

                    db.collection("OrdersInfo").document(orderUuid).setData([
                                "userEmail": email,
                                "orderID": orderUuid,
                                "stockCode": self.stockName.text,
                                "type": "sell",
                                "quantity": sharesAdd,
                                "price": self.Stockprice.text,
                                "timestamp": timeStamp,
                                "Status":"Waiting"
                            ])
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