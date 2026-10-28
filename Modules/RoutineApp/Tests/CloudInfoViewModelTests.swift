import CloudKitSyncMonitor
@testable import Routine
import XCTest

final class CloudInfoViewModelTests: XCTestCase {
  @MainActor func testPreviouslyCompletedSyncIsVisibleWhenOpeningCloudInfo() {
    let monitor = SyncMonitor(
      setupSuccessful: true,
      importSuccessful: true,
      exportSuccessful: true,
      errorText: nil
    )
    let viewModel = CloudInfoViewModelImpl(monitor: monitor)
    XCTAssertEqual(viewModel.cloudStatusVM.state, .success)
    XCTAssertEqual(viewModel.importStatusVM.state, .success)
    XCTAssertEqual(viewModel.exportStatusVM.state, .success)
    XCTAssertNil(viewModel.errorHint)
  }

  @MainActor func testExistingNetworkAndAccountFailuresAreVisibleImmediately() {
    let disconnected = SyncMonitor(networkAvailable: false, iCloudAccountStatus: .available, listen: false)
    XCTAssertEqual(
      CloudInfoViewModelImpl(monitor: disconnected).errorHint,
      RoutineAppStrings.Localizable.CloudInfo.ErrorHint.noNetwork
    )
    let signedOut = SyncMonitor(networkAvailable: true, iCloudAccountStatus: .noAccount, listen: false)
    XCTAssertEqual(
      CloudInfoViewModelImpl(monitor: signedOut).errorHint,
      RoutineAppStrings.Localizable.CloudInfo.ErrorHint.iCloudAccount
    )
  }
}
