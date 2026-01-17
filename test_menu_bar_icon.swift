#!/usr/bin/env swift
// Test script for MenuBarIconView logic
// Run with: swift test_menu_bar_icon.swift

import Foundation

// Simulate the relevant parts of DriveManager state
struct MockDriveManagerState {
    var isUnmountingAll: Bool = false
    var busyVolumeIdentifier: String? = nil
    var busyEjectingIdentifier: String? = nil
    var hasUserActionError: Bool = false
}

// Mirror the icon selection logic from MenuBarIconView
func selectIcon(for state: MockDriveManagerState) -> String {
    if state.isUnmountingAll
        || state.busyVolumeIdentifier != nil
        || state.busyEjectingIdentifier != nil {
        return "externaldrive.fill.badge.timemachine"
    }

    if state.hasUserActionError {
        return "externaldrive.fill.trianglebadge.exclamationmark"
    }

    return "externaldrive.fill"
}

// Test cases
struct TestCase {
    let name: String
    let state: MockDriveManagerState
    let expectedIcon: String
}

let testCases: [TestCase] = [
    TestCase(
        name: "Default idle state",
        state: MockDriveManagerState(),
        expectedIcon: "externaldrive.fill"
    ),
    TestCase(
        name: "Unmounting all drives",
        state: MockDriveManagerState(isUnmountingAll: true),
        expectedIcon: "externaldrive.fill.badge.timemachine"
    ),
    TestCase(
        name: "Busy mounting a volume",
        state: MockDriveManagerState(busyVolumeIdentifier: "disk2s1"),
        expectedIcon: "externaldrive.fill.badge.timemachine"
    ),
    TestCase(
        name: "Busy ejecting a disk",
        state: MockDriveManagerState(busyEjectingIdentifier: "disk2"),
        expectedIcon: "externaldrive.fill.badge.timemachine"
    ),
    TestCase(
        name: "Error state (no busy operation)",
        state: MockDriveManagerState(hasUserActionError: true),
        expectedIcon: "externaldrive.fill.trianglebadge.exclamationmark"
    ),
    TestCase(
        name: "Busy takes priority over error",
        state: MockDriveManagerState(isUnmountingAll: true, hasUserActionError: true),
        expectedIcon: "externaldrive.fill.badge.timemachine"
    ),
    TestCase(
        name: "Multiple busy states",
        state: MockDriveManagerState(
            isUnmountingAll: true,
            busyVolumeIdentifier: "disk2s1",
            busyEjectingIdentifier: "disk3"
        ),
        expectedIcon: "externaldrive.fill.badge.timemachine"
    ),
]

// Run tests
print("Testing MenuBarIconView icon selection logic\n")
print(String(repeating: "=", count: 50))

var passed = 0
var failed = 0

for test in testCases {
    let actualIcon = selectIcon(for: test.state)
    let success = actualIcon == test.expectedIcon

    if success {
        print("PASS: \(test.name)")
        passed += 1
    } else {
        print("FAIL: \(test.name)")
        print("  Expected: \(test.expectedIcon)")
        print("  Actual:   \(actualIcon)")
        failed += 1
    }
}

print(String(repeating: "=", count: 50))
print("\nResults: \(passed) passed, \(failed) failed")

exit(failed > 0 ? 1 : 0)
