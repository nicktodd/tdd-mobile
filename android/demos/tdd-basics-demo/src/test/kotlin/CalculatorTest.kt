import org.junit.jupiter.api.*
import org.junit.jupiter.api.Assertions.*

/**
 * Test class demonstrating TDD Red-Green-Refactor cycle
 * 
 * This test suite shows how TDD works in practice:
 * - Tests are written BEFORE implementation
 * - Each test drives the design of the production code
 * - Refactoring happens with confidence due to test coverage
 */
class CalculatorTest {
    
    private lateinit var calculator: Calculator
    
    @BeforeEach
    fun setUp() {
        calculator = Calculator()
        println("SETUP: Creating new Calculator instance")
    }
    
    @AfterEach
    fun tearDown() {
        println("TEARDOWN: Test completed")
    }
    
    @Nested
    @DisplayName("RED Phase - Tests Written First (These Would Initially Fail)")
    inner class RedPhaseTests {
        
        @Test
        @DisplayName("RED: Addition should return sum of two numbers")
        fun testAdditionRedPhase() {
            // This test was written FIRST, before Calculator.add() existed
            println("TEST: Red phase - testing addition")
            val result = calculator.add(2.0, 3.0)
            assertEquals(5.0, result)
        }
        
        @Test
        @DisplayName("RED: Division by zero should throw exception")
        fun testDivisionByZeroRedPhase() {
            println("TEST: Red phase - testing division by zero")
            assertThrows<IllegalArgumentException> {
                calculator.divide(10.0, 0.0)
            }
        }
    }
    
    @Nested
    @DisplayName("GREEN Phase - Minimal Implementation to Pass Tests")
    inner class GreenPhaseTests {
        
        @Test
        @DisplayName("GREEN: Basic arithmetic operations work")
        fun testBasicArithmeticGreenPhase() {
            println("TEST: Green phase - basic operations")
            assertEquals(5.0, calculator.add(2.0, 3.0))
            assertEquals(2.0, calculator.subtract(5.0, 3.0))
            assertEquals(15.0, calculator.multiply(3.0, 5.0))
            assertEquals(4.0, calculator.divide(12.0, 3.0))
        }
    }
    
    @Nested
    @DisplayName("REFACTOR Phase - Improved Implementation with Enhanced Features")
    inner class RefactorPhaseTests {
        
        @Test
        @DisplayName("Calculator should handle positive numbers correctly")
        fun testPositiveNumbers() {
            assertEquals(8.0, calculator.add(3.0, 5.0))
            assertEquals(2.0, calculator.subtract(7.0, 5.0))
        }
        
        @Test
        @DisplayName("Calculator should handle negative numbers correctly")
        fun testNegativeNumbers() {
            assertEquals(-2.0, calculator.add(-5.0, 3.0))
            assertEquals(-8.0, calculator.subtract(-5.0, 3.0))
        }
        
        @Test
        @DisplayName("Calculator should handle decimal numbers correctly")
        fun testDecimalNumbers() {
            assertEquals(5.5, calculator.add(2.2, 3.3), 0.001)
            assertEquals(6.25, calculator.multiply(2.5, 2.5))
        }
        
        @Test
        @DisplayName("Division should handle floating point results")
        fun testDivisionWithFloatingPoint() {
            val result = calculator.divide(10.0, 3.0)
            assertEquals(3.333, result, 0.001)
        }
        
        @Test
        @DisplayName("Division by zero should provide meaningful error message")
        fun testDivisionByZeroErrorMessage() {
            val exception = assertThrows<IllegalArgumentException> {
                calculator.divide(10.0, 0.0)
            }
            assertTrue(exception.message!!.contains("ERROR: Division by zero"))
        }
        
        @Test
        @DisplayName("Calculator should track last result")
        fun testLastResultTracking() {
            calculator.add(5.0, 3.0)
            assertEquals(8.0, calculator.getLastResult())
            
            calculator.multiply(2.0, 4.0)
            assertEquals(8.0, calculator.getLastResult())
        }
        
        @Test
        @DisplayName("Calculator should maintain operation history")
        fun testOperationHistory() {
            calculator.add(2.0, 3.0)
            calculator.subtract(10.0, 4.0)
            
            val history = calculator.getHistory()
            assertEquals(2, history.size)
            assertTrue(history[0].contains("2.0 + 3.0 = 5.0"))
            assertTrue(history[1].contains("10.0 - 4.0 = 6.0"))
        }
        
        @Test
        @DisplayName("Calculator should handle percentage calculations")
        fun testPercentageCalculation() {
            val result = calculator.calculatePercentage(200.0, 15.0)
            assertEquals(30.0, result)
        }
        
        @Test
        @DisplayName("Calculator should validate inputs")
        fun testInputValidation() {
            assertTrue(calculator.validateInputs(5.0, 3.0))
            assertFalse(calculator.validateInputs(Double.NaN, 3.0))
            assertFalse(calculator.validateInputs(5.0, Double.POSITIVE_INFINITY))
        }
        
        @Test
        @DisplayName("Calculator should allow clearing memory")
        fun testClearFunctionality() {
            calculator.add(5.0, 3.0)
            calculator.subtract(10.0, 2.0)
            
            assertEquals(2, calculator.getHistory().size)
            assertEquals(8.0, calculator.getLastResult())
            
            calculator.clear()
            
            assertEquals(0, calculator.getHistory().size)
            assertEquals(0.0, calculator.getLastResult())
        }
    }
    
