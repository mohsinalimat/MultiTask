//
//  RealmManager.swift
//  MultiTask
//
//  Created by rightmeow on 8/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import RealmSwift

protocol PersistentContainerDelegate: NSObjectProtocol {
    // error
    func persistentContainer(_ manager: RealmManager, didErr error: Error)
    // auth
    func didRegister(_ manager: RealmManager, user: User)
    func didLogin(_ manager: RealmManager, user: User)
    func didLogout(_ manager: RealmManager, user: User)
    // fetch
    func persistentContainer(_ manager: RealmManager, didFetch objects: Results<Object>?)
    func persistentContainer(_ manager: RealmManager, didFetchSketches sketches: Results<Sketch>?)
    func persistentContainer(_ manager: RealmManager, didFetchUsers users: Results<User>?)
    func persistentContainer(_ manager: RealmManager, didFetchTasks tasks: Results<Task>?)
    func persistentContainer(_ manager: RealmManager, didFetchItems items: Results<Item>?)
    // create
    func persistentContainer(_ manager: RealmManager, didAddObjects objects: [Object])
    // update
    func persistentContainer(_ manager: RealmManager, didUpdateObject object: Object)
    // delete
    func didPurgeDatabase(_ manager: RealmManager)
    func persistentContainer(_ manager: RealmManager, didDeleteTasks tasks: [Task]?)
    func persistentContainer(_ manager: RealmManager, didDeleteItems items: [Item]?)
    func persistentContainer(_ manager: RealmManager, didDeleteSketches sketches: [Sketch]?)
}

extension PersistentContainerDelegate {
    // auth
    func didRegister(_ manager: RealmManager, user: User) {}
    func didLogin(_ manager: RealmManager, user: User) {}
    func didLogout(_ manager: RealmManager, user: User) {}
    // fetch
    func persistentContainer(_ manager: RealmManager, didFetch objects: Results<Object>?) {}
    func persistentContainer(_ manager: RealmManager, didFetchSketches sketches: Results<Sketch>?) {}
    func persistentContainer(_ manager: RealmManager, didFetchUsers users: Results<User>?) {}
    func persistentContainer(_ manager: RealmManager, didFetchTasks tasks: Results<Task>?) {}
    func persistentContainer(_ manager: RealmManager, didFetchItems items: Results<Item>?) {}
    // create
    func persistentContainer(_ manager: RealmManager, didAddObjects objects: [Object]) {}
    // update
    func persistentContainer(_ manager: RealmManager, didUpdateObject object: Object) {}
    // delete
    func didPurgeDatabase(_ manager: RealmManager) {}
    func persistentContainer(_ manager: RealmManager, didDeleteTasks tasks: [Task]?) {}
    func persistentContainer(_ manager: RealmManager, didDeleteItems items: [Item]?) {}
    func persistentContainer(_ manager: RealmManager, didDeleteSketches sketches: [Sketch]?) {}
}

var defaultRealm: Realm!

func setupRealm() {
    let config = Realm.Configuration(fileURL: URL.inDocumentDirectory(fileName: "default.realm"), schemaVersion: 0, migrationBlock: nil, objectTypes: [Task.self, Item.self, User.self, Sketch.self])
    defaultRealm = try! Realm(configuration: config)
}

class RealmManager: NSObject {

    weak var delegate: PersistentContainerDelegate?
    static var pathForDefaultContainer: URL? { return Realm.Configuration.defaultConfiguration.fileURL }
    static var pathForStaticContainer: URL? { return URL.inDocumentDirectory(fileName: "static.realm") }
    static var pathForTestContainer: URL? { return URL.inDocumentDirectory(fileName: "test.realm") }
    static var pathForSafeContainer: URL? { return URL.inDocumentDirectory(fileName: "safe.realm") }

    // MARK: - Database

