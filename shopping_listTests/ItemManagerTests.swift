//
//  ItemManagerTests.swift
//  shopping_listTests
//

import XCTest

extension UserDefaults {
    func removeAll() {
        dictionaryRepresentation().forEach { removeObject(forKey: $0.key) }
    }
}

class MockItemInputRequestObserver: ItemInputRequestObserver {
    
    var notifyFlag = false
    
    func notify() {
        self.notifyFlag = true
    }

}

class ItemManagerTests: XCTestCase {

    let manager = ItemManager.sharedManager

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.manager.setTodoItems(items: [])
        self.manager.setDoneItems(items: [])
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.manager.setTodoItems(items: [])
        self.manager.setDoneItems(items: [])
    }

    private func get_todo_items_from_userdefaults() -> [ItemModel] {
        let data = UserDefaults.standard.data(forKey: "todo_items")!
        return try! (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [ItemModel])!
    }

    private func get_done_items_from_userdefaults() -> [ItemModel] {
        let data = UserDefaults.standard.data(forKey: "done_items")!
        return try! (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [ItemModel])!
    }

    // MARK: - Model
    func test_itemModel() throws {
        let itemA = ItemModel(name: "A")
        let itemAA = ItemModel(name: "A")
        let itemB = ItemModel(name: "B")
        XCTAssertEqual(itemA, itemAA)
        XCTAssertNotEqual(itemA, itemB)
    }

    // MARK: - ToDo Item
    func test_setToDoItems() throws {
        var items: [ItemModel]!
        // 空のItemを登録
        self.manager.setTodoItems(items: [])
        items = self.manager.getTodoItems()
        XCTAssertEqual(0, items.count)

        // UserDefaults登録確認
        var items_stored = self.get_todo_items_from_userdefaults()
        XCTAssertEqual(0, items_stored.count)

        // Itemを３つ登録
        var test_items = [ItemModel(name: "item0"), ItemModel(name: "item1"), ItemModel(name: "item2")]
        self.manager.setTodoItems(items: test_items)
        items = self.manager.getTodoItems()
        XCTAssertEqual(3, items.count)
        for i in 0..<test_items.count {
            XCTAssertEqual(test_items[i], items[i])
        }

        // UserDefaults登録確認
        items_stored = self.get_todo_items_from_userdefaults()
        XCTAssertEqual(3, items_stored.count)
        for i in 0..<test_items.count {
            XCTAssertEqual(test_items[i], items_stored[i])
        }

        // test_itemsを１つ削除してもItemManagerのItemsはそのまま
        test_items.remove(at: 1)
        items = self.manager.getTodoItems()
        XCTAssertEqual(3, items.count)
        
        // test_items再度登録するとItemManagerも更新される
        self.manager.setTodoItems(items: test_items)
        items = self.manager.getTodoItems()
        XCTAssertEqual(2, items.count)

        // ItemManagerから取得したItemを加工してもItemManagerのItemは変わらない
        items.remove(at: 0)
        items = self.manager.getTodoItems()
        XCTAssertEqual(2, items.count)
        
        // UserDefaults登録確認
        items_stored = self.get_todo_items_from_userdefaults()
        XCTAssertEqual(2, items_stored.count)
        for i in 0..<test_items.count {
            XCTAssertEqual(test_items[i], items_stored[i])
        }
    }

    func test_addTodoItem() throws {
        var items: [ItemModel]!
        // 1つ追加
        self.manager.addTodoItem(item: ItemModel(name: "item0"))
        items = self.manager.getTodoItems()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item0", items[0].name)

        // 同じ名前は無視される
        self.manager.addTodoItem(item: ItemModel(name: "item0"))
        items = self.manager.getTodoItems()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item0", items[0].name)

        // 空の名前は無視される
        self.manager.addTodoItem(item: ItemModel(name: ""))
        items = self.manager.getTodoItems()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item0", items[0].name)

        // 末尾に追加される
        self.manager.addTodoItem(item: ItemModel(name: "item1"))
        items = self.manager.getTodoItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item0", items[0].name)
        XCTAssertEqual("item1", items[1].name)
        
        // UserDefaults登録確認
        items = self.get_todo_items_from_userdefaults()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item0", items[0].name)
        XCTAssertEqual("item1", items[1].name)
    }

    func test_updateTodoItem() throws {
        // Itemを登録
        self.manager.setTodoItems(items: [
            ItemModel(name: "item0"),
            ItemModel(name: "item1")])
        var items: [ItemModel]!
        self.manager.updateTodoItem(at: 0, item: ItemModel(name: "item00"))
        self.manager.updateTodoItem(at: 1, item: ItemModel(name: "item11"))
        items = self.manager.getTodoItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item00", items[0].name)
        XCTAssertEqual("item11", items[1].name)

        // 不正なインデックス指定は無視される
        self.manager.updateTodoItem(at: 2, item: ItemModel(name: "item2"))
        items = self.manager.getTodoItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item00", items[0].name)
        XCTAssertEqual("item11", items[1].name)

        // 重複する名前は無視される
        self.manager.updateTodoItem(at: 1, item: ItemModel(name: "item00"))
        items = self.manager.getTodoItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item00", items[0].name)
        XCTAssertEqual("item11", items[1].name)

        // 空の名前は無視される
        self.manager.updateTodoItem(at: 1, item: ItemModel(name: ""))
        items = self.manager.getTodoItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item00", items[0].name)
        XCTAssertEqual("item11", items[1].name)

        // UserDefaults登録確認
        items = self.get_todo_items_from_userdefaults()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item00", items[0].name)
        XCTAssertEqual("item11", items[1].name)
    }

    func test_getTodoItemIndex() throws {
        // Itemを３つ登録
        self.manager.setTodoItems(items: [
            ItemModel(name: "item0"),
            ItemModel(name: "item1"),
            ItemModel(name: "item2")])
        XCTAssertEqual(-1, self.manager.getTodoItemIndex(item: ItemModel(name: "item9")))
        XCTAssertEqual(0, self.manager.getTodoItemIndex(item: ItemModel(name: "item0")))
        XCTAssertEqual(1, self.manager.getTodoItemIndex(item: ItemModel(name: "item1")))
        XCTAssertEqual(2, self.manager.getTodoItemIndex(item: ItemModel(name: "item2")))
    }

    func test_moveTodoItem() throws {
        self.manager.setTodoItems(items: [
            ItemModel(name: "A"),
            ItemModel(name: "B"),
            ItemModel(name: "C")])
        var items: [ItemModel]!
        
        // A=>B
        self.manager.moveTodoItem(sourceIndex: 0, destinationIndex: 1)
        items = self.manager.getTodoItems()
        XCTAssertEqual("B", items[0].name)
        XCTAssertEqual("A", items[1].name)
        XCTAssertEqual("C", items[2].name)

        // A=>C
        self.manager.moveTodoItem(sourceIndex: 1, destinationIndex: 2)
        items = self.manager.getTodoItems()
        XCTAssertEqual("B", items[0].name)
        XCTAssertEqual("C", items[1].name)
        XCTAssertEqual("A", items[2].name)

        // A=>C
        self.manager.moveTodoItem(sourceIndex: 2, destinationIndex: 1)
        items = self.manager.getTodoItems()
        XCTAssertEqual("B", items[0].name)
        XCTAssertEqual("A", items[1].name)
        XCTAssertEqual("C", items[2].name)

        // A=>B
        self.manager.moveTodoItem(sourceIndex: 1, destinationIndex: 0)
        items = self.manager.getTodoItems()
        XCTAssertEqual("A", items[0].name)
        XCTAssertEqual("B", items[1].name)
        XCTAssertEqual("C", items[2].name)

        // A=>C
        self.manager.moveTodoItem(sourceIndex: 0, destinationIndex: 2)
        items = self.manager.getTodoItems()
        XCTAssertEqual("B", items[0].name)
        XCTAssertEqual("C", items[1].name)
        XCTAssertEqual("A", items[2].name)
    }

    func test_doneTodoItems() throws {
        var items: [ItemModel]!
        // Itemを３つ登録
        let test_items = [ItemModel(name: "item0"), ItemModel(name: "item1"), ItemModel(name: "item2")]
        self.manager.setTodoItems(items: test_items)

        // 完了したItemの確認
        self.manager.doneTodoItem(at: 1)
        items = self.manager.getTodoItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item0", items[0].name)
        XCTAssertEqual("item2", items[1].name)
        
        items = self.manager.getDoneItems()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item1", items[0].name)

        self.manager.doneTodoItem(at: 0)
        items = self.manager.getTodoItems()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item2", items[0].name)
        
        items = self.manager.getDoneItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item0", items[0].name)
        XCTAssertEqual("item1", items[1].name)

        self.manager.doneTodoItem(at: 0)
        items = self.manager.getTodoItems()
        XCTAssertEqual(0, items.count)
        
        items = self.manager.getDoneItems()
        XCTAssertEqual(3, items.count)
        XCTAssertEqual("item2", items[0].name)
        XCTAssertEqual("item0", items[1].name)
        XCTAssertEqual("item1", items[2].name)
    }

    func test_removeTodoItems() throws {
        var items: [ItemModel]!
        // Itemを３つ登録
        let test_items = [ItemModel(name: "item0"), ItemModel(name: "item1"), ItemModel(name: "item2")]
        self.manager.setTodoItems(items: test_items)

        self.manager.removeTodoItem(at: 1)
        items = self.manager.getTodoItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item0", items[0].name)
        XCTAssertEqual("item2", items[1].name)
        
        self.manager.removeTodoItem(at: 1)
        items = self.manager.getTodoItems()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item0", items[0].name)
        
        // 無効なindexは無視される
        self.manager.removeTodoItem(at: 1)
        self.manager.removeTodoItem(at: -1)
        self.manager.removeTodoItem(at: 100)
        items = self.manager.getTodoItems()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item0", items[0].name)

        // UserDefaults登録確認
        items = self.get_todo_items_from_userdefaults()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item0", items[0].name)
    }

    func test_addTodoItems() throws {
        // Itemを登録
        self.manager.setTodoItems(items: [
            ItemModel(name: "item0"),
            ItemModel(name: "item1"),
            ItemModel(name: "item2"),
        ])

        // 重複itemは無視される
        self.manager.addTodoItems(itemText: "item3、item4\nitem5,item2")
        let items = self.manager.getTodoItems()
        XCTAssertEqual(3 + 3, items.count)
        XCTAssertEqual("item3", items[3].name)
        XCTAssertEqual("item4", items[4].name)
        XCTAssertEqual("item5", items[5].name)
    }
    
    func test_resetTodoItem() throws {
        var items: [ItemModel]!
        self.manager.setTodoItems(items: [
            ItemModel(name: "item0"),
            ItemModel(name: "item1"),
            ItemModel(name: "item2"),
        ])

        // リセット確認
        self.manager.resetTodoItem()
        items = self.manager.getTodoItems()
        XCTAssertEqual(0, items.count)
        
        // UserDefaults登録確認
        items = self.get_todo_items_from_userdefaults()
        XCTAssertEqual(0, items.count)
    }

    func test_allDoneTodoItem() throws {
        var items: [ItemModel]!
        self.manager.setTodoItems(items: [
            ItemModel(name: "item0"),
            ItemModel(name: "item1"),
            ItemModel(name: "item2"),
        ])

        self.manager.allDoneTodoItem()
        items = self.manager.getTodoItems()
        XCTAssertEqual(0, items.count)
        
        items = self.manager.getDoneItems()
        XCTAssertEqual(3, items.count)
        XCTAssertEqual("item2", items[0].name)
        XCTAssertEqual("item1", items[1].name)
        XCTAssertEqual("item0", items[2].name)

        // UserDefaults登録確認
        items = self.get_todo_items_from_userdefaults()
        XCTAssertEqual(0, items.count)

    }
    
    func test_splitItemText() throws {
        var items: [String]

        items = self.manager.splitItemText(itemText: "1,2,3")
        XCTAssertEqual(3, items.count)
        XCTAssertEqual("1", items[0])
        XCTAssertEqual("2", items[1])
        XCTAssertEqual("3", items[2])

        items = self.manager.splitItemText(itemText: ",,1,,2,,,,3,,,,")
        XCTAssertEqual(3, items.count)
        XCTAssertEqual("1", items[0])
        XCTAssertEqual("2", items[1])
        XCTAssertEqual("3", items[2])

        items = self.manager.splitItemText(itemText: " ,,1,,2, ,,3。,,,")
        XCTAssertEqual(3, items.count)
        XCTAssertEqual("1", items[0])
        XCTAssertEqual("2", items[1])
        XCTAssertEqual("3", items[2])

        items = self.manager.splitItemText(itemText: "1、2。3,4, 5 6　7\n8")
        XCTAssertEqual(8, items.count)
        XCTAssertEqual("1", items[0])
        XCTAssertEqual("2", items[1])
        XCTAssertEqual("3", items[2])
        XCTAssertEqual("4", items[3])
        XCTAssertEqual("5", items[4])
        XCTAssertEqual("6", items[5])
        XCTAssertEqual("7", items[6])
        XCTAssertEqual("8", items[7])

        items = self.manager.splitItemText(itemText: " 1 、 2 。3  ,4 , 5 6　7   \n  8")
        XCTAssertEqual(8, items.count)
    }
        
    // MARK: - Done Item
    func test_setDoneItems() throws {
        var items: [ItemModel]!
        // 空のItemを登録
        self.manager.setDoneItems(items: [])
        items = self.manager.getDoneItems()
        XCTAssertEqual(0, items.count)

        // UserDefaults登録確認
        var items_stored = self.get_done_items_from_userdefaults()
        XCTAssertEqual(0, items_stored.count)

        // Itemを３つ登録
        var test_items = [ItemModel(name: "item0"), ItemModel(name: "item1"), ItemModel(name: "item2")]
        self.manager.setDoneItems(items: test_items)
        items = self.manager.getDoneItems()
        XCTAssertEqual(3, items.count)
        for i in 0..<test_items.count {
            XCTAssertEqual(test_items[i], items[i])
        }

        // UserDefaults登録確認
        items_stored = self.get_done_items_from_userdefaults()
        XCTAssertEqual(3, items_stored.count)
        for i in 0..<test_items.count {
            XCTAssertEqual(test_items[i], items_stored[i])
        }

        // test_itemsを１つ削除してもItemManagerのItemsはそのまま
        test_items.remove(at: 1)
        items = self.manager.getDoneItems()
        XCTAssertEqual(3, items.count)
        
        // test_items再度登録するとItemManagerも更新される
        self.manager.setDoneItems(items: test_items)
        items = self.manager.getDoneItems()
        XCTAssertEqual(2, items.count)

        // ItemManagerから取得したItemを加工してもItemManagerのItemは変わらない
        items.remove(at: 0)
        items = self.manager.getDoneItems()
        XCTAssertEqual(2, items.count)
        
        // UserDefaults登録確認
        items_stored = self.get_done_items_from_userdefaults()
        XCTAssertEqual(2, items_stored.count)
        for i in 0..<test_items.count {
            XCTAssertEqual(test_items[i], items_stored[i])
        }
    }

    func test_addDoneItem() throws {
        var items: [ItemModel]!
        // 1つ追加
        self.manager.addDoneItem(item: ItemModel(name: "item0"))
        items = self.manager.getDoneItems()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item0", items[0].name)

        // 空の名前は無視される
        self.manager.addDoneItem(item: ItemModel(name: ""))
        items = self.manager.getDoneItems()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item0", items[0].name)

        // 先頭に追加される
        self.manager.addDoneItem(item: ItemModel(name: "item1"))
        self.manager.addDoneItem(item: ItemModel(name: "item2"))
        items = self.manager.getDoneItems()
        XCTAssertEqual(3, items.count)
        XCTAssertEqual("item2", items[0].name)
        XCTAssertEqual("item1", items[1].name)
        XCTAssertEqual("item0", items[2].name)

        // 同じ名前は先頭に移動する
        self.manager.addDoneItem(item: ItemModel(name: "item0"))
        items = self.manager.getDoneItems()
        XCTAssertEqual(3, items.count)
        XCTAssertEqual("item0", items[0].name)
        XCTAssertEqual("item2", items[1].name)
        XCTAssertEqual("item1", items[2].name)

        self.manager.addDoneItem(item: ItemModel(name: "item2"))
        items = self.manager.getDoneItems()
        XCTAssertEqual(3, items.count)
        XCTAssertEqual("item2", items[0].name)
        XCTAssertEqual("item0", items[1].name)
        XCTAssertEqual("item1", items[2].name)

        self.manager.addDoneItem(item: ItemModel(name: "item2"))
        items = self.manager.getDoneItems()
        XCTAssertEqual(3, items.count)
        XCTAssertEqual("item2", items[0].name)
        XCTAssertEqual("item0", items[1].name)
        XCTAssertEqual("item1", items[2].name)

        // UserDefaults登録確認
        items = self.get_done_items_from_userdefaults()
        XCTAssertEqual(3, items.count)
        XCTAssertEqual("item2", items[0].name)
        XCTAssertEqual("item0", items[1].name)
        XCTAssertEqual("item1", items[2].name)
        
        // 登録は100個まで
        // それ以上登録した時は古いItemが削除される
        self.manager.setDoneItems(items: [])
        for i in 0..<110 {
            self.manager.addDoneItem(item: ItemModel(name: String(i)))
        }
        items = self.manager.getDoneItems()
        XCTAssertEqual(100, items.count)
        XCTAssertEqual("109", items[0].name)
        XCTAssertEqual("10", items[99].name)
        XCTAssertEqual(-1, self.manager.getDoneItemIndex(item: ItemModel(name: "0")))

    }

    func test_updateDoneItem() throws {
        // Itemを登録
        self.manager.setDoneItems(items: [
            ItemModel(name: "item0"),
            ItemModel(name: "item1")])
        var items: [ItemModel]!
        self.manager.updateDoneItem(at: 0, item: ItemModel(name: "item00"))
        self.manager.updateDoneItem(at: 1, item: ItemModel(name: "item11"))
        items = self.manager.getDoneItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item00", items[0].name)
        XCTAssertEqual("item11", items[1].name)

        // 不正なインデックス指定は無視される
        self.manager.updateDoneItem(at: 2, item: ItemModel(name: "item2"))
        items = self.manager.getDoneItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item00", items[0].name)
        XCTAssertEqual("item11", items[1].name)

        // 重複する名前は無視される
        self.manager.updateDoneItem(at: 1, item: ItemModel(name: "item00"))
        items = self.manager.getDoneItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item00", items[0].name)
        XCTAssertEqual("item11", items[1].name)

        // 空の名前は無視される
        self.manager.updateDoneItem(at: 1, item: ItemModel(name: ""))
        items = self.manager.getDoneItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item00", items[0].name)
        XCTAssertEqual("item11", items[1].name)

        // UserDefaults登録確認
        items = self.get_done_items_from_userdefaults()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item00", items[0].name)
        XCTAssertEqual("item11", items[1].name)
    }

    func test_removeDoneItems() throws {
        var items: [ItemModel]!
        // Itemを３つ登録
        let test_items = [ItemModel(name: "item0"), ItemModel(name: "item1"), ItemModel(name: "item2")]
        self.manager.setDoneItems(items: test_items)

        self.manager.removeDoneItem(at: 1)
        items = self.manager.getDoneItems()
        XCTAssertEqual(2, items.count)
        XCTAssertEqual("item0", items[0].name)
        XCTAssertEqual("item2", items[1].name)
        
        self.manager.removeDoneItem(at: 1)
        items = self.manager.getDoneItems()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item0", items[0].name)
        
        // 無効なindexは無視される
        self.manager.removeDoneItem(at: 1)
        self.manager.removeDoneItem(at: -1)
        self.manager.removeDoneItem(at: 100)
        items = self.manager.getDoneItems()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item0", items[0].name)

        // UserDefaults登録確認
        items = self.get_done_items_from_userdefaults()
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("item0", items[0].name)
    }

    // MARK: Notification Control
    func test_createNotifyBodyText() throws {
        self.manager.setTodoItems(items: [
            ItemModel(name: "item0"),
            ItemModel(name: "item1"),
            ItemModel(name: "item2"),
        ])
        XCTAssertEqual("item0 item1 item2", self.manager.createNotifyBodyText())
    }

    func test_running() throws {
        // todoを空にするとstopする
        self.manager.setTodoItems(items: [])
        XCTAssertFalse(self.manager.isRunning())

        // todoが空の場合はstartできない
        self.manager.start()
        XCTAssertFalse(self.manager.isRunning())
        
        // todoが存在すればstartできる
        self.manager.setTodoItems(items: [ItemModel(name: "item0"), ItemModel(name: "item1")])
        self.manager.start()
        XCTAssertTrue(self.manager.isRunning())

        // todoが全て完了したらstopする
        self.manager.doneTodoItem(at: 0)
        XCTAssertTrue(self.manager.isRunning())
        self.manager.doneTodoItem(at: 0)
        XCTAssertFalse(self.manager.isRunning())

        // todoをリセットしたらstopする
        self.manager.setTodoItems(items: [ItemModel(name: "item0"), ItemModel(name: "item1")])
        self.manager.start()
        self.manager.resetTodoItem()
        XCTAssertFalse(self.manager.isRunning())

        // todoを全て削除したらstopする
        self.manager.setTodoItems(items: [ItemModel(name: "item0"), ItemModel(name: "item1")])
        self.manager.start()
        self.manager.removeTodoItem(at: 0)
        XCTAssertTrue(self.manager.isRunning())
        self.manager.removeTodoItem(at: 0)
        XCTAssertFalse(self.manager.isRunning())

        // todoを空にするとstopする
        self.manager.setTodoItems(items: [ItemModel(name: "item0"), ItemModel(name: "item1")])
        self.manager.start()
        self.manager.setTodoItems(items: [])
        XCTAssertFalse(self.manager.isRunning())

    }
    
    func test_ItemInputRequestObserver() throws {
        let observer = MockItemInputRequestObserver()
        self.manager.setItemInputRequestObserver(observer: observer)
        self.manager.notifyItemInputRequest()
        XCTAssertTrue(observer.notifyFlag)

    }
}
