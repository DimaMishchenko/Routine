@testable import Routine
import XCTest

final class AppLockStateTests: XCTestCase {
  func testAuthenticationSuccessWhilePromptIsInactiveUnlocksOnActivation() throws {
    var state = AppLockState()
    state.activate(protectionEnabled: true)
    let generation = try XCTUnwrap(state.beginAuthentication())
    state.deactivate(protectionEnabled: true)
    state.completeAuthentication(succeeded: true, generation: generation)
    XCTAssertTrue(state.blocksContent)
    state.activate(protectionEnabled: true)
    XCTAssertFalse(state.blocksContent)
    XCTAssertFalse(state.shouldAuthenticateAutomatically)
  }

  func testColdStartStaysBlockedUntilAuthenticationSucceeds() throws {
    var state = AppLockState()
    state.activate(protectionEnabled: true)
    XCTAssertTrue(state.blocksContent)
    let generation = try XCTUnwrap(state.beginAuthentication())
    XCTAssertTrue(state.blocksContent)
    state.completeAuthentication(succeeded: true, generation: generation)
    XCTAssertFalse(state.blocksContent)
  }

  func testFailureStaysLockedWithoutAnAutomaticRetryLoop() throws {
    var state = AppLockState()
    state.activate(protectionEnabled: true)
    let generation = try XCTUnwrap(state.beginAuthentication())
    state.deactivate(protectionEnabled: true)
    state.activate(protectionEnabled: true)
    state.completeAuthentication(succeeded: false, generation: generation)
    XCTAssertTrue(state.blocksContent)
    XCTAssertFalse(state.shouldAuthenticateAutomatically)
    XCTAssertNotNil(state.beginAuthentication())
  }

  func testBackgroundInvalidatesAnOutstandingAuthenticationResult() throws {
    var state = AppLockState()
    state.activate(protectionEnabled: true)
    let generation = try XCTUnwrap(state.beginAuthentication())
    state.enterBackground()
    state.activate(protectionEnabled: true)
    XCTAssertFalse(state.completeAuthentication(succeeded: true, generation: generation))
    XCTAssertTrue(state.blocksContent)
    XCTAssertTrue(state.shouldAuthenticateAutomatically)
  }

  func testReactivationAloneDoesNotUnlockProtectedContent() throws {
    var state = AppLockState()
    state.activate(protectionEnabled: true)
    let generation = try XCTUnwrap(state.beginAuthentication())
    state.completeAuthentication(succeeded: true, generation: generation)
    state.deactivate(protectionEnabled: true)
    state.activate(protectionEnabled: true)
    XCTAssertTrue(state.blocksContent)
    XCTAssertTrue(state.shouldAuthenticateAutomatically)
  }

  func testInactiveAuthenticationSuccessDoesNotRevealContent() throws {
    var state = AppLockState()
    state.activate(protectionEnabled: true)
    let generation = try XCTUnwrap(state.beginAuthentication())
    state.deactivate(protectionEnabled: true)
    state.completeAuthentication(succeeded: true, generation: generation)
    XCTAssertTrue(state.blocksContent)
  }

  func testUnprotectedAppDoesNotRequestAuthentication() {
    var state = AppLockState()
    state.activate(protectionEnabled: false)
    XCTAssertFalse(state.blocksContent)
    XCTAssertFalse(state.shouldAuthenticateAutomatically)
    XCTAssertNil(state.beginAuthentication())
  }
  @MainActor func testBackgroundReleasesAttemptAndLateResultCannotClearReplacement() async {
    var continuations: [CheckedContinuation<Bool, Never>] = []
    var cancellations: [Bool] = []
    let started = (0..<3).map { expectation(description: "Authentication \($0) started") }
    let scene = SceneDelegate {
      let result = await withCheckedContinuation { continuation in
        continuations.append(continuation)
        started[continuations.count - 1].fulfill()
      }
      cancellations.append(Task.isCancelled)
      return result
    }
    scene.activateLock(protectionEnabled: true)
    await fulfillment(of: [started[0]], timeout: 2)
    scene.deactivateLock(protectionEnabled: true)
    scene.backgroundLock()
    scene.activateLock(protectionEnabled: true)
    await fulfillment(of: [started[1]], timeout: 2)
    continuations[0].resume(returning: true)
    await waitUntil { cancellations == [true] }
    XCTAssertEqual(cancellations, [true])
    XCTAssertTrue(scene.lockState.blocksContent)
    XCTAssertEqual(scene.lockState.phase, .authenticating)
    scene.authenticate()
    XCTAssertEqual(continuations.count, 2)
    continuations[1].resume(returning: false)
    await waitUntil { scene.lockState.phase == .locked }
    XCTAssertEqual(scene.lockState.phase, .locked)
    scene.authenticate()
    await fulfillment(of: [started[2]], timeout: 2)
    continuations[2].resume(returning: true)
    await waitUntil { scene.lockState.phase == .unlocked }
    XCTAssertFalse(scene.lockState.blocksContent)
  }

  @MainActor func testPromptSuccessWhileInactiveRevealsContentOnlyAfterActivation() async {
    let started = expectation(description: "Authentication started")
    var completion: CheckedContinuation<Bool, Never>?
    let scene = SceneDelegate {
      await withCheckedContinuation { continuation in
        completion = continuation
        started.fulfill()
      }
    }
    scene.activateLock(protectionEnabled: true)
    await fulfillment(of: [started], timeout: 2)
    scene.deactivateLock(protectionEnabled: true)
    completion?.resume(returning: true)
    await waitUntil { scene.lockState.phase == .unlocked }
    XCTAssertTrue(scene.lockState.blocksContent)
    scene.activateLock(protectionEnabled: true)
    XCTAssertFalse(scene.lockState.blocksContent)
  }

  @MainActor private func waitUntil(_ condition: @escaping () -> Bool) async {
    let completed = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in condition() }, object: nil)
    await fulfillment(of: [completed], timeout: 2)
  }
}
