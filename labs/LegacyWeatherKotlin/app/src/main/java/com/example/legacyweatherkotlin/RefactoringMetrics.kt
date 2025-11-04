package com.example.legacyweatherkotlin

/**
 * Baseline Metrics for Legacy Refactoring Exercise
 * 
 * Use this file to track your progress during the TDD refactoring exercise.
 * Fill in the measurements before and after each phase to see your improvement.
 * 
 * HOW TO MEASURE:
 * - Lines of Code: Count non-comment, non-blank lines
 * - Cyclomatic Complexity: Count decision points (if, when, &&, ||, loops)
 * - Method Count: Count public methods in each class
 * - Test Coverage: Percentage of code covered by tests
 */
object RefactoringMetrics {
    
    /**
     * BASELINE MEASUREMENTS (Before Starting)
     * Fill these in by examining the current legacy code
     */
    object Baseline {
        const val MAIN_ACTIVITY_LINES = 627          // MainActivity.kt total lines
        const val WEATHER_SINGLETON_LINES = 259     // WeatherSingleton.kt total lines (updated after fixes)
        const val CONSTANTS_LINES = 90              // Constants.kt total lines
        
        const val MAIN_ACTIVITY_PUBLIC_METHODS = 15  // Public methods in MainActivity
        const val WEATHER_SINGLETON_PUBLIC_METHODS = 12 // Public methods in WeatherSingleton
        
        const val HARDCODED_VALUES_COUNT = 25        // Magic numbers and strings
        const val SINGLETON_DEPENDENCIES = 8         // Classes that directly use WeatherSingleton
        
        const val CYCLOMATIC_COMPLEXITY_MAIN = 45    // Decision points in MainActivity
        const val CYCLOMATIC_COMPLEXITY_SINGLETON = 20 // Decision points in WeatherSingleton
        
        const val TESTABLE_METHODS = 0               // Methods that can be unit tested
        const val TEST_COVERAGE_PERCENT = 0          // Current test coverage
        
        const val CLASSES_WITH_SINGLE_RESPONSIBILITY = 0 // Classes following SRP
        const val INTERFACES_COUNT = 1               // Current interfaces (only WeatherService)
    }
    
    /**
     * PHASE 1 MEASUREMENTS (After Characterization Testing)
     * Fill these in after completing Phase 1
     */
    object Phase1Results {
        var characterization_tests_written = 0       // Number of characterization tests
        var behaviors_documented = 0                 // Number of documented behaviors  
        var edge_cases_captured = 0                  // Number of edge cases found
        var baseline_established = false             // Safety net created?
        
        // Code metrics should be mostly unchanged after Phase 1
        var main_activity_lines = Baseline.MAIN_ACTIVITY_LINES
        var weather_singleton_lines = Baseline.WEATHER_SINGLETON_LINES
        var test_coverage_percent = 0                // Still low, just characterization tests
        
        // Confidence metrics
        var confidence_in_current_behavior = ""      // High/Medium/Low
        var ready_for_refactoring = false           // Feel safe to start changing code?
    }
    
    /**
     * PHASE 2 MEASUREMENTS (After Dependency Breaking)  
     * Fill these in after completing Phase 2
     */
    object Phase2Results {
        var seams_created = 0                        // Extension points added
        var dependencies_made_injectable = 0         // Dependencies that can now be injected
        var test_doubles_created = 0                 // Mocks, fakes, stubs created
        var interfaces_extracted = 0                 // New interfaces created
        
        var methods_extracted = 0                    // Methods pulled out for testing
        var utility_classes_created = 0             // New focused utility classes
        var testable_methods = 0                     // Methods now testable in isolation
        
        var test_coverage_percent = 0                // Should be higher now
        var unit_tests_written = 0                  // Actual unit tests (not just characterization)
        
        // Architecture improvements  
        var classes_with_single_responsibility = 0   // Classes now following SRP better
        var dependency_injection_points = 0         // Places where DI is now possible
    }
    
