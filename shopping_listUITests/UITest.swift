//
//  UITest.swift
//  shopping_listUITests
//

import XCTest

class UITest: XCTestCase {

    let app = XCUIApplication() // クラス変数にしないとlaunchArgumentsを受け渡しできないので注意
    let reset_items = true
    let fastlane_use = false
    let actionInterval: UInt32 = 0

    override func setUp() {
        super.setUp()
        self.app.launchArguments += ["UI-Testing"]
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        if self.reset_items {
            self.app.launchArguments += ["--uitesting"]
        }

        // fastlane
        setupSnapshot(app)

        self.app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_run() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        /*
         todoを入力
         */
        self.filterElementsWithLabel(elements: self.app.cells, text: "全て購入済にする").element.tap()
        self.filterElementsWithLabel(elements: self.app.cells, text: "品物を入力").element.tap()
        sleep(actionInterval)

        self.app.textViews.element.tap()
        self.app.textViews.element.typeText("りんご　にんじん　玉ねぎ　ジャガイモ　カレールウ　豚肉　ヨーグルト")
        self.takeScreenShot(name: "scr2")
        self.app.navigationBars.buttons["買い物リスト"].tap()
        sleep(actionInterval)
        self.takeScreenShot(name: "scr1")
        
        /*
         todoを完了させる
         */
        self.filterElementsWithLabel(elements: self.app.cells, text: "にんじん").element.tap()
        sleep(actionInterval)
        self.filterElementsWithLabel(elements: self.app.cells, text: "ジャガイモ").element.tap()
        sleep(actionInterval)
        self.filterElementsWithLabel(elements: self.app.cells, text: "豚肉").element.tap()
        sleep(actionInterval)
        self.filterElementsWithLabel(elements: self.app.cells, text: "ヨーグルト").element.tap()
        sleep(actionInterval)

        /*
         doneからリストを作成
         */
        // 品物を選択するメニューをタップ
        self.filterElementsWithLabel(elements: self.app.cells, text: "購入履歴から品物を選択").element.tap()
        sleep(actionInterval)
        // 品物を選択
        self.filterElementsWithLabel(elements: self.app.cells, text: "ヨーグルト").element.tap()
        sleep(actionInterval)
        self.filterElementsWithLabel(elements: self.app.cells, text: "ジャガイモ").element.tap()
        sleep(actionInterval)
        self.takeScreenShot(name: "scr3")

        self.app.navigationBars.buttons["買い物リスト"].tap()
        sleep(actionInterval)

        /*
         買い物を開始
         */
        self.filterElementsWithLabel(elements: self.app.cells, text: "買い物を開始する").element.tap()
        sleep(actionInterval)

        XCUIDevice.shared.perform(NSSelectorFromString("pressLockButton"))
        sleep(6)
        if !self.fastlane_use {
            self.takeScreenShot(name: "scr5")
        }

        XCUIDevice.shared.press(XCUIDevice.Button.home)
        sleep(actionInterval)

        self.filterElementsWithLabel(elements: self.app.cells, text: "ヨーグルト").element.tap()
        sleep(actionInterval)
        self.filterElementsWithLabel(elements: self.app.cells, text: "買い物を中断する").element.tap()
        sleep(actionInterval)

        /*
         Extension
         */
        self.filterElementsWithLabel(elements: self.app.cells, text: "品物を入力").element.tap()
        sleep(actionInterval)
        self.app.textViews.element.tap()
        self.app.textViews.element.typeText("りんご　にんじん　玉ねぎ　ジャガイモ　カレールウ　豚肉　ヨーグルト")
        self.app.navigationBars.buttons["買い物リスト"].tap()
        sleep(actionInterval)
        let rightNavBarButton = self.app.navigationBars.children(matching: .button).firstMatch
        rightNavBarButton.tap()
        sleep(2)
        self.takeScreenShot(name: "scr4")

        /*
         https://github.com/pixeldock/LocalNotificationDemo/blob/master/UserNotificationUITests/UserNotificationUITests.swift
         */
    }

    func filterElementsWithLabel(elements: XCUIElementQuery, text: String) -> XCUIElementQuery {
        return elements.containing(NSPredicate(format: "label CONTAINS %@", text))
    }

    func takeScreenShot(name: String) {
        if fastlane_use == false {
            let screen = XCUIScreen.main
            let screenShot = screen.screenshot()
            let attachment = XCTAttachment(screenshot: screenShot)
            attachment.lifetime = XCTAttachment.Lifetime.keepAlways
            attachment.name = name
            self.add(attachment)
        } else {
            snapshot(name)
        }
    }
}
