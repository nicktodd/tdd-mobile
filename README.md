# Advanced Test-Driven Development for Mobile Development

**Professional Training Materials for Kotlin & Swift**

This repository contains comprehensive course materials, hands-on labs, and practical demonstrations for advanced Test-Driven Development (TDD) training focused on mobile development. These materials are used by select partner training companies including KPL and Neueda, as well as by [Watchelm](https://watchelm.com/).

## 🎯 Repository Purpose

This repository serves as the complete learning resource for professional mobile developers seeking to master Test-Driven Development practices in iOS and Android development. It provides:

- **Structured Learning Paths** - Progressive modules covering TDD fundamentals to advanced legacy code refactoring
- **Hands-On Labs** - Practical exercises with real-world mobile development scenarios
- **Complete Solutions** - Reference implementations demonstrating best practices
- **Live Demonstrations** - Working code examples for both Kotlin and Swift
- **Industry Standards** - Modern mobile testing frameworks and contemporary development practices

## 📚 Course Overview

### 🟢 Advanced Test-Driven Development in Kotlin and Swift

**Master TDD practices for production-ready mobile applications**

Test-Driven Development has become essential for building robust, maintainable mobile applications. This intensive two-day course provides comprehensive coverage of TDD principles, advanced mocking techniques, and practical strategies for refactoring legacy mobile code.

**What You'll Learn:**

- **Red-Green-Refactor Cycle** - Master the fundamental TDD workflow at scale
- **Quality Unit Testing** - Write effective, maintainable tests that provide real value
- **Advanced Mocking** - Use modern frameworks (MockK, Cuckoo) to test complex interactions
- **MVVM Architecture** - Apply TDD to modern mobile architecture patterns
- **Legacy Code Refactoring** - Safely refactor untestable code using characterization testing
- **Mobile-Specific Challenges** - Address device fragmentation, network variability, and platform constraints
- **Test Doubles** - Understand when and how to use mocks, stubs, fakes, and spies
- **API Integration Testing** - Test network layers and external dependencies effectively

**Target Audience:**
- Intermediate to advanced mobile developers with experience in Kotlin or Swift
- Developers looking to improve code quality and testability
- Teams transitioning to TDD practices
- Anyone maintaining legacy mobile codebases

**Prerequisites:**
- Working knowledge of Kotlin (Android) or Swift (iOS)
- Basic understanding of mobile app development
- Familiarity with your platform's development tools (Android Studio or Xcode)

**Course Format:** 2-Day Intensive Workshop

Repository Sections: `android/demos/`, `ios/demos/`, `labs/`, `solutions/`

[View Full Course Details](https://watchelm.com/course/TDDMOB/Advanced%20Test-Driven%20Development%20in%20Kotlin%20and%20Swift)

## 🚀 Professional Training

### Training Partners

These materials are utilized by select partner training companies including KPL and Neueda, delivering high-quality technical training to help organizations fill critical skill gaps and solve complex business challenges.

### Training Provider: Watchelm

Watch Elm Consulting Ltd is one of the providers using these materials for technical training, consulting, and EdTech solutions.

#### 🏆 Accreditations & Expertise

- AWS Professional Certified Solutions Architects
- AWS DevOps Specialty Certified
- Professional Scrum Master Certified
- Altova Training & Consulting Partner

#### 🎓 Comprehensive Course Catalog

Explore our full range of professional training programs:

**Mobile & Testing:**
- [Advanced Test-Driven Development in Kotlin and Swift](https://watchelm.com/course/TDDMOB/Advanced%20Test-Driven%20Development%20in%20Kotlin%20and%20Swift)
- [Testing and Quality Assurance](https://watchelm.com/categories/Testing)

**Software Development:**
- [Software Development](https://watchelm.com/categories/Software%20Development)
- [Python](https://watchelm.com/categories/Python)
- [Java and SpringBoot](https://watchelm.com/categories/Java)
- [.NET and C#](https://watchelm.com/categories/.Net)

**Additional Specializations:**
- [Web Development](https://watchelm.com/categories/Web)
- [IT & Cloud Infrastructure](https://watchelm.com/categories/Cloud)
- [GenAI and Machine Learning](https://watchelm.com/categories/GenAI%20and%20ML)
- [DevOps and Automation](https://watchelm.com/categories/DevOps)
- [Docker and Kubernetes](https://watchelm.com/categories/Docker)
- [Software Architecture and Design](https://watchelm.com/categories/Analysis%20and%20Design)

#### 🏢 Corporate Training Solutions

- Custom curriculum tailored to your organization's needs
- On-site and remote training delivery options
- Flexible scheduling to minimize business disruption
- Expert instructors with real-world industry experience
- Post-training support and consultation services

## 📖 Course Structure Overview

### Day 1: TDD Fundamentals & Best Practices

#### Module 1: Red-Green-Refactor at Scale

**Objectives:** Master the TDD cycle beyond basic examples and understand when TDD provides the most value

**Topics Covered:**
- The Red-Green-Refactor cycle in practice
- TDD mindset for mobile development challenges
- When (and when not) to use TDD
- Test-first vs test-after decision making
- Mobile-specific considerations (fragmentation, battery, security)

**Materials:** [Android Demo](android/demos/tdd-basics-demo) | [iOS Demo](ios/demos/tdd-basics-demo) | [Lab 01](labs/01GoodQualityUnitTests.md)

#### Module 2: Writing Good Quality Unit Tests

**Objectives:** Create maintainable, meaningful tests that provide real value

**Topics Covered:**
- Characteristics of effective unit tests (FIRST principles)
- Test naming conventions and organization
- Arrange-Act-Assert pattern
- Testing edge cases and error conditions
- Avoiding test smells and anti-patterns

**Materials:** [Lab 01](labs/01GoodQualityUnitTests.md)

#### Module 3: Effective Mocking & Test Doubles

**Objectives:** Master mocking frameworks and understand different types of test doubles

**Topics Covered:**
- Mocks, stubs, fakes, and spies - when to use each
- MockK for Kotlin (Android)
- Cuckoo for Swift (iOS)
- Testing complex component interactions
- Verifying behavior vs. verifying state

**Materials:** [Lab 02](labs/02EffectiveMocking.md) | [Android Demo](android/demos/tdd-basics-demo) | [iOS Demo](ios/demos/tdd-basics-demo)

### Day 2: MVVM, API Testing & Legacy Code

#### Module 4: TDD with MVVM Architecture

**Objectives:** Apply TDD principles to modern mobile architecture patterns

**Topics Covered:**
- MVVM pattern fundamentals
- Testing ViewModels in isolation
- Repository pattern and dependency injection
- Reactive programming with StateFlow/Combine
- UI testing vs. unit testing

**Materials:** [Android MVVM Demo](android/demos/mvvm-demo) | [iOS MVVM Demo](ios/demos/mvvm-demo)

#### Module 5: API Integration & Network Testing

**Objectives:** Test network layers and external dependencies effectively

**Topics Covered:**
- Testing REST API integrations
- Mocking network responses
- Handling asynchronous operations
- Error handling and retry logic
- Testing with real APIs vs. mocked APIs

**Materials:** [Android API Demo](android/demos/SwapiAPIExample) | [iOS API Demo](ios/demos/starwars-api)

#### Module 6: Dealing with Legacy Mobile Code

**Objectives:** Apply TDD techniques to refactor untestable legacy codebases

**Topics Covered:**
- Characterization testing - documenting existing behavior
- Dependency breaking techniques
- Seams and injection points
- Safe refactoring strategies
- Working within real-world constraints
- The Strangler Fig pattern for mobile apps

**Materials:** [Lab 07](labs/07DealingWithLegacyMobileCode.md) | [Legacy Weather Kotlin](labs/LegacyWeatherKotlin) | [Legacy Weather Swift](labs/LegacyWeatherSwift) | [Refactored Solutions](solutions)

## 🛠️ Getting Started

### Prerequisites

**For Android (Kotlin):**
- Android Studio (latest stable version recommended)
- JDK 17 or higher
- Android SDK (API 33 or higher)
- Gradle knowledge (helpful but not required)

**For iOS (Swift):**
- macOS with Xcode 15 or later
- Swift 5.9 or higher
- CocoaPods or Swift Package Manager
- iOS 17 SDK (recommended)

**Both Platforms:**
- Git for version control
- Basic understanding of mobile development
- Familiarity with your chosen platform's testing framework

### Quick Start

```bash
# Clone the repository
git clone https://github.com/nicktodd/tdd-mobile.git
cd tdd-mobile

# For Android development
cd android/demos/tdd-basics-demo
./gradlew test

# For iOS development
cd ios/demos/tdd-basics-demo
swift test
# Or open in Xcode and run tests (Cmd+U)

# Choose your learning path
cd labs/                        # Start with hands-on exercises
cd android/demos/               # Explore Android demonstrations
cd ios/demos/                   # Explore iOS demonstrations
cd solutions/                   # Reference implementations

# Follow the README in each module for specific instructions
```

### Repository Structure

```
tdd-mobile/
├── android/                      # Android (Kotlin) materials
│   └── demos/
│       ├── tdd-basics-demo/      # Red-Green-Refactor fundamentals
│       ├── mvvm-demo/            # MVVM architecture with TDD
│       └── SwapiAPIExample/      # API testing examples
│
├── ios/                          # iOS (Swift) materials
│   └── demos/
│       ├── tdd-basics-demo/      # Red-Green-Refactor fundamentals
│       ├── mvvm-demo/            # MVVM architecture with TDD
│       └── starwars-api/         # API testing examples
│
├── labs/                         # Hands-on exercises
│   ├── 01GoodQualityUnitTests.md
│   ├── 02EffectiveMocking.md
│   ├── 07DealingWithLegacyMobileCode.md
│   ├── LegacyWeatherKotlin/      # Android legacy refactoring
│   └── LegacyWeatherSwift/       # iOS legacy refactoring
│
└── solutions/                    # Complete reference implementations
    ├── RefactoredWeatherKotlin/
    └── RefactoredWeatherSwift/
```

## 💡 Key Learning Outcomes

By completing this course, you will be able to:

- ✅ Apply the Red-Green-Refactor cycle to complex mobile development scenarios
- ✅ Write high-quality, maintainable unit tests that provide real value
- ✅ Use mocking frameworks effectively (MockK for Kotlin, Cuckoo for Swift)
- ✅ Test ViewModels and business logic in isolation from the UI
- ✅ Apply TDD principles to MVVM architecture patterns
- ✅ Test network integrations and handle asynchronous operations
- ✅ Use characterization testing to document legacy code behavior
- ✅ Apply dependency breaking techniques to make legacy code testable
- ✅ Make informed decisions about when to use TDD vs. other approaches
- ✅ Handle mobile-specific testing challenges (device fragmentation, network variability)

## 🎓 Ready to Level Up Your Mobile Development Skills?

### Individual Learning

Explore this repository at your own pace using the structured learning materials. Each module builds upon the previous one, ensuring a comprehensive understanding of Test-Driven Development practices for mobile applications.

### Professional Training

Ready for instructor-led, comprehensive training? Our partner training companies offer:

**🏢 Corporate Training**

- Customized curriculum for your mobile development team's specific needs
- Expert instruction from industry professionals with real-world experience
- Flexible delivery: on-site, remote, or hybrid formats
- Hands-on labs using your team's actual codebase (optional)
- Post-training support and consultation

**👤 Individual Courses**

- Structured 2-day intensive learning experience
- Small class sizes for personalized attention
- Practical, hands-on approach with real mobile apps
- Certificate of completion
- Career advancement opportunities in mobile development

### Training Contacts

For professional training inquiries, contact our partner training companies KPL and Neueda, or:

**Watchelm:**

📞 Phone: [+44 (0) 117 441 7005](tel:+441174417005)  
📧 Email: [enquiries@watchelm.com](mailto:enquiries@watchelm.com)  
🌐 Website: [https://watchelm.com](https://watchelm.com/)  
📍 Address: Watch Elm Close, Bristol BS32 8AL, United Kingdom

**Browse All Courses:** [https://watchelm.com/categories/Testing](https://watchelm.com/categories/Testing)

## 📱 Platform-Specific Resources

### Android (Kotlin) Resources

**Testing Frameworks:**
- [JUnit 5](https://junit.org/junit5/) - Unit testing framework
- [MockK](https://mockk.io/) - Mocking library for Kotlin
- [Kotest](https://kotest.io/) - Kotlin-first testing framework
- [Espresso](https://developer.android.com/training/testing/espresso) - UI testing

**Key Topics:**
- Coroutines testing with `TestDispatchers`
- ViewModel testing with `StateFlow`
- Repository pattern implementation
- Dependency injection with Hilt/Koin

### iOS (Swift) Resources

**Testing Frameworks:**
- [XCTest](https://developer.apple.com/documentation/xctest) - Apple's testing framework
- [Cuckoo](https://github.com/Brightify/Cuckoo) - Mocking framework for Swift
- [Nimble](https://github.com/Quick/Nimble) - Matcher framework
- [Quick](https://github.com/Quick/Quick) - BDD testing framework

**Key Topics:**
- Async/await testing
- Combine framework testing
- SwiftUI view testing
- Protocol-oriented programming for testability

## 🤝 Contributing

While this repository primarily serves as training material, we welcome feedback and suggestions for improvements. If you're a training participant and find issues or have suggestions, please reach out to your instructor or contact Watchelm directly.

## 📄 License & Usage

This training material is provided for educational purposes. Individual modules may contain specific licensing information for third-party libraries and frameworks.

© Watch Elm Consulting Ltd 2025 | Company No. 16285610 | VAT No. GB 488264054

---

**Transform your mobile development skills with professional TDD training from industry experts.** Join hundreds of developers who have improved their code quality and confidence through comprehensive training programs delivered by our partner companies including KPL, Neueda, and Watchelm.

*Master Test-Driven Development. Build Better Mobile Apps.*
