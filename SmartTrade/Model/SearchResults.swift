//
//  SearchResults.swift
//  SmartTrade
//
//  Created by Gary She on 2024/5/27.
//

import Foundation

struct SearchResults: Decodable {
    let globalQuote: SearchResult?

    enum CodingKeys: String, CodingKey {
        case globalQuote = "Global Quote"
    }
}

struct SearchResult: Decodable {
    let symbol: String
    let high: String
    let low: String
    let price: String


    enum CodingKeys: String, CodingKey {
        case symbol = "01. symbol"
        case high = "03. high"
        case low = "04. low"
        case price = "05. price"
    }
}