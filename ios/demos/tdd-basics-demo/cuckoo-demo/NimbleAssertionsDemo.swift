import XCTest
import Nimble

final class NimbleAssertionsDemo: XCTestCase {
    func testNimbleAssertions() {
        // Basic Equality
        expect(1 + 1).to(equal(2))

        // Inequality
        expect(5).toNot(equal(3))

        // Nil Check
        let optionalValue: Int? = nil
        expect(optionalValue).to(beNil())

        // Boolean Assertions
        expect(true).to(beTrue())
        expect(false).to(beFalse())

        // Collection Assertions
        let array = [1, 2, 3]
        expect(array).to(contain(2))
        expect(array).toNot(contain(4))
        expect(array).to(haveCount(3))

        // String Assertions
        let string = "Hello, Nimble!"
        expect(string).to(beginWith("Hello"))
        expect(string).to(endWith("Nimble!"))
        expect(string).to(contain("Nimble"))

        // Range Assertions
        expect(5).to(beGreaterThan(3))
        expect(5).to(beLessThan(10))
        expect(5).to(beCloseTo(5.0, within: 0.1))

        // Error Handling
        expect { throw NSError(domain: "Test", code: 1, userInfo: nil) }.to(throwError())

        // Asynchronous Assertions
        var value = 0
        DispatchQueue.global().async {
            value = 10
        }
        expect(value).toEventually(equal(10), timeout: .seconds(2))
    }
}
