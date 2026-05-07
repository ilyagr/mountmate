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
  // but a card inserted into it has RemovableMedia=true (verified via
  // `diskutil info -plist` on a real card, which also reports Ejectable=true,
  // BusProtocol="Secure Digital", MediaName="Built In SDXC Reader").
  func testBuiltInSDCardIsNotFixedInternal() {
    let info: [String: Any] = [
      "Internal": true,
      "Ejectable": true,
      "RemovableMedia": true,
      "BusProtocol": "Secure Digital",
    ]
    XCTAssertFalse(DriveManager.isFixedInternalDisk(infoPlist: info))
  }

  // A hypothetical hot-swappable internal drive bay (e.g. legacy Mac Pro
  // tower SATA bay) reports Internal=true with the drive itself ejectable,
  // but the drive *is* the device — its media isn't removable. Such a disk
  // should stay classified as internal so users still see the boot-drive
  // bucket they expect.
  func testHotSwapInternalBayStaysInternal() {
    let info: [String: Any] = [
      "Internal": true,
      "Ejectable": true,
      "RemovableMedia": false,
      "BusProtocol": "SATA",
    ]
    XCTAssertTrue(DriveManager.isFixedInternalDisk(infoPlist: info))
  }

  func testMissingPlistIsNotFixedInternal() {
    XCTAssertFalse(DriveManager.isFixedInternalDisk(infoPlist: nil))
    XCTAssertFalse(DriveManager.isFixedInternalDisk(infoPlist: [:]))
  }
}