    /**
     * PHASE 3 MEASUREMENTS (After Architecture Refactoring)
     * Fill these in after completing Phase 3
     */
    object Phase3Results {
        var singletons_eliminated = 0                // Singleton anti-patterns removed
        var viewmodels_created = 0                   // Proper ViewModels implemented
        var repositories_created = 0                 // Repository pattern implementations
        var use_cases_created = 0                    // Use case/interactor classes
        
        var main_activity_lines = 0                  // Should be much smaller now
        var weather_singleton_lines = 0              // Should be eliminated or much smaller
        var total_classes_created = 0               // New classes from refactoring
        
        var test_coverage_percent = 0                // Should be high (>80%)
        var unit_tests_written = 0                   // Total unit tests
        var integration_tests_written = 0           // Integration tests
        
        var cyclomatic_complexity_reduction = 0      // Complexity reduction percentage
        var maintainability_improvement = ""         // High/Medium/Low improvement
        
        // Architecture quality
        var proper_mvvm_implementation = false       // True MVVM architecture?
        var dependency_injection_framework = false   // DI framework integrated?
        var clean_architecture_layers = 0           // Distinct architectural layers
    }
    
    /**
     * FINAL ASSESSMENT
     * Fill this in at the end of the exercise
     */
    object FinalAssessment {
        var total_refactoring_time_minutes = 0       // Time spent on exercise
        var most_difficult_refactoring = ""          // What was hardest to refactor?
        var biggest_learning = ""                    // Key insight from exercise
        var confidence_with_legacy_tdd = ""          // High/Medium/Low
        
        // Before vs After comparison
        fun calculateImprovements(): RefactoringImprovements {
            return RefactoringImprovements(
                linesOfCodeReduction = Baseline.MAIN_ACTIVITY_LINES - Phase3Results.main_activity_lines,
                testCoverageIncrease = Phase3Results.test_coverage_percent - Baseline.TEST_COVERAGE_PERCENT,
                cyclomaticComplexityReduction = Baseline.CYCLOMATIC_COMPLEXITY_MAIN - calculateFinalComplexity(),
                testableMethodsIncrease = Phase3Results.unit_tests_written - Baseline.TESTABLE_METHODS,
                classesCreated = Phase3Results.total_classes_created,
                interfacesCreated = Phase2Results.interfaces_extracted
            )
        }
        
        private fun calculateFinalComplexity(): Int {
            // Students calculate final cyclomatic complexity
            return 0 // To be filled in by students
        }
    }
    
    /**
     * Data class to track overall improvements
     */
    data class RefactoringImprovements(
        val linesOfCodeReduction: Int,
        val testCoverageIncrease: Int, 
        val cyclomaticComplexityReduction: Int,
        val testableMethodsIncrease: Int,
        val classesCreated: Int,
        val interfacesCreated: Int
    ) {
        fun printSummary() {
            println("=== REFACTORING RESULTS SUMMARY ===")
            println("Lines of Code Reduced: $linesOfCodeReduction")
            println("Test Coverage Increase: $testCoverageIncrease%")
            println("Complexity Reduction: $cyclomaticComplexityReduction decision points")
            println("New Testable Methods: $testableMethodsIncrease")
            println("New Classes Created: $classesCreated") 
            println("New Interfaces Created: $interfacesCreated")
            println("===================================")
        }
    }
    
    /**
     * Helper methods for students to calculate metrics
     */
    object MetricsHelper {
        
        fun countLinesOfCode(className: String): Int {
            println("TODO: Count non-comment, non-blank lines in $className")
            return 0
        }
        
        fun calculateCyclomaticComplexity(className: String): Int {
            println("TODO: Count decision points (if, when, &&, ||, for, while) in $className")
            return 0
        }
        
        fun countPublicMethods(className: String): Int {
            println("TODO: Count public methods in $className")
            return 0
        }
        
        fun countHardcodedValues(className: String): Int {
            println("TODO: Count magic numbers, hardcoded strings, colors in $className")
            return 0
        }
        
        fun calculateTestCoverage(): Int {
            println("TODO: Run test coverage tool and report percentage")
            return 0
        }
    }
}