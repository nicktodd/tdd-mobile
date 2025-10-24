//
//  CharacterResponse.swift
//  StarwarsAPI
//
//  Created by Nick Todd on 24/10/2025.
//

import Foundation

/// Represents the API response wrapper from SWAPI's /people/ endpoint
struct CharacterResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Character]
}
