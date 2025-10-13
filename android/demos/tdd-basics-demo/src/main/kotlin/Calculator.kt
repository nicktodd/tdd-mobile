/**
 * Calculator class demonstrating TDD principles
 * 
 * This implementation follows the Red-Green-Refactor cycle:
 * 1. RED: Tests are written first and fail
 * 2. GREEN: Minimal code is written to pass tests
 * 3. REFACTOR: Code is improved without changing behavior
 */
class Calculator {
    
    private var lastResult: Double = 0.0
    private val history = mutableListOf<String>()
    
    /**
     * Adds two numbers together
     * @param a First number
     * @param b Second number  
     * @return Sum of a and b
     */
    fun add(a: Double, b: Double): Double {
        val result = a + b
        recordOperation("$a + $b = $result")
        lastResult = result
        return result
    }
    
    /**
     * Subtracts second number from first
     * @param a First number
     * @param b Number to subtract
     * @return Difference of a and b
     */
    fun subtract(a: Double, b: Double): Double {
        val result = a - b
        recordOperation("$a - $b = $result")
        lastResult = result
        return result
    }
    
    /**
     * Multiplies two numbers
     * @param a First number
     * @param b Second number
     * @return Product of a and b
     */
    fun multiply(a: Double, b: Double): Double {
        val result = a * b
        recordOperation("$a * $b = $result")
        lastResult = result
        return result
    }
    
    /**
     * Divides first number by second
     * @param a Dividend
     * @param b Divisor
     * @return Quotient of a divided by b
     * @throws IllegalArgumentException if divisor is zero
     */
    fun divide(a: Double, b: Double): Double {
        if (b == 0.0) {
            throw IllegalArgumentException("ERROR: Division by zero is not allowed")
        }
        val result = a / b
        recordOperation("$a / $b = $result")
        lastResult = result
        return result
    }
    
    /**
     * Calculates percentage of a number
     * @param value The base value
     * @param percentage The percentage to calculate
     * @return Percentage of the value
     */
    fun calculatePercentage(value: Double, percentage: Double): Double {
        val result = (value * percentage) / 100
        recordOperation("$percentage% of $value = $result")
        lastResult = result
        return result
    }
    
    /**
     * Gets the last calculated result
     * @return Last operation result
     */
    fun getLastResult(): Double = lastResult
    
    /**
     * Gets the calculation history
     * @return List of performed operations
     */
    fun getHistory(): List<String> = history.toList()
    
    /**
     * Clears the calculator memory and history
     */
    fun clear() {
        lastResult = 0.0
        history.clear()
    }
    
    /**
     * Records an operation in the history
     * @param operation String representation of the operation
     */
    private fun recordOperation(operation: String) {
        history.add(operation)
        println("CALCULATION: $operation")
    }
    
    /**
     * Validates input for basic arithmetic operations
     * @param a First operand
     * @param b Second operand
     * @return true if inputs are valid
     */
    fun validateInputs(a: Double, b: Double): Boolean {
        return !(a.isNaN() || b.isNaN() || a.isInfinite() || b.isInfinite())
    }
}
