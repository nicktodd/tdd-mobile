//
//  UserListViewModelPresentationTests.swift
//  MVVMExampleTests
//
//  Tests for the presentation logic and computed properties of UserListViewModel
//

import XCTest
import Nimble
import Cuckoo
@testable import MVVMExample

/**
 * USER LIST VIEW MODEL PRESENTATION TESTS
 *
 * These tests focus specifically on the presentation logic and computed properties
 * that determine what should be displayed in the UI. They are separated from
 * business logic tests for better organization and maintainability.
 */
class UserListViewModelPresentationTests: XCTestCase {
    
    var viewModel: UserListViewModel!
    var mockRepository: MockUserRepositoryProtocol!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepositoryProtocol()
        
        // Stub basic repository calls to avoid side effects
        stub(mockRepository) { stub in
            when(stub.getAllUsers()).thenReturn([])
        }
        
        viewModel = UserListViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Computed Properties Tests
    
    func testCanAddUserWhenNameIsValid() {
        // Given
        viewModel.newUserName = "Valid Name"
        viewModel.isLoading = false
        
        // Then
        expect(self.viewModel.canAddUser).to(beTrue())
    }
    
    func testCanAddUserWhenNameIsEmpty() {
        // Given
        viewModel.newUserName = ""
        viewModel.isLoading = false
        
        // Then
        expect(self.viewModel.canAddUser).to(beFalse())
    }
    
    func testCanAddUserWhenNameIsWhitespace() {
        // Given
        viewModel.newUserName = "   "
        viewModel.isLoading = false
        
        // Then
        expect(self.viewModel.canAddUser).to(beFalse())
    }
    
    func testCanAddUserWhenLoading() {
        // Given
        viewModel.newUserName = "Valid Name"
        viewModel.isLoading = true
        
        // Then
        expect(self.viewModel.canAddUser).to(beFalse())
    }
    
    func testUserCountTextSingular() {
        // Given
        viewModel.users = [User.mockUser()]
        
        // Then
        expect(self.viewModel.userCountText).to(equal("1 User"))
    }
    
    func testUserCountTextPlural() {
        // Given
        viewModel.users = User.mockUsers() // 3 users
        
        // Then
        expect(self.viewModel.userCountText).to(equal("3 Users"))
    }
    
    func testUserCountTextZero() {
        // Given
        viewModel.users = []
        
        // Then
        expect(self.viewModel.userCountText).to(equal("0 Users"))
    }
    
    // MARK: - State Combination Tests
    
    func testLoadingStateWithUsers() {
        // Given
        viewModel.users = User.mockUsers()
        viewModel.isLoading = true
        
        // Then
        expect(self.viewModel.userCountText).to(equal("3 Users")) // Should still show count
        expect(self.viewModel.canAddUser).to(beFalse()) // But can't add while loading
    }
    
    func testErrorStateDisplays() {
        // Given
        let errorMessage = "Something went wrong"
        viewModel.errorMessage = errorMessage
        
        // Then
        expect(self.viewModel.errorMessage).to(equal(errorMessage))
        expect(self.viewModel.errorMessage).toNot(beNil())
    }
    
    func testClearingErrorState() {
        // Given
        viewModel.errorMessage = "Error message"
        
        // When
        viewModel.clearError()
        
        // Then
        expect(self.viewModel.errorMessage).to(beNil())
    }
}