    func purgeDatabase() {
        do {
            try defaultRealm.write {
                defaultRealm.deleteAll()
            }
            delegate?.didPurgeDatabase(self)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    // MARK: - Authentication

    func register(newUser: User) {
        do {
            try defaultRealm.write {
                defaultRealm.add(newUser, update: true)
            }
            delegate?.didRegister(self, user: newUser)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    func login(existingUser: User, pass: String) {
        // TODO: implement this
        delegate?.didLogin(self, user: existingUser)
    }

    func logout(existingUser: User) {
        // TODO: implement this
        delegate?.didLogout(self, user: existingUser)
    }

    // MARK: - Fetch

    func fetchExistingUsers() {
        let users = defaultRealm.objects(User.self)
        delegate?.persistentContainer(self, didFetchUsers: users)
    }

    func fetch(ofType: Object.Type, predicate: NSPredicate, sortedBy keyPath: String, ascending: Bool) {
        let objects = defaultRealm.objects(ofType).filter(predicate).sorted(byKeyPath: keyPath, ascending: ascending)
        delegate?.persistentContainer(self, didFetch: objects)
    }

    func fetchSketches(sortedBy keyPath: String, ascending: Bool) {
        let sketches = defaultRealm.objects(Sketch.self).sorted(byKeyPath: keyPath, ascending: ascending)
        delegate?.persistentContainer(self, didFetchSketches: sketches)
    }

    func fetchTasks(predicate: NSPredicate, sortedBy keyPath: String, ascending: Bool) {
        let tasks = defaultRealm.objects(Task.self).filter(predicate).sorted(byKeyPath: keyPath, ascending: ascending)
        delegate?.persistentContainer(self, didFetchTasks: tasks)
    }

    func fetchItems(parentTaskId: String, sortedBy keyPath: String, ascending: Bool) {
        let items = defaultRealm.object(ofType: Task.self, forPrimaryKey: parentTaskId)?.items.sorted(byKeyPath: keyPath, ascending: ascending)
        delegate?.persistentContainer(self, didFetchItems: items)
    }

    func fetchItems(parentTaskId: String, predicate: NSPredicate) {
        let items = defaultRealm.object(ofType: Task.self, forPrimaryKey: parentTaskId)?.items.filter(predicate).sorted(byKeyPath: "created_at", ascending: false)
        delegate?.persistentContainer(self, didFetchItems: items)
    }

    // MARK: - Delete

    func deleteTasks(tasks: [Task]) {
        do {
            try defaultRealm.write {
                for task in tasks {
                    if !task.items.isEmpty {
                        defaultRealm.delete(task.items)
                        defaultRealm.delete(task)
                    } else {
                        defaultRealm.delete(task)
                    }
                }
            }
            delegate?.persistentContainer(self, didDeleteTasks: tasks)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    func deleteItems(items: [Item]) {
        do {
            try defaultRealm.write {
                defaultRealm.delete(items)
            }
            delegate?.persistentContainer(self, didDeleteItems: items)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    func deleteSketches(sketches: [Sketch]) {
        do {
            try defaultRealm.write {
                defaultRealm.delete(sketches)
            }
            delegate?.persistentContainer(self, didDeleteSketches: sketches)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    // MARK: - Create

    func addObjects(objects: [Object]) {
        do {
            try defaultRealm.write {
                defaultRealm.add(objects, update: true)
            }
            delegate?.persistentContainer(self, didAddObjects: objects)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    /**
     Append an item object to the item array of its belonging task.
     - remark: Calling this delegate method will trigger the didAdd protocol.
     */
    func appendItem(_ item: Item, into parentTask: Task) {
        do {
            try defaultRealm.write {
                parentTask.items.append(item)
                defaultRealm.add(parentTask)
            }
            delegate?.persistentContainer(self, didAddObjects: [item])
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    // MARK: - Update

    func updateObject(object: Object, keyedValues: [String : Any]) {
        do {
            try defaultRealm.write {
                object.setValuesForKeys(keyedValues)
                defaultRealm.add(object, update: true)
            }
            delegate?.persistentContainer(self, didUpdateObject: object)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

}
