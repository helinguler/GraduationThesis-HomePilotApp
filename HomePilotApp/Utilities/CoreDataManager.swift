//
//  CoreDataManager.swift
//  HomePilotApp
//
//  Created by Helin Güler on 26.01.2025.
//

import CoreData
import UIKit

class CoreDataManager {
    // Singleton olarak tanımlama
    static let shared = CoreDataManager()
    private init() {}

    // CoreData veritabanının yönetildiği ana yapı
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HomePilotApp")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - User Management
    func fetchCurrentUser(uid: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", uid)
        return try? context.fetch(request).first
    }

    func createUserIfNotExists(uid: String) -> User {
        if let existingUser = fetchCurrentUser(uid: uid) {
            return existingUser
        }
        let user = User(context: context)
        user.uid = uid
        saveContext()
        return user
    }

    // MARK: - DeviceUsage Management
    func saveDeviceUsage(for user: User, result: DeviceUsageResult, deviceName: String) {
        let usage = DeviceUsage(context: context)

        usage.deviceName = deviceName
        usage.electricityUsage = result.electricityUsage ?? 0.0
        usage.electricityCost = result.electricityCost ?? 0.0
        usage.waterUsage = result.waterUsage ?? 0.0
        usage.waterCost = result.waterCost ?? 0.0
        usage.gasUsage = result.gasUsage ?? 0.0
        usage.gasCost = result.gasCost ?? 0.0
        usage.totalCost = result.totalCost
        usage.date = result.date
        usage.usageTime = result.usageTime ?? 0.0
        usage.user = user

        do {
            try context.save()
            print("Device usage saved successfully: \(usage)")
        } catch {
            print("Error saving device usage: \(error.localizedDescription)")
        }
    }

    
    func fetchDeviceUsages(for user: User) -> [DeviceUsage] {
        return user.deviceUsage?.allObjects as? [DeviceUsage] ?? []
    }
     
    
    // Belirli Tarih Aralığında(Haftalık veya Aylık) Kullanıcı Verilerini Getirme
        func fetchDeviceUsages(for user: User, from startDate: Date, to endDate: Date) -> [DeviceUsage] {
            let request: NSFetchRequest<DeviceUsage> = DeviceUsage.fetchRequest()
                request.predicate = NSPredicate(format: "user == %@ AND date >= %@ AND date <= %@", user, startDate as NSDate, endDate as NSDate)
                
                do {
                    let results = try context.fetch(request)
                    for result in results {
                        print("Fetched Device Usage - Date: \(String(describing: result.date)), Device: \(String(describing: result.deviceName))")
                    }
                    return results
                } catch {
                    print("Error fetching device usages: \(error.localizedDescription)")
                    return []
                }
        }
    
}
