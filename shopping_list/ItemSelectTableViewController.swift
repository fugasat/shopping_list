//
//  ItemSelectTableViewController.swift
//  shopping_list
//

import UIKit

class ItemSelectTableViewController: UITableViewController {

    let itemManager = ItemManager.sharedManager
    var items: [ItemModel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.items = self.itemManager.getDoneItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.items = self.itemManager.getDoneItems()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = self.items[indexPath.row]
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = item.name
        }
        if self.itemManager.getTodoItemIndex(item: item) >= 0 {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        self.itemManager.addTodoItem(item: self.items[indexPath.row])
        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
        let index = self.itemManager.getTodoItemIndex(item: self.items[indexPath.row])
        if index >= 0 {
            self.itemManager.removeTodoItem(at: index)
            cell?.accessoryType = UITableViewCell.AccessoryType.none
        }
    }
}
