//
//  StockDetailViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/5/30.
//

import UIKit

class StockDetailViewController: UIViewController {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
