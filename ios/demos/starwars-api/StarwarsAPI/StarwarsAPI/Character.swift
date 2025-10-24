//
//  Character.swift
//  StarwarsAPI
//
//  Created by Nick Todd on 24/10/2025.
//

import Foundation

/// Represents a Star Wars character from the SWAPI
struct Character: Codable, Identifiable {
    let name: String
    let height: String
    let mass: String
    let hairColor: String
    let skinColor: String
    let eyeColor: String
    let birthYear: String
    let gender: String
    let url: String
    
    // Computed property for SwiftUI's Identifiable protocol
    var id: String { url }
    
    // Map JSON snake_case to Swift camelCase
    enum CodingKeys: String, CodingKey {
        case name
        case height
        case mass
        case hairColor = "hair_color"
        case skinColor = "skin_color"
        case eyeColor = "eye_color"
        case birthYear = "birth_year"
        case gender
        case url
    }
}
