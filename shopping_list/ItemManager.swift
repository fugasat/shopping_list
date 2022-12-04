//
//  NotificationController.swift
//  shopping_list
//

import Foundation
import UserNotifications

class ItemManager {
    enum ActionIdentifier: String {
        case selected
    }

    let DONE_MAX = 100
    
    static let sharedManager = ItemManager()
    private let userDefaults = UserDefaults.standard
    private var running = false
    private var todoItems: [ItemModel] = []
    private var doneItems: [ItemModel] = []
    private var itemInputRequestObserver: ItemInputRequestObserver?
    
    private init() {
        self.todoItems = self.getTodoItemsFromUserDefaults()
        self.doneItems = self.getDoneItemsFromUserDefaults()
    }

    // MARK: - ToDo Items
    func getTodoItems() -> [ItemModel] {
        return self.todoItems
    }

    func setTodoItems(items: [ItemModel]) {
        self.todoItems = items
        self.storeData(key: "todo_items", data: self.todoItems)
        if self.todoItems.count <= 0 {
            self.stop()
        }
    }

    func addTodoItem(item: ItemModel) {
        if item.name == "" {
            return
        }
        if self.getTodoItemIndex(item: item) >= 0 {
            return
        }
        var newItems = self.getTodoItems()
        newItems.append(item)
        self.setTodoItems(items: newItems)
    }
    
    func updateTodoItem(at: Int, item: ItemModel) {
        if at < 0 || at >= self.todoItems.count {
            return
        }
        if item.name == "" {
            return
        }
        if  self.getTodoItemIndex(item: item) >= 0 {
            return
        }
        var newItems = self.getTodoItems()
        newItems[at] = item
        self.setTodoItems(items: newItems)
    }

    func getTodoItemIndex(item: ItemModel) -> Int {
        for index in 0..<self.todoItems.count {
            if item == self.todoItems[index] {
                return index
            }
        }
        return -1
    }

    func moveTodoItem(sourceIndex: Int, destinationIndex: Int) {
        var newItems = self.getTodoItems()
        let srcItem = newItems[sourceIndex]
        newItems.remove(at: sourceIndex)
        newItems.insert(srcItem, at: destinationIndex)
        self.setTodoItems(items: newItems)
    }

    func doneTodoItem(at: Int) {
        var newItems = self.getTodoItems()
        let srcItem = newItems[at]
        newItems.remove(at: at)
        self.setTodoItems(items: newItems)
        self.addDoneItem(item: srcItem)
    }

    func allDoneTodoItem() {
        for _ in 0..<self.getTodoItems().count {
            self.doneTodoItem(at: 0)
        }
    }
    
    func removeTodoItem(at: Int) {
        var newItems = self.getTodoItems()
        if at < 0 || at >= newItems.count {
            return
        }
        newItems.remove(at: at)
        self.setTodoItems(items: newItems)
    }

    func addTodoItems(itemText: String) {
        let splittedTexts = self.splitItemText(itemText: itemText)
        for text in splittedTexts {
            self.addTodoItem(item: ItemModel(name: text))
        }
    }
    
    func resetTodoItem() {
        self.setTodoItems(items: [])
    }

    func splitItemText(itemText: String) -> [String] {
        let separates = [",","、", "。","\n", "　", " "]
        func splitItemText(itemText: String, index: Int) -> [String] {
            if index >= separates.count {
                return [itemText]
            }
            var splittedTexts: [String] = []
            for tempA in itemText.components(separatedBy: separates[index]) {
                for tempB in splitItemText(itemText: tempA, index: index + 1) {
                    if tempB.count > 0 {
                        splittedTexts.append(tempB)
                    }
                }
            }
            return splittedTexts
        }
        return splitItemText(itemText: itemText, index: 0)
    }
    
    // MARK: - Done Items
    func getDoneItems() -> [ItemModel] {
        return self.doneItems
    }

    func setDoneItems(items: [ItemModel]) {
        self.doneItems = items.prefix(DONE_MAX).map{ $0 }
        self.storeData(key: "done_items", data: self.doneItems)
    }

    func addDoneItem(item: ItemModel) {
        if item.name == "" {
            return
        }
        var newItems = self.getDoneItems()
        let index = self.getDoneItemIndex(item: item)
        if index >= 0 {
            self.removeDoneItem(at: index)
            newItems = self.getDoneItems()
        }
        newItems.insert(item, at: 0)
        self.setDoneItems(items: newItems)
    }

