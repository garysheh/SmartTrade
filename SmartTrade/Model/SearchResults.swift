//
//  SearchResults.swift
//  SmartTrade
//
//  Created by Gary She on 2024/5/27.
//

import Foundation

struct SearchResults: Decodable {
    let bestMatches: [SearchResults]
}

struct SearchResult: Decodable {
    let symbol: String
    let name: String
    let currency: String
    let type: String
}
