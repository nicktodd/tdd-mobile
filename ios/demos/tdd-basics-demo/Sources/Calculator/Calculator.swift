import Foundation

/**
 * Calculator class demonstrating TDD principles
 *
 * This implementation follows the Red-Green-Refactor cycle:
 * 1. RED: Tests are written first and fail
 * 2. GREEN: Minimal code is written to pass tests
 * 3. REFACTOR: Code is improved without changing behavior
 */
public class Calculator {
    
    private var lastResult: Double = 0.0
    private var history: [String] = []
    
    public init() {}
    
    /**
     * Adds two numbers together
     * - Parameters:
     *   - a: First number
     *   - b: Second number
     * - Returns: Sum of a and b
     */
    public func add(_ a: Double, _ b: Double) -> Double {
        let result = a + b
        recordOperation("\(a) + \(b) = \(result)")
        lastResult = result
        return result
    }
    
    /**
     * Subtracts second number from first
     * - Parameters:
     *   - a: First number
     *   - b: Number to subtract
     * - Returns: Difference of a and b
     */
    public func subtract(_ a: Double, _ b: Double) -> Double {
        let result = a - b
        recordOperation("\(a) - \(b) = \(result)")
        lastResult = result
        return result
    }
    
    /**
     * Multiplies two numbers
     * - Parameters:
     *   - a: First number
     *   - b: Second number
     * - Returns: Product of a and b
     */
    public func multiply(_ a: Double, _ b: Double) -> Double {
        let result = a * b
        recordOperation("\(a) * \(b) = \(result)")
        lastResult = result
        return result
    }
    
    /**
     * Divides first number by second
     * - Parameters:
     *   - a: Dividend
     *   - b: Divisor
     * - Returns: Quotient of a divided by b
     * - Throws: CalculatorError.divisionByZero if divisor is zero
     */
    public func divide(_ a: Double, _ b: Double) throws -> Double {
        guard b != 0.0 else {
            throw CalculatorError.divisionByZero("ERROR: Division by zero is not allowed")
        }
        let result = a / b
        recordOperation("\(a) / \(b) = \(result)")
        lastResult = result
        return result
    }
    
    /**
     * Calculates percentage of a number
     * - Parameters:
     *   - value: The base value
     *   - percentage: The percentage to calculate
     * - Returns: Percentage of the value
     */
    public func calculatePercentage(of value: Double, percentage: Double) -> Double {
        let result = (value * percentage) / 100
        recordOperation("\(percentage)% of \(value) = \(result)")
        lastResult = result
        return result
    }
    
    /**
     * Gets the last calculated result
     * - Returns: Last operation result
     */
    public func getLastResult() -> Double {
        return lastResult
    }
    
    /**
     * Gets the calculation history
     * - Returns: Array of performed operations
     */
    public func getHistory() -> [String] {
        return history
    }
    
    /**
     * Clears the calculator memory and history
     */
    public func clear() {
        lastResult = 0.0
        history.removeAll()
    }
    
    /**
     * Records an operation in the history
     * - Parameter operation: String representation of the operation
     */
    private func recordOperation(_ operation: String) {
        history.append(operation)
        print("CALCULATION: \(operation)")
    }
    
    /**
     * Validates input for basic arithmetic operations
     * - Parameters:
     *   - a: First operand
     *   - b: Second operand
     * - Returns: true if inputs are valid
     */
    public func validateInputs(_ a: Double, _ b: Double) -> Bool {
        return !(a.isNaN || b.isNaN || a.isInfinite || b.isInfinite)
    }
}

/**
 * Errors that can be thrown by Calculator operations
 */
public enum CalculatorError: Error, LocalizedError {
    case divisionByZero(String)
    
    public var errorDescription: String? {
        switch self {
        case .divisionByZero(let message):
            return message
        }
    }
}
