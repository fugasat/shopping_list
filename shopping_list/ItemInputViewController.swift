//
//  FreeInputViewController.swift
//  shopping_list
//

import UIKit

class ItemInputViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    let itemManager = ItemManager.sharedManager

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButtonItem = UIBarButtonItem(title: NSLocalizedString("キャンセル", comment: ""), style: .plain, target: self, action: #selector(rightBarButtonTapped))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillChangeFrame(notification:)),
                                                         name: UIResponder.keyboardWillChangeFrameNotification,
                                                         object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(notification:)),
                                                         name: UIResponder.keyboardWillHideNotification,
                                                         object: nil)
        self.textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.itemManager.addTodoItems(itemText: self.textView.text)

        NotificationCenter.default.removeObserver(self)
        self.textView.resignFirstResponder()
    }
    
    @objc func rightBarButtonTapped(_ sender: UIBarButtonItem) {
        self.textView.text = ""
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyBoardValue : NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey]! as! NSValue
            let keyBoardFrame : CGRect = keyBoardValue.cgRectValue
            let duration : TimeInterval = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as! TimeInterval
            self.bottomLayoutConstraint.constant = keyBoardFrame.height * -1
            UIView.animate(withDuration: duration, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let duration : TimeInterval = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as! TimeInterval
            self.bottomLayoutConstraint.constant = 0
            UIView.animate(withDuration: duration, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
}
