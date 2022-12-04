//
//  ItemSelectTableViewControllerTest.swift
//  shopping_listTests
//

import XCTest
//@testable import

class ItemSelectTableViewControllerTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTableView() throws {
        let manager = ItemManager.sharedManager
        var items: [ItemModel] = []
        for index in 0..<100 {
            items.append(ItemModel(name: String(index)))
        }
        manager.setDoneItems(items: items)
        manager.resetTodoItem()
        
        var viewController: ItemSelectTableViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "item_select") as! ItemSelectTableViewController
        /*
         lifecycle loadView()
         lifecycle viewDidLoad()
         */
        viewController.loadViewIfNeeded()
        /*
         lifecycle viewWillLayoutSubviews()
         lifecycle viewDidLayoutSubviews()
         */
        viewController.view.layoutIfNeeded()

        XCTAssertEqual(100, viewController.tableView(viewController.tableView, numberOfRowsInSection: 0))

        let cell = viewController.tableView(viewController.tableView, cellForRowAt: IndexPath(row: 0, section: 1))
        let label = cell.viewWithTag(1) as! UILabel
        XCTAssertEqual(label.text, "1")


        //viewController.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.none)
    }

}