    func updateDoneItem(at: Int, item: ItemModel) {
        if at < 0 || at >= self.doneItems.count {
            return
        }
        if item.name == "" {
            return
        }
        if  self.getDoneItemIndex(item: item) >= 0 {
            return
        }
        var newItems = self.getDoneItems()
        newItems[at] = item
        self.setDoneItems(items: newItems)
    }


    func removeDoneItem(at: Int) {
        var newItems = self.getDoneItems()
        if at < 0 || at >= newItems.count {
            return
        }
        newItems.remove(at: at)
        self.setDoneItems(items: newItems)
    }
    
    func getDoneItemIndex(item: ItemModel) -> Int {
        for index in 0..<self.doneItems.count {
            if item == self.doneItems[index] {
                return index
            }
        }
        return -1
    }

    // MARK: User Defaults
    private func storeData(key: String, data: [NSObject]) {
        // archiveエラー防止
        NSKeyedArchiver.setClassName(String(describing: "shopping_list.ItemModel"), for: ItemModel.self)
        let archivedData = try! NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
        self.userDefaults.set(archivedData, forKey: key)
    }

    private func getItemsFromUserDefaults(key: String) -> [ItemModel] {
        if let data = self.userDefaults.data(forKey: key) {
            // unarchiveエラー防止
            NSKeyedUnarchiver.setClass(ItemModel.self, forClassName: String(describing: "shopping_list.ItemModel"))
            if let unarchivedObject = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [ItemModel] {
                return unarchivedObject
            }
        }
        return []
    }

    private func getTodoItemsFromUserDefaults() -> [ItemModel] {
        return self.getItemsFromUserDefaults(key: "todo_items")
    }

    private func getDoneItemsFromUserDefaults() -> [ItemModel] {
        return self.getItemsFromUserDefaults(key: "done_items")
    }

    private func getItemsFromUserDefaults() -> [ItemModel] {
        return self.getItemsFromUserDefaults(key: "items")
    }

    // MARK: Notification Control
    func createNotifyBodyText() -> String {
        var body = ""
        for item in self.getTodoItems() {
            if body.count > 0 {
                body.append(" ")
            }
            body.append(item.name!)
        }
        return body
    }
    
    func isRunning() -> Bool {
        return self.running
    }

    func start() {
        if self.todoItems.count > 0 {
            self.running = true
        }
    }
    
    func stop() {
        self.running = false
    }

    func notifyItem() {
        self.notifyItem(interval: 1)
    }

    func notifyItem(interval: Float) {
        if !self.running {
            return
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            if error != nil {
                return
            }
            if granted {
                let content = UNMutableNotificationContent()
                let items = self.getTodoItems()
                var item: String!
                if items.count > 0 {
                    content.title = NSLocalizedString("買い物リスト", comment: "")
                    item = (items[0].name)! + NSLocalizedString("を購入", comment: "")
                    let actionSelected = UNNotificationAction(identifier: ActionIdentifier.selected.rawValue, title: item, options: [])
                    let category = UNNotificationCategory(identifier: "selected",
                                                          actions: [actionSelected],
                                                          intentIdentifiers: [],
                                                          options: [])
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                } else {
                    content.title = NSLocalizedString("買い物終了", comment: "")
                }

                content.body = self.createNotifyBodyText()
                content.sound = nil // 無音
                if (item != nil) {
                    content.categoryIdentifier = "selected"
                }

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(interval), repeats: false)
                let request = UNNotificationRequest(identifier: "shopping_list",
                                                   content: content,
                                                   trigger: trigger)

                // ローカル通知予約
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                print("notify:" + content.body)
            }
        }
    }
    
    func notifyFinish() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            if error != nil {
                return
            }
            if granted {
                let content = UNMutableNotificationContent()
                content.body = NSLocalizedString("買い物終了", comment: "")
                content.sound = nil // 無音
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(0.75), repeats: false)
                let request = UNNotificationRequest(identifier: "shopping_list",
                                                   content: content,
                                                   trigger: trigger)

                // ローカル通知予約
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                print("notify:" + content.body)
            }
        }
    }

    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            if error != nil {
                return
            }
            if granted {
                print("Authorization approved.")
            } else {
                print("Authorization rejected.")
            }
        }
    }

    // MARK: Item input request observer Control
    func notifyItemInputRequest() {
        if let observer = self.itemInputRequestObserver {
            observer.notify()
        }
    }
    
    func setItemInputRequestObserver(observer: ItemInputRequestObserver) {
        self.itemInputRequestObserver = observer
    }
    
    func removeItemInputRequestObserver() {
        self.itemInputRequestObserver = nil
    }
}
