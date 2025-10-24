//
//  MockUserRepository.swift
//  MVVMExampleTests
//
//  Mock implementation of UserRepositoryProtocol for testing
//

import Cuckoo
@testable import MVVMExample

/**
 * MOCK USER REPOSITORY
 *
 * This demonstrates how to create a mock using Cuckoo.
 * The mock allows us to:
 * 1. Control the behavior of dependencies in tests
 * 2. Verify that the ViewModel calls the repository correctly
 * 3. Test error scenarios by making the mock return specific values
 * 4. Isolate the ViewModel from the actual repository implementation
 */
class MockUserRepositoryProtocol: UserRepositoryProtocol, Mock {
    
    func getAllUsers() -> [User] {
        return cuckoo_manager.call("getAllUsers() -> [User]",
                                 parameters: (),
                                 escapingParameters: ()) as [User]
    }
    
    func getUserById(_ id: Int) -> User? {
        return cuckoo_manager.call("getUserById(Int) -> User?",
                                 parameters: (id),
                                 escapingParameters: (id)) as User?
    }
    
    func addUser(_ user: User) -> User {
        return cuckoo_manager.call("addUser(User) -> User",
                                 parameters: (user),
                                 escapingParameters: (user)) as User
    }
    
    func deleteUser(withId id: Int) -> Bool {
        return cuckoo_manager.call("deleteUser(withId: Int) -> Bool",
                                 parameters: (id),
                                 escapingParameters: (id)) as Bool
    }
    
    func updateUser(_ user: User) -> User? {
        return cuckoo_manager.call("updateUser(User) -> User?",
                                 parameters: (user),
                                 escapingParameters: (user)) as User?
    }
    
    var cuckoo_manager = CuckooManager()
}
