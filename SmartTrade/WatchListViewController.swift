//
//  WatchListViewController.swift
//  SmartTrade
//
//  Created by Gary She on 2024/5/25.
//

import UIKit
import Combine

class WatchListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: [SearchResult] = []
    @Published private var searchQuery = String()
    var emailID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tabBarController?.selectedIndex = 0
        performSearch()
    }
    
    private func performSearch() {
        let symbols = ["IBM", "AAPL", "GOOGL", "AMZN", "NDAQ", "MSFT"]
            let publishers = symbols.map { apiService.fetchSymbolsPublisher(symbol: $0) }
            
            Publishers.MergeMany(publishers)
                .map { data -> SearchResult? in
                    if let searchResults = try? JSONDecoder().decode(SearchResults.self, from: data) {
                        return searchResults.globalQuote
                    }
                    return nil
                }
                .collect()
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished:
                        break
                    }
                } receiveValue: { searchResults in
                    self.searchResults = searchResults.compactMap { $0 }
                    self.tableView.reloadData()
                }
                .store(in: &subscribers)
      }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> 
        Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "StockDetailViewController") as? StockDetailViewController {
            let selectedStock = searchResults[indexPath.row]
                        vc.stockData = selectedStock
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "stockId", for: indexPath) as! StockTableViewCell
            let searchResult = searchResults[indexPath.row]
            cell.configure(with: searchResult)
            return cell
        }
    
        @IBAction func TradeClicked(_ sender: UIButton) {
        
        
         
    }
 
}
