@testable import Routine
import XCTest

final class AppLockStateTests: XCTestCase {
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
}
