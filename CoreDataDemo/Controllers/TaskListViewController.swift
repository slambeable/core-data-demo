//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Andrey Evdokimov on 21.02.2021.
//

import UIKit
import CoreData

protocol TaskViewControllerDelegate {
    func reloadData()
}

class TaskListViewController: UITableViewController {
    private let cellID = "task"
    
    private var selectedRowIndex: IndexPath = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        navigationItem.rightBarButtonItem = editButtonItem
        setupNavigationBar()
        StorageManager.shared.fetchData()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func showAlert(with title: String, and message: String, type: ActionTypesForUIAlertButton = .save) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }

            if (type == .save) {
                self.save(task)
            }
            
            if (type == .edit) {
                self.edit(task)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        StorageManager.shared.save(taskName)
        
        let cellIndex = IndexPath(row: StorageManager.shared.taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
    
    private func edit(_ taskName: String) {
        guard let cell = tableView.cellForRow(at: selectedRowIndex) else { return }
        StorageManager.shared.edit(taskName, at: selectedRowIndex.row)
        
        var content = cell.defaultContentConfiguration()
        content.text = taskName
        cell.contentConfiguration = content
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        StorageManager.shared.taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = StorageManager.shared.taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool    {
        true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
           StorageManager.shared.remove(at: indexPath.row)
           tableView.deleteRows(at: [indexPath], with: .fade)
        }
       
        let editAction = UIContextualAction(style: .normal, title: "Edit") {  (_, _, completion) in
            self.selectedRowIndex = indexPath
            self.showAlert(with: "EditTask", and: "How do you edit this task?", type: .edit)
            completion(true)
        }
       
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
       
        return swipeActions
    }
}

// MARK: - TaskViewControllerDelegate
extension TaskListViewController: TaskViewControllerDelegate {
    func reloadData() {
        StorageManager.shared.fetchData()
        tableView.reloadData()
    }
}

// MARK: - TaskViewControllerEnum
extension TaskListViewController {
    enum ActionTypesForUIAlertButton {
        case save
        case edit
    }
}
