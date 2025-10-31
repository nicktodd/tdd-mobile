# Dealing With Legacy Mobile Code

## Exercise 1: Case Study – “Where Would You Start?” (Guided Group Activity)

### Purpose
To practice identifying pain points and developing a testing/refactoring strategy from an external codebase.


### Scenarios

#### iOS Scenario
An iOS shopping app built in Objective-C, last updated in 2015. The app uses:
- Outdated networking code with `NSURLConnection` (deprecated in iOS 9).
- A monolithic `ViewController` with over 2,000 lines of code, mixing UI logic, network calls, and data parsing.
- No dependency injection, making it hard to replace or mock components for testing.
- Manual memory management (no ARC), leading to potential memory leaks.
- No unit tests or automated test coverage.

#### Android Scenario
An Android expense tracker app written in Java, last updated in 2016. The app includes:
- Static utility classes for database access, tightly coupled to SQLite.
- Networking implemented with `HttpURLConnection` instead of modern libraries like Retrofit.
- Business logic embedded directly in `Activity` and `Fragment` classes, making them hard to test.
- No use of dependency injection frameworks like Dagger or Hilt.
- Legacy Android Support Library instead of AndroidX.
- No unit tests, and manual QA is the only testing process.

### Task
In small groups, have participants:

1. Identify pain points (performance, maintainability, testability, security).
2. List risks of refactoring (e.g., breaking user flows, API changes).
3. Propose a phased testing and refactoring strategy:
   - What to test first?
   - Where to add seams for testability?
   - How to minimize regression risk?
4. How would you best apply TDD principles in this situation?


### Deliverable
Each group presents a short summary or diagram of their strategy.

---

## Exercise 2: Personal Reflection – “Your Legacy App” (Individual Exercise)

### Setup
Think of a real app you've worked on or are working on that qualifies as legacy (or a past project that suffered from tech debt).

### Task

1. Describe the legacy context (tech stack, team size, constraints).
2. Identify 3–5 main pain points.
3. Propose a test-first refactoring plan:
   - Which modules would you isolate first?
   - What testing tools/frameworks would you choose (XCTest, JUnit, MockK, etc.)?
   - How would you measure progress (coverage, performance, crash rate, etc.)?


