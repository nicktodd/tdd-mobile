//
//  CharacterTests.swift
//  StarwarsAPITests
//
//  Created by Nick Todd on 24/10/2025.
//

import XCTest
@testable import StarwarsAPI

/// Tests for the Character model
/// These tests verify that our model correctly encodes and decodes JSON data
final class CharacterTests: XCTestCase {
    
    // MARK: - Test: JSON Decoding
    
    /// Tests that a Character can be decoded from valid JSON
    ///
    /// Purpose: Ensures our model's Codable implementation correctly maps
    /// the snake_case JSON keys from SWAPI to our camelCase Swift properties
    ///
    /// What we're testing:
    /// - CodingKeys mapping works correctly
    /// - All properties are decoded properly
    /// - The Character model is Codable-compliant
    func testCharacterDecoding() throws {
        // GIVEN: Valid JSON data from SWAPI
        let json = """
        {
            "name": "Luke Skywalker",
            "height": "172",
            "mass": "77",
            "hair_color": "blond",
            "skin_color": "fair",
            "eye_color": "blue",
            "birth_year": "19BBY",
            "gender": "male",
            "url": "https://swapi.dev/api/people/1/"
        }
        """
        
        let jsonData = json.data(using: .utf8)!
        
        // WHEN: We decode the JSON into a Character object
        let decoder = JSONDecoder()
        let character = try decoder.decode(Character.self, from: jsonData)
        
        // THEN: All properties should be correctly decoded
        XCTAssertEqual(character.name, "Luke Skywalker", "Character name should match")
        XCTAssertEqual(character.height, "172", "Height should match")
        XCTAssertEqual(character.mass, "77", "Mass should match")
        XCTAssertEqual(character.hairColor, "blond", "Hair color should be mapped from snake_case")
        XCTAssertEqual(character.skinColor, "fair", "Skin color should be mapped from snake_case")
        XCTAssertEqual(character.eyeColor, "blue", "Eye color should be mapped from snake_case")
        XCTAssertEqual(character.birthYear, "19BBY", "Birth year should be mapped from snake_case")
        XCTAssertEqual(character.gender, "male", "Gender should match")
        XCTAssertEqual(character.url, "https://swapi.dev/api/people/1/", "URL should match")
    }
    
    // MARK: - Test: Identifiable Protocol
    
    /// Tests that the Character's id property uses the URL
    ///
    /// Purpose: Verifies that our computed 'id' property correctly uses
    /// the URL as the unique identifier for SwiftUI's Identifiable protocol
    ///
    /// Why this matters: SwiftUI's List and ForEach require Identifiable
    /// objects, and each character's URL is unique in SWAPI
    func testCharacterIdentifiable() throws {
        // GIVEN: A decoded character
        let json = """
        {
            "name": "Leia Organa",
            "height": "150",
            "mass": "49",
            "hair_color": "brown",
            "skin_color": "light",
            "eye_color": "brown",
            "birth_year": "19BBY",
            "gender": "female",
            "url": "https://swapi.dev/api/people/5/"
        }
        """
        
        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let character = try decoder.decode(Character.self, from: jsonData)
        
        // THEN: The id should be the URL
        XCTAssertEqual(character.id, "https://swapi.dev/api/people/5/",
                      "Character id should be the URL for uniqueness")
    }
    
    // MARK: - Test: JSON Encoding
    
    /// Tests that a Character can be encoded to JSON
    ///
    /// Purpose: Ensures our model can be encoded back to JSON format
    /// This is useful if we need to cache data or send it to another service
    func testCharacterEncoding() throws {
        // GIVEN: A Character object
        let character = Character(
            name: "Han Solo",
            height: "180",
            mass: "80",
            hairColor: "brown",
            skinColor: "fair",
            eyeColor: "brown",
            birthYear: "29BBY",
            gender: "male",
            url: "https://swapi.dev/api/people/14/"
        )
        
        // WHEN: We encode it to JSON
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(character)
        
        // THEN: We should be able to decode it back
        let decoder = JSONDecoder()
        let decodedCharacter = try decoder.decode(Character.self, from: jsonData)
        
        XCTAssertEqual(decodedCharacter.name, character.name, "Encoded and decoded character should match")
        XCTAssertEqual(decodedCharacter.id, character.id, "IDs should match")
    }
    
    // MARK: - Test: Invalid JSON Handling
    
    /// Tests that decoding fails gracefully with invalid JSON
    ///
    /// Purpose: Ensures our model throws appropriate errors when
    /// given malformed or incomplete JSON data
    ///
    /// Why this matters: In real-world scenarios, API responses might
    /// be malformed, and we need to handle these cases properly
    func testCharacterDecodingWithInvalidJSON() {
        // GIVEN: Invalid JSON (missing required fields)
        let invalidJson = """
        {
            "name": "Incomplete Character"
        }
        """
        
        let jsonData = invalidJson.data(using: .utf8)!
        
        // WHEN/THEN: Decoding should throw an error
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(Character.self, from: jsonData)) { error in
            // Verify it's a decoding error
            XCTAssertTrue(error is DecodingError, "Should throw a DecodingError")
        }
    }
}
