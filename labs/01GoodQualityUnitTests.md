# Lab: Good Quality Unit Tests

## Objective
The goal of this lab is to practice the Test-Driven Development (TDD) process by implementing a class that converts a time of day into text. This exercise focuses on writing good quality unit tests and following the TDD cycle: **Red, Green, Refactor**.

## Scenario
You will create a class with a function that converts a time object into a human-readable text representation of the time of day. The class will be used in later exercises to create a speaking clock. For now, the focus is solely on practicing TDD and writing high-quality unit tests.

## Requirements
- The function should take a time object as input and return a string representing the time in English.
- Examples of expected outputs:
  - "Midnight"
  - "Midday"
  - "It's one o'clock"
  - "It's half past two"
  - "It's just gone half past five"
  - "It's nearly half past five"
- The requirements are intentionally vague to allow you to make design decisions and iterate through the TDD process.
- The implementation does not need to handle every possible edge case; focus on the TDD process.

## Instructions

### Step 1: Set Up Your Project
1. **Swift (iOS)**:
   - Create a new Swift package or add a new class to your existing iOS project.
   - Ensure you have a test target set up for writing unit tests.

2. **Kotlin (Android)**:
   - Create a new Kotlin module or add a new class to your existing Android project.
   - Ensure you have a test directory set up for writing unit tests.

### Step 2: Follow the TDD Process
1. **Write a Failing Test (Red)**:
   - Start by writing a test for the simplest possible case, such as converting midnight to "Midnight".
   - Run the test to ensure it fails.

2. **Make the Test Pass (Green)**:
   - Implement just enough code to make the test pass.

3. **Refactor**:
   - Refactor the code to improve its quality while ensuring all tests still pass.

4. **Repeat**:
   - Write the next test for a slightly more complex case, such as converting 1:00 AM to "It's one o'clock".
   - Continue iterating through the TDD cycle.


## Tips
- Focus on writing clear, concise, and meaningful tests.
- Use descriptive names for your test cases to indicate what behavior is being tested.
- Don't try to implement everything at once; let the tests drive your implementation.

## Deliverables
- A class with a function that converts a time object into text.
- A suite of unit tests demonstrating the TDD process.

Good luck, and enjoy practicing TDD!