//
//  SelectTableViewController.swift
//  shopping_list
//
//  Created by Satoru on 2020/04/20.
//  Copyright © 2020 Satoru. All rights reserved.
//

import UIKit

class ItemTableViewController: UITableViewController {

    let itemManager = ItemManager.sharedManager
    var items: [ItemModel]!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.items = self.itemManager.getItems()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        let item = self.items[indexPath.row]
        cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = item.name
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.checkmark
//        self.items[indexPath.row].selected = true
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.none
//        self.items[indexPath.row].selected = false
    }

}
