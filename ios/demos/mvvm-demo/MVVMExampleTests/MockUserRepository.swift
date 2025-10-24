//
//  MockUserRepository.swift
//  MVVMExampleTests
//
//  Manual mock implementation of UserRepositoryProtocol for testing
//

import Foundation
@testable import MVVMExample

/**
 * MANUAL MOCK REPOSITORY
 *
 * This is a simple, hand-written mock that implements UserRepositoryProtocol.
 * 
 * Why Manual Mocks?
 * 1. SIMPLE: Easy to understand and maintain
 * 2. NO DEPENDENCIES: No external frameworks needed
 * 3. EDUCATIONAL: Shows exactly how mocking works
 * 4. FLEXIBLE: Can be customized for specific test scenarios
 * 5. RELIABLE: No setup issues or build phase complexity
 *
 * How It Works:
 * - Each method has a corresponding "ReturnValue" property to control what it returns
 * - Each method has a "Called" or "CalledWith" property to verify it was called
 * - Tests set up the return values before using the mock
 * - Tests verify the mock was called correctly after the test
 */
class MockUserRepository: UserRepositoryProtocol {
    
    // MARK: - getAllUsers Mock Properties
    
    /// Tracks whether getAllUsers() was called
    var getAllUsersCalled = false
    
    /// Tracks how many times getAllUsers() was called
    var getAllUsersCallCount = 0
    
    /// The value to return when getAllUsers() is called
    var getAllUsersReturnValue: [User] = []
    
    func getAllUsers() -> [User] {
        getAllUsersCalled = true
        getAllUsersCallCount += 1
        return getAllUsersReturnValue
    }
    
    // MARK: - getUserById Mock Properties
    
    /// Stores the ID that was passed to getUserById()
    var getUserByIdCalledWith: Int?
    
    /// Tracks how many times getUserById() was called
    var getUserByIdCallCount = 0
    
    /// The value to return when getUserById() is called
    var getUserByIdReturnValue: User?
    
    func getUserById(_ id: Int) -> User? {
        getUserByIdCalledWith = id
        getUserByIdCallCount += 1
        return getUserByIdReturnValue
    }
    
    // MARK: - addUser Mock Properties
    
    /// Stores the User that was passed to addUser()
    var addUserCalledWith: User?
    
    /// Tracks how many times addUser() was called
    var addUserCallCount = 0
    
    /// The value to return when addUser() is called
    /// If nil, returns the input user with a generated ID
    var addUserReturnValue: User?
    
    func addUser(_ user: User) -> User {
        addUserCalledWith = user
        addUserCallCount += 1
        
        if let returnValue = addUserReturnValue {
            return returnValue
        }
        
        // Default behavior: return user with ID
        return User(id: addUserCallCount, name: user.name)
    }
    
    // MARK: - deleteUser Mock Properties
    
    /// Stores the ID that was passed to deleteUser()
    var deleteUserCalledWith: Int?
    
    /// Tracks how many times deleteUser() was called
    var deleteUserCallCount = 0
    
    /// The value to return when deleteUser() is called
    var deleteUserReturnValue = false
    
    func deleteUser(withId id: Int) -> Bool {
        deleteUserCalledWith = id
        deleteUserCallCount += 1
        return deleteUserReturnValue
    }
    
    // MARK: - updateUser Mock Properties
    
    /// Stores the User that was passed to updateUser()
    var updateUserCalledWith: User?
    
    /// Tracks how many times updateUser() was called
    var updateUserCallCount = 0
    
    /// The value to return when updateUser() is called
    var updateUserReturnValue: User?
    
    func updateUser(_ user: User) -> User? {
        updateUserCalledWith = user
        updateUserCallCount += 1
        return updateUserReturnValue
    }
    
    // MARK: - Helper Methods
    
    /// Resets all mock state - useful if you reuse a mock across tests
    func reset() {
        getAllUsersCalled = false
        getAllUsersCallCount = 0
        getAllUsersReturnValue = []
        
        getUserByIdCalledWith = nil
        getUserByIdCallCount = 0
        getUserByIdReturnValue = nil
        
        addUserCalledWith = nil
        addUserCallCount = 0
        addUserReturnValue = nil
        
        deleteUserCalledWith = nil
        deleteUserCallCount = 0
        deleteUserReturnValue = false
        
        updateUserCalledWith = nil
        updateUserCallCount = 0
        updateUserReturnValue = nil
    }
}
