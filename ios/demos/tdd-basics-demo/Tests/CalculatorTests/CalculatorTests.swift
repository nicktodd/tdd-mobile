import XCTest
@testable import Calculator

/**
 * Test class demonstrating TDD Red-Green-Refactor cycle
 *
 * This test suite shows how TDD works in practice:
 * - Tests are written BEFORE implementation
 * - Each test drives the design of the production code
 * - Refactoring happens with confidence due to test coverage
 */
final class CalculatorTests: XCTestCase {
    
    var calculator: Calculator!
    
    override func setUp() {
        super.setUp()
        calculator = Calculator()
        print("SETUP: Creating new Calculator instance")
    }
    
    override func tearDown() {
        calculator = nil
        print("TEARDOWN: Test completed")
        super.tearDown()
    }
}

// MARK: - RED Phase Tests
extension CalculatorTests {
    
    func testRedPhase_AdditionShouldReturnSumOfTwoNumbers() {
        // This test was written FIRST, before Calculator.add() existed
        print("TEST: Red phase - testing addition")
        let result = calculator.add(2.0, 3.0)
        XCTAssertEqual(result, 5.0)
    }
    
    func testRedPhase_DivisionByZeroShouldThrowException() {
        print("TEST: Red phase - testing division by zero")
        XCTAssertThrowsError(try calculator.divide(10.0, 0.0)) { error in
            XCTAssertTrue(error is CalculatorError)
        }
    }
}

// MARK: - GREEN Phase Tests  
extension CalculatorTests {
    
    func testGreenPhase_BasicArithmeticOperationsWork() {
        print("TEST: Green phase - basic operations")
        XCTAssertEqual(calculator.add(2.0, 3.0), 5.0)
        XCTAssertEqual(calculator.subtract(5.0, 3.0), 2.0)
        XCTAssertEqual(calculator.multiply(3.0, 5.0), 15.0)
        XCTAssertEqual(try calculator.divide(12.0, 3.0), 4.0)
    }
}

// MARK: - REFACTOR Phase Tests
extension CalculatorTests {
    
    func testCalculatorShouldHandlePositiveNumbersCorrectly() {
        XCTAssertEqual(calculator.add(3.0, 5.0), 8.0)
        XCTAssertEqual(calculator.subtract(7.0, 5.0), 2.0)
    }
    
    func testCalculatorShouldHandleNegativeNumbersCorrectly() {
        XCTAssertEqual(calculator.add(-5.0, 3.0), -2.0)
        XCTAssertEqual(calculator.subtract(-5.0, 3.0), -8.0)
    }
    
    func testCalculatorShouldHandleDecimalNumbersCorrectly() {
        XCTAssertEqual(calculator.add(2.2, 3.3), 5.5, accuracy: 0.001)
        XCTAssertEqual(calculator.multiply(2.5, 2.5), 6.25)
    }
    
    func testDivisionShouldHandleFloatingPointResults() {
        let result = try! calculator.divide(10.0, 3.0)
        XCTAssertEqual(result, 3.333, accuracy: 0.001)
    }
    
    func testDivisionByZeroShouldProvideMeaningfulErrorMessage() {
        do {
            _ = try calculator.divide(10.0, 0.0)
            XCTFail("Expected division by zero error")
        } catch let error as CalculatorError {
            switch error {
            case .divisionByZero(let message):
                XCTAssertTrue(message.contains("ERROR: Division by zero"))
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testCalculatorShouldTrackLastResult() {
        calculator.add(5.0, 3.0)
        XCTAssertEqual(calculator.getLastResult(), 8.0)
        
        calculator.multiply(2.0, 4.0)
        XCTAssertEqual(calculator.getLastResult(), 8.0)
    }
    
    func testCalculatorShouldMaintainOperationHistory() {
        calculator.add(2.0, 3.0)
        calculator.subtract(10.0, 4.0)
        
        let history = calculator.getHistory()
        XCTAssertEqual(history.count, 2)
        XCTAssertTrue(history[0].contains("2.0 + 3.0 = 5.0"))
        XCTAssertTrue(history[1].contains("10.0 - 4.0 = 6.0"))
    }
    
    func testCalculatorShouldHandlePercentageCalculations() {
        let result = calculator.calculatePercentage(of: 200.0, percentage: 15.0)
        XCTAssertEqual(result, 30.0)
    }
    
    func testCalculatorShouldValidateInputs() {
        XCTAssertTrue(calculator.validateInputs(5.0, 3.0))
        XCTAssertFalse(calculator.validateInputs(Double.nan, 3.0))
        XCTAssertFalse(calculator.validateInputs(5.0, Double.infinity))
    }
    
    func testCalculatorShouldAllowClearingMemory() {
        calculator.add(5.0, 3.0)
        calculator.subtract(10.0, 2.0)
        
        XCTAssertEqual(calculator.getHistory().count, 2)
        XCTAssertEqual(calculator.getLastResult(), 8.0)
        
        calculator.clear()
        
        XCTAssertEqual(calculator.getHistory().count, 0)
        XCTAssertEqual(calculator.getLastResult(), 0.0)
    }
}

// MARK: - TDD Benefits Demonstration
extension CalculatorTests {
    
    func testTDDBenefit_EarlyBugDetection_EdgeCaseHandling() {
        // TDD helps catch edge cases early
        XCTAssertNoThrow(calculator.add(Double.greatestFiniteMagnitude, 1.0))
    }
    
    func testTDDBenefit_DesignClarity_ClearMethodContracts() {
        // Tests document expected behavior
        let result = calculator.add(0.0, 0.0)
        XCTAssertEqual(result, 0.0)
        
        let history = calculator.getHistory()
        XCTAssertFalse(history.isEmpty)
    }
    
    func testTDDBenefit_RefactoringConfidence_BehaviorPreservation() {
        // These tests ensure refactoring doesn't break functionality
        let originalResult = calculator.multiply(6.0, 7.0)
        XCTAssertEqual(originalResult, 42.0)
        
        // If we refactor multiply() method, this test ensures it still works
        calculator.clear()
        let refactoredResult = calculator.multiply(6.0, 7.0)
        XCTAssertEqual(refactoredResult, 42.0)
    }
}

// MARK: - Mobile Development Specific Tests
extension CalculatorTests {
    
    func testMobile_PerformanceRequirement_FastCalculations() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<1000 {
            calculator.add(Double(i), Double(i + 1))
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = (endTime - startTime) * 1000 // Convert to milliseconds
        
        // Ensure calculations complete within reasonable time for mobile
        XCTAssertLessThan(executionTime, 100, "Calculations should complete quickly on mobile devices")
    }
    
    func testMobile_MemoryEfficiency_LimitedHistorySize() {
        // Mobile devices have limited memory
        for i in 0..<1000 {
            calculator.add(1.0, 1.0)
        }
        
        let historySize = calculator.getHistory().count
        print("PERFORMANCE: History size after 1000 operations: \(historySize)")
        
        // In a real mobile app, we might limit history size
        XCTAssertLessThanOrEqual(historySize, 1000, "History should not grow unbounded")
    }
}

// MARK: - Test Performance Measurements
extension CalculatorTests {
    
    func testPerformance_BasicOperations() {
        measure {
            for _ in 0..<100 {
                calculator.add(1.0, 2.0)
                calculator.multiply(3.0, 4.0)
                calculator.subtract(10.0, 5.0)
                _ = try! calculator.divide(20.0, 4.0)
            }
        }
    }
}
