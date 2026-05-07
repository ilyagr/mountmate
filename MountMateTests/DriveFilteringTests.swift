import XCTest

@testable import MountMate

final class DriveFilteringTests: XCTestCase {
  func testBootSSDIsFixedInternal() {
    let info: [String: Any] = [
      "Internal": true,
      "Ejectable": false,
      "RemovableMedia": false,
      "BusProtocol": "Apple Fabric",
    ]
    XCTAssertTrue(DriveManager.isFixedInternalDisk(infoPlist: info))
  }

  func testExternalUSBIsNotFixedInternal() {
    let info: [String: Any] = [
      "Internal": false,
      "Ejectable": true,
      "RemovableMedia": false,
      "BusProtocol": "USB",
    ]
    XCTAssertFalse(DriveManager.isFixedInternalDisk(infoPlist: info))
  }

  // The PCIe-attached built-in MacBook Pro SD reader reports Internal=true,
  // but the inserted card is ejectable / its media is removable.
  func testBuiltInSDCardIsNotFixedInternal() {
    let ejectableSD: [String: Any] = [
      "Internal": true,
      "Ejectable": true,
      "RemovableMedia": false,
      "BusProtocol": "Secure Digital",
    ]
    XCTAssertFalse(DriveManager.isFixedInternalDisk(infoPlist: ejectableSD))

    let removableMediaSD: [String: Any] = [
      "Internal": true,
      "Ejectable": false,
      "RemovableMedia": true,
      "BusProtocol": "Secure Digital",
    ]
    XCTAssertFalse(DriveManager.isFixedInternalDisk(infoPlist: removableMediaSD))
  }

  func testMissingPlistIsNotFixedInternal() {
    XCTAssertFalse(DriveManager.isFixedInternalDisk(infoPlist: nil))
    XCTAssertFalse(DriveManager.isFixedInternalDisk(infoPlist: [:]))
  }
}
