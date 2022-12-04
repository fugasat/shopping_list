//
//  RequestTableViewController.swift
//  shopping_list
//
//  Created by Satoru on 2020/04/18.
//  Copyright © 2020 Satoru. All rights reserved.
//

import UIKit

class SelectionTableViewController: UITableViewController {

    let itemManager = ItemManager.sharedManager
    var items: [SelectionModel]!


    override func viewDidLoad() {
        super.viewDidLoad()

//        let test_items = [
//            ItemModel(name: "牛乳"),
//            ItemModel(name: "肉＆魚"),
//            ItemModel(name: "玉ねぎ")]
//        self.itemManager.setItems(items: test_items)
//        let test_selection_items = [
//            SelectionModel(item: ItemModel(name: "牛乳")),
//            SelectionModel(item: ItemModel(name: "玉ねぎ"))]
//        self.itemManager.setSelectionItems(items: test_selection_items)
        
        self.items = self.itemManager.getSelectionItems()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func isItemRow(indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            if indexPath.row < self.items.count {
                return true
            }
        }
        return false
    }
    
    func isAddRow(indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            if indexPath.row == self.items.count {
                return true
            }
        }
        return false
    }
    
    func isStartRow(indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            if indexPath.row == self.items.count + 1 {
                return true
            }
        }
        return false
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items.count + 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        if self.isItemRow(indexPath: indexPath) {
            let item = self.items[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_item", for: indexPath)
            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = item.item!.name
            }
        } else if self.isAddRow(indexPath: indexPath){
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_add", for: indexPath)
        } else if self.isStartRow(indexPath: indexPath){
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_start", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isItemRow(indexPath: indexPath) {
            let cell = self.tableView.cellForRow(at: indexPath)
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            self.items[indexPath.row].selected = true
        } else if self.isAddRow(indexPath: indexPath){
            self.tableView(self.tableView, didDeselectRowAt: indexPath)
        } else if self.isStartRow(indexPath: indexPath){
            let cell = self.tableView.cellForRow(at: indexPath)
            if let label = cell?.viewWithTag(1) as? UILabel {
                label.text = "Stop"
            }
            self.itemManager.run()
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
        if self.isItemRow(indexPath: indexPath) {
            cell?.accessoryType = UITableViewCellAccessoryType.none
            self.items[indexPath.row].selected = false
        } else if self.isStartRow(indexPath: indexPath){
            let cell = self.tableView.cellForRow(at: indexPath)
            if let label = cell?.viewWithTag(1) as? UILabel {
                label.text = "Start"
            }
            self.itemManager.stop()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
