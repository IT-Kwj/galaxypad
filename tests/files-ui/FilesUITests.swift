// SPDX-License-Identifier: GPL-3.0-or-later
import XCTest

final class FilesUITests: XCTestCase {
    func testImportChoicesOpenPicker() {
        continueAfterFailure = false
        let game = XCUIApplication(bundleIdentifier: "org.galaxypad.GalaxyPad")
        game.launch()
        for action in ["Import from GalaxyPad Folder", "Import or Reimport Game Data"] {
            let menu = game.buttons["galaxypad.menu"]
            XCTAssertTrue(menu.waitForExistence(timeout: 10))
            menu.tap()
            game.buttons["Game Data & Saves"].tap()
            game.buttons[action].tap()
            let alert = game.alerts.firstMatch
            XCTAssertTrue(alert.waitForExistence(timeout: 5))
            XCTAssertTrue(alert.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Downloads' AND label CONTAINS 'iCloud Drive'")).firstMatch.exists)
            let choose = alert.buttons["Choose Image"]
            XCTAssertTrue(choose.exists)
            choose.tap()
            let cancel = game.buttons["Cancel"]
            XCTAssertTrue(cancel.waitForExistence(timeout: 10), "Choose Image opens the system picker")
            print("IMPORT PICKER: \(game.debugDescription)")
            XCTAssertTrue(game.collectionViews["File View"].waitForExistence(timeout: 5), "A document picker is presented")
            let screenshot = XCTAttachment(screenshot: game.screenshot())
            screenshot.lifetime = .keepAlways
            add(screenshot)
            cancel.tap()
        }
    }

    func testFolderVisibleInFiles() {
        continueAfterFailure = false
        let game = XCUIApplication(bundleIdentifier: "org.galaxypad.GalaxyPad")
        game.launch()
        let files = XCUIApplication(bundleIdentifier: "com.apple.DocumentsApp")
        files.launch()
        let browse = files.buttons.matching(identifier: "Browse").firstMatch
        if browse.waitForExistence(timeout: 10) { browse.tap() }
        let local = files.cells.matching(NSPredicate(format: "label CONTAINS 'On My iPhone' OR label CONTAINS 'On My iPad'")).firstMatch
        print("FILES ROOT: \(files.debugDescription)")
        let localTitle = files.navigationBars.staticTexts.matching(NSPredicate(format: "label == 'On My iPhone' OR label == 'On My iPad'")).firstMatch
        for _ in 0..<4 {
            if localTitle.exists { break }
            if local.exists { local.tap() }
            else if files.buttons["DOC.navBarButton.backInHistory"].isEnabled {
                files.buttons["DOC.navBarButton.backInHistory"].tap()
            }
        }
        XCTAssertTrue(localTitle.waitForExistence(timeout: 10), "Files must show local storage")
        let folder = files.cells.matching(NSPredicate(format: "label BEGINSWITH 'GalaxyPad'")).firstMatch
        print("LOCAL STORAGE: \(files.debugDescription)")
        XCTAssertTrue(folder.waitForExistence(timeout: 10), "GalaxyPad must appear in Files after a fresh launch")
        folder.tap()
        let guide = files.cells.matching(NSPredicate(format: "label CONTAINS 'Import Game Data'")).firstMatch
        XCTAssertTrue(guide.waitForExistence(timeout: 10), "Fresh folder contains the import guide")
        let screenshot = XCTAttachment(screenshot: files.screenshot())
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
