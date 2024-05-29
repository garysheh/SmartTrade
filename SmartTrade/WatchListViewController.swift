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
    private var searchResult: SearchResult?
    @Published private var searchQuery = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tabBarController?.selectedIndex = 0
        performSearch()
    }
    
    private func performSearch() {
        $searchQuery
            .debounce(for: .milliseconds(700), scheduler: RunLoop.main)
            .sink { [unowned self] (searchQuery) in
                self.apiService.fetchSymbolsPublisher(symbol: "S&P500").sink { (completion) in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished: break
                }
            } receiveValue: { (data) in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON Response: \(jsonString)")
                    }
                }.store(in: &self.subscribers)
            }.store(in: &subscribers)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> 
        Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
            UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "stockId", for: indexPath) as! StockTableViewCell
                if let searchResult = self.searchResult {
                    cell.configure(with: searchResult)
                }
                return cell
    }
    
    @IBAction func TradeClicked(_ sender: UIButton) {
        
        self.performSegue(withIdentifier:"trade", sender: self)
         
    }
    
}
