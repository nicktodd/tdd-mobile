//
//  UserListViewModelTests.swift
//  MVVMExampleTests
//
//  Tests for the UserListViewModel business logic
//

import XCTest
import Nimble
import Cuckoo
@testable import MVVMExample

/**
 * USER LIST VIEW MODEL TESTS
 *
 * These are the most important tests as they verify the business logic.
 * Key testing strategies:
 * 1. MOCK DEPENDENCIES: Use MockUserRepositoryProtocol to control repository behavior
 * 2. TEST PUBLISHED PROPERTIES: Verify @Published properties update correctly
 * 3. TEST COMMANDS: Verify user actions trigger correct repository calls
 * 4. TEST ERROR HANDLING: Verify error states are handled properly
 * 5. TEST COMPUTED PROPERTIES: Verify presentation logic works correctly
 */
class UserListViewModelTests: XCTestCase {
    
    var viewModel: UserListViewModel!
    var mockRepository: MockUserRepositoryProtocol!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepositoryProtocol()
        viewModel = UserListViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitializationLoadsUsers() {
        // Given
        let expectedUsers = User.mockUsers()
        stub(mockRepository) { stub in
            when(stub.getAllUsers()).thenReturn(expectedUsers)
        }
        
        // When
        let newViewModel = UserListViewModel(repository: mockRepository)
        
        // Then
        expect(newViewModel.users).to(equal(expectedUsers))
        verify(mockRepository).getAllUsers()
    }
    
    // MARK: - Load Users Tests
    
    func testLoadUsersSuccess() {
        // Given
        let expectedUsers = User.mockUsers()
        stub(mockRepository) { stub in
            when(stub.getAllUsers()).thenReturn(expectedUsers)
        }
        
        // When
        viewModel.loadUsers()
        
        // Then
        expect(self.viewModel.users).to(equal(expectedUsers))
        expect(self.viewModel.isLoading).to(beFalse())
        expect(self.viewModel.errorMessage).to(beNil())
        verify(mockRepository).getAllUsers()
    }
    
    func testLoadUsersShowsLoadingState() {
        // Given
        stub(mockRepository) { stub in
            when(stub.getAllUsers()).thenReturn([])
        }
        
        // When
        viewModel.loadUsers()
        
        // Then - Check that loading state is set immediately
        expect(self.viewModel.isLoading).to(beTrue())
        expect(self.viewModel.errorMessage).to(beNil())
    }
    
    // MARK: - Add User Tests
    
    func testAddUserSuccess() {
        // Given
        let userToAdd = User(id: 1, name: "New User")
        let allUsersAfterAdd = [userToAdd]
        
        stub(mockRepository) { stub in
            when(stub.addUser(any())).thenReturn(userToAdd)
            when(stub.getAllUsers()).thenReturn([]).thenReturn(allUsersAfterAdd)
        }
        
        viewModel.newUserName = "New User"
        
        // When
        viewModel.addUser()
        
        // Then
        expect(self.viewModel.users).to(equal(allUsersAfterAdd))
        expect(self.viewModel.newUserName).to(equal("")) // Should clear input
        expect(self.viewModel.isLoading).to(beFalse())
        
        verify(mockRepository).addUser(any())
        verify(mockRepository, times(2)).getAllUsers() // Once on init, once after add
    }
    
    func testAddUserWithEmptyName() {
        // Given
        viewModel.newUserName = "   " // Whitespace only
        
        // When
        viewModel.addUser()
        
        // Then
        expect(self.viewModel.errorMessage).to(equal("User name cannot be empty"))
        verifyNoMoreInteractions(mockRepository) // Should not call repository
    }
    
    func testAddUserTrimsWhitespace() {
        // Given
        let expectedUser = User(id: 1, name: "Trimmed User")
        stub(mockRepository) { stub in
            when(stub.addUser(any())).thenReturn(expectedUser)
            when(stub.getAllUsers()).thenReturn([]).thenReturn([expectedUser])
        }
        
        viewModel.newUserName = "  Trimmed User  "
        
        // When
        viewModel.addUser()
        
        // Then
        let argumentCaptor = ArgumentCaptor<User>()
        verify(mockRepository).addUser(argumentCaptor.capture())
        expect(argumentCaptor.value?.name).to(equal("Trimmed User"))
    }
    
    // MARK: - Delete User Tests
    
    func testDeleteUserSuccess() {
        // Given
        let remainingUsers = [User(id: 2, name: "Remaining User")]
        stub(mockRepository) { stub in
            when(stub.deleteUser(withId: 1)).thenReturn(true)
            when(stub.getAllUsers()).thenReturn([]).thenReturn(remainingUsers)
        }
        
        // When
        viewModel.deleteUser(withId: 1)
        
        // Then
        expect(self.viewModel.users).to(equal(remainingUsers))
        expect(self.viewModel.isLoading).to(beFalse())
        expect(self.viewModel.errorMessage).to(beNil())
        
        verify(mockRepository).deleteUser(withId: 1)
        verify(mockRepository, times(2)).getAllUsers()
    }
    
    func testDeleteUserFailure() {
        // Given
        stub(mockRepository) { stub in
            when(stub.deleteUser(withId: 999)).thenReturn(false)
            when(stub.getAllUsers()).thenReturn([])
        }
        
        // When
        viewModel.deleteUser(withId: 999)
        
        // Then
        expect(self.viewModel.errorMessage).to(equal("Failed to delete user. User not found."))
        expect(self.viewModel.isLoading).to(beFalse())
        
        verify(mockRepository).deleteUser(withId: 999)
    }
    
    // MARK: - Error Handling Tests
    
    func testClearError() {
        // Given
        viewModel.errorMessage = "Test error"
        
        // When
        viewModel.clearError()
        
        // Then
        expect(self.viewModel.errorMessage).to(beNil())
    }
}
