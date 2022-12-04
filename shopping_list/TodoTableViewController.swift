//
//  RequestTableViewController.swift
//  shopping_list
//

import UIKit
import UserNotifications
import LinkPresentation


class TodoTableViewController: UITableViewController, UNUserNotificationCenterDelegate, ItemInputRequestObserver {

    let itemManager = ItemManager.sharedManager
    let SECTION_ITEM = 0
    let SECTION_MENU = 1
    let INDEX_INPUT = IndexPath(row: 0, section: 1)
    let INDEX_SELECT = IndexPath(row: 1, section: 1)
    let INDEX_RESET = IndexPath(row: 2, section: 1)
    let INDEX_START = IndexPath(row: 3, section: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // appがforegroundになる前のイベント（viewWillAppearは効かないので注意）
        NotificationCenter.default.addObserver(self, selector: #selector(TodoTableViewController.viewWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        tableView.register(UINib(nibName: "SectionItemView", bundle: nil), forHeaderFooterViewReuseIdentifier: "section_item")
        tableView.register(UINib(nibName: "SectionMenuView", bundle: nil), forHeaderFooterViewReuseIdentifier: "section_menu")
        
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up")!, style: .plain, target: self, action: #selector(rightBarButtonTapped))
        navigationItem.rightBarButtonItem = barButtonItem

        // 常に編集モードにする
        self.tableView.isEditing = true
        self.tableView.allowsSelectionDuringEditing = true
        
        // 入力画面オープンの通知を受け取る
        self.itemManager.setItemInputRequestObserver(observer: self)
    }

    @objc func viewWillEnterForeground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.itemManager.requestAuthorization()
    }

    @objc func rightBarButtonTapped(_ sender: UIBarButtonItem) {
        let shareText = ShareItem(self.itemManager.createNotifyBodyText())
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    func isItemRow(indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_ITEM {
            return true
        }
        return false
    }

    private func updateStartMenu() {
        let cell = self.tableView.cellForRow(at: INDEX_START)
        if let label = cell?.viewWithTag(1) as? UILabel {
            label.text = self.getStartMenuLabel()
        }
    }
    
    private func getStartMenuCell(indexPath: IndexPath) -> UITableViewCell {
        if self.itemManager.isRunning() {
            // ここでselectRowしないと初期表示時に選択状態にならない
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_start", for: indexPath)
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = self.getStartMenuLabel()
        }
        return cell
    }
    
    private func getStartMenuLabel() -> String {
        if self.itemManager.getTodoItems().count <= 0 {
            return NSLocalizedString(" ", comment: "")
        } else if self.itemManager.isRunning() {
            return NSLocalizedString("買い物を中断する", comment: "")
        } else {
            return NSLocalizedString("買い物を開始する", comment: "")
        }
    }
        
    func notify() {
        self.navigationController?.popToRootViewController(animated: false)
        self.performSegue(withIdentifier: "item_input", sender: nil)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == SECTION_ITEM {
            return self.itemManager.getTodoItems().count
        } else if section == SECTION_MENU {
            return 4
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellName: String!
        if section == SECTION_ITEM {
            cellName = "section_item"
        } else if section == SECTION_MENU {
            cellName = "section_menu"
        } else {
            cellName = "section"
        }
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: cellName)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        if self.isItemRow(indexPath: indexPath) {
            let item = self.itemManager.getTodoItems()[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_item", for: indexPath)
            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = item.name
            }
            cell?.editingAccessoryType = UITableViewCell.AccessoryType.none // 削除アイコンを消す
        } else if indexPath == INDEX_INPUT {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_input", for: indexPath)
        } else if indexPath == INDEX_SELECT {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_select", for: indexPath)
        } else if indexPath == INDEX_RESET {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_reset", for: indexPath)
        } else if indexPath == INDEX_START {
            cell = self.getStartMenuCell(indexPath: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isItemRow(indexPath: indexPath) {
            self.itemManager.doneTodoItem(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        } else if indexPath == INDEX_START {
            if self.itemManager.isRunning() {
                self.itemManager.stop()
            } else {
                self.itemManager.start()
            }
        } else if indexPath == INDEX_RESET {
            let itemCount = self.itemManager.getTodoItems().count
            var removeIndexPaths: [IndexPath] = []
            for index in 0..<itemCount {
                removeIndexPaths.append(IndexPath(row: index, section: 0))
            }
            self.itemManager.allDoneTodoItem()
            self.tableView.deleteRows(at: removeIndexPaths, with: UITableView.RowAnimation.top)
        }
        self.tableView.deselectRow(at: indexPath, animated: true)

        // todoリストの状況に応じて開始ボタンの表示を更新
        self.updateStartMenu()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.itemManager.removeTodoItem(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }

        // todoリストの状況に応じて開始ボタンの表示を更新
        self.updateStartMenu()
    }

    // item sectionのみ編集を許可する
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.isItemRow(indexPath: indexPath) {
            return true
        } else {
            return false
        }
    }

    // cellの移動を許可する
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // cellの編集モードアイコンを無効にする
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }

    // cellの編集モードインデントを無効にする
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    // sectionを横断したMoveを禁止
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
       if sourceIndexPath.section == proposedDestinationIndexPath.section {
           return proposedDestinationIndexPath
       }
       return sourceIndexPath
    }

    // cellの並び替え
     override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
         self.itemManager.moveTodoItem(
             sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
     }

}

class ShareItem<T>: NSObject, UIActivityItemSource {
    
    private let item: T
    
    init(_ item: T) {
        self.item = item
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return item
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return activityViewControllerPlaceholderItem(activityViewController)
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {

        let metadata = LPLinkMetadata()
        if let shareText = self.item as? String {
            metadata.title = shareText
        }
        return metadata
    }
}
