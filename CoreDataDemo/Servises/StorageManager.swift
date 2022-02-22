//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Андрей Евдокимов on 21.02.2022.
//

import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    var taskList: [Task] = []
    
    private lazy var context = persistentContainer.viewContext
    
    private init() {}

    // MARK: - Core Data stack
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
    
    func save(_ taskName: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }

        task.title = taskName
        taskList.append(task)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    func edit(_ taskName: String, at indexRow: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        
        if let tasks = try? context.fetch(fetchRequest) as? [Task] {
            let task = tasks[indexRow]
                    
            task.title = taskName
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    func remove(at indexRow: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        taskList.remove(at: indexRow)
        
        if let tasks = try? context.fetch(fetchRequest) as? [Task] {
            let currentTitle = tasks[indexRow]
            context.delete(currentTitle)
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error {
                    print(error)
                }
            }
        }
    }
}
