// MARK: - Mocks generated for Cuckoo
//
// This file contains mock classes for use with Cuckoo testing framework
// For Swift Package Manager projects, we need to import Cuckoo and create the mocks manually
// In a real project, you would use the Cuckoo generator to create these automatically

import Foundation
import Cuckoo
@testable import SpeakingClock

// MARK: - Mock Classes

class MockClock: Clock, Cuckoo.ClassMock {
    typealias MocksType = Clock
    typealias Stubbing = __StubbingProxy_Clock
    typealias Verification = __VerificationProxy_Clock

    let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    private var __defaultImplStub: Clock?

    func enableDefaultImplementation(_ stub: Clock) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }

    override func getTime() -> Date {
        return cuckoo_manager.call(
            "getTime() -> Date",
            parameters: (),
            escapingParameters: (),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.getTime()
        )
    }

    struct __StubbingProxy_Clock: Cuckoo.StubbingProxy {
        private let cuckoo_manager: Cuckoo.MockManager

        init(manager: Cuckoo.MockManager) {
            self.cuckoo_manager = manager
        }

        func getTime() -> Cuckoo.ClassStubFunction<(), Date> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return .init(stub: cuckoo_manager.createStub(for: MockClock.self,
                                                          method: "getTime() -> Date",
                                                          parameterMatchers: matchers))
        }
    }

    struct __VerificationProxy_Clock: Cuckoo.VerificationProxy {
        private let cuckoo_manager: Cuckoo.MockManager
        private let callMatcher: Cuckoo.CallMatcher
        private let sourceLocation: Cuckoo.SourceLocation

        init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
            self.cuckoo_manager = manager
            self.callMatcher = callMatcher
            self.sourceLocation = sourceLocation
        }

        @discardableResult
        func getTime() -> Cuckoo.__DoNotUse<(), Date> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return cuckoo_manager.verify(
                "getTime() -> Date",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
    }
}

class MockSpeechSynthesizer: SpeechSynthesizer, Cuckoo.ClassMock {
    typealias MocksType = SpeechSynthesizer
    typealias Stubbing = __StubbingProxy_SpeechSynthesizer
    typealias Verification = __VerificationProxy_SpeechSynthesizer

    let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    private var __defaultImplStub: SpeechSynthesizer?

    func enableDefaultImplementation(_ stub: SpeechSynthesizer) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }

    override func speak(_ text: String) {
        return cuckoo_manager.call(
            "speak(_: String)",
            parameters: (text),
            escapingParameters: (text),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.speak(text)
        )
    }

    struct __StubbingProxy_SpeechSynthesizer: Cuckoo.StubbingProxy {
        private let cuckoo_manager: Cuckoo.MockManager

        init(manager: Cuckoo.MockManager) {
            self.cuckoo_manager = manager
        }

        func speak<M1: Cuckoo.Matchable>(_ text: M1) -> Cuckoo.ClassStubNoReturnFunction<(String)> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: text) { $0 }]
            return .init(stub: cuckoo_manager.createStub(for: MockSpeechSynthesizer.self,
                                                          method: "speak(_: String)",
                                                          parameterMatchers: matchers))
        }
    }

    struct __VerificationProxy_SpeechSynthesizer: Cuckoo.VerificationProxy {
        private let cuckoo_manager: Cuckoo.MockManager
        private let callMatcher: Cuckoo.CallMatcher
        private let sourceLocation: Cuckoo.SourceLocation

        init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
            self.cuckoo_manager = manager
            self.callMatcher = callMatcher
            self.sourceLocation = sourceLocation
        }

        @discardableResult
        func speak<M1: Cuckoo.Matchable>(_ text: M1) -> Cuckoo.__DoNotUse<(String), Void> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: text) { $0 }]
            return cuckoo_manager.verify(
                "speak(_: String)",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
    }
}

class MockTimeToTextConverter: TimeToTextConverter, Cuckoo.ClassMock {
    typealias MocksType = TimeToTextConverter
    typealias Stubbing = __StubbingProxy_TimeToTextConverter
    typealias Verification = __VerificationProxy_TimeToTextConverter

    let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    private var __defaultImplStub: TimeToTextConverter?

    func enableDefaultImplementation(_ stub: TimeToTextConverter) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }

    override func convertTimeToText(_ date: Date) -> String? {
        return cuckoo_manager.call(
            "convertTimeToText(_: Date) -> String?",
            parameters: (date),
            escapingParameters: (date),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.convertTimeToText(date)
        )
    }

    struct __StubbingProxy_TimeToTextConverter: Cuckoo.StubbingProxy {
        private let cuckoo_manager: Cuckoo.MockManager

        init(manager: Cuckoo.MockManager) {
            self.cuckoo_manager = manager
        }

        func convertTimeToText<M1: Cuckoo.Matchable>(_ date: M1) -> Cuckoo.ClassStubFunction<(Date), String?> where M1.MatchedType == Date {
            let matchers: [Cuckoo.ParameterMatcher<(Date)>] = [wrap(matchable: date) { $0 }]
            return .init(stub: cuckoo_manager.createStub(for: MockTimeToTextConverter.self,
                                                          method: "convertTimeToText(_: Date) -> String?",
                                                          parameterMatchers: matchers))
        }
    }

    struct __VerificationProxy_TimeToTextConverter: Cuckoo.VerificationProxy {
        private let cuckoo_manager: Cuckoo.MockManager
        private let callMatcher: Cuckoo.CallMatcher
        private let sourceLocation: Cuckoo.SourceLocation

        init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
            self.cuckoo_manager = manager
            self.callMatcher = callMatcher
            self.sourceLocation = sourceLocation
        }

        @discardableResult
        func convertTimeToText<M1: Cuckoo.Matchable>(_ date: M1) -> Cuckoo.__DoNotUse<(Date), String?> where M1.MatchedType == Date {
            let matchers: [Cuckoo.ParameterMatcher<(Date)>] = [wrap(matchable: date) { $0 }]
            return cuckoo_manager.verify(
                "convertTimeToText(_: Date) -> String?",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
    }
}