    @Nested
    @DisplayName("TDD Benefits Demonstration")
    inner class TDDBenefitsTests {
        
        @Test
        @DisplayName("BENEFIT: Early bug detection - Edge case handling")
        fun testEarlyBugDetection() {
            // TDD helps catch edge cases early
            assertDoesNotThrow {
                calculator.add(Double.MAX_VALUE, 1.0)
            }
        }
        
        @Test
        @DisplayName("BENEFIT: Design clarity - Clear method contracts")
        fun testDesignClarity() {
            // Tests document expected behavior
            val result = calculator.add(0.0, 0.0)
            assertEquals(0.0, result)
            
            val history = calculator.getHistory()
            assertFalse(history.isEmpty())
        }
        
        @Test
        @DisplayName("BENEFIT: Refactoring confidence - Behavior preservation")
        fun testRefactoringConfidence() {
            // These tests ensure refactoring doesn't break functionality
            val originalResult = calculator.multiply(6.0, 7.0)
            assertEquals(42.0, originalResult)
            
            // If we refactor multiply() method, this test ensures it still works
            calculator.clear()
            val refactoredResult = calculator.multiply(6.0, 7.0)
            assertEquals(42.0, refactoredResult)
        }
    }
    
    @Nested
    @DisplayName("Mobile Development Specific Tests")
    inner class MobileTDDTests {
        
        @Test
        @DisplayName("MOBILE: Performance consideration - Fast calculations")
        fun testPerformanceRequirement() {
            val startTime = System.currentTimeMillis()
            
            repeat(1000) {
                calculator.add(it.toDouble(), (it + 1).toDouble())
            }
            
            val endTime = System.currentTimeMillis()
            val executionTime = endTime - startTime
            
            // Ensure calculations complete within reasonable time for mobile
            assertTrue(executionTime < 100, "Calculations should complete quickly on mobile devices")
        }
        
        @Test
        @DisplayName("MOBILE: Memory efficiency - Limited history size")
        fun testMemoryEfficiency() {
            // Mobile devices have limited memory
            repeat(1000) {
                calculator.add(1.0, 1.0)
            }
            
            val historySize = calculator.getHistory().size
            println("PERFORMANCE: History size after 1000 operations: $historySize")
            
            // In a real mobile app, we might limit history size
            assertTrue(historySize <= 1000, "History should not grow unbounded")
        }
    }
}
