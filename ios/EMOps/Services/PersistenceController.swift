import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = PersistenceController.createManagedObjectModel()
        container = NSPersistentContainer(name: "EMOps", managedObjectModel: model)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("CoreData load error: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Programmatic CoreData Model

    private static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // CachedWeeklySheet entity
        let sheetEntity = NSEntityDescription()
        sheetEntity.name = "CachedWeeklySheet"
        sheetEntity.managedObjectClassName = "CachedWeeklySheet"
        sheetEntity.properties = [
            makeStringAttribute(name: "id"),
            makeStringAttribute(name: "weekStart"),
            makeStringAttribute(name: "weekLabel"),
            makeStringAttribute(name: "status"),
            makeStringAttribute(name: "jsonData")
        ]

        // CachedHabit entity
        let habitEntity = NSEntityDescription()
        habitEntity.name = "CachedHabit"
        habitEntity.managedObjectClassName = "CachedHabit"
        habitEntity.properties = [
            makeStringAttribute(name: "id"),
            makeStringAttribute(name: "name"),
            makeStringAttribute(name: "category"),
            makeStringAttribute(name: "jsonData")
        ]

        // CachedHabitLog entity
        let habitLogEntity = NSEntityDescription()
        habitLogEntity.name = "CachedHabitLog"
        habitLogEntity.managedObjectClassName = "CachedHabitLog"
        habitLogEntity.properties = [
            makeStringAttribute(name: "id"),
            makeStringAttribute(name: "habitId"),
            makeStringAttribute(name: "logDate"),
            makeBoolAttribute(name: "isCompleted"),
            makeStringAttribute(name: "jsonData")
        ]

        // CachedDsaaLog entity
        let dsaaLogEntity = NSEntityDescription()
        dsaaLogEntity.name = "CachedDsaaLog"
        dsaaLogEntity.managedObjectClassName = "CachedDsaaLog"
        dsaaLogEntity.properties = [
            makeStringAttribute(name: "id"),
            makeStringAttribute(name: "logDate"),
            makeStringAttribute(name: "dsaaAction"),
            makeStringAttribute(name: "jsonData")
        ]

        model.entities = [sheetEntity, habitEntity, habitLogEntity, dsaaLogEntity]
        return model
    }

    private static func makeStringAttribute(name: String) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = .stringAttributeType
        attr.isOptional = true
        return attr
    }

    private static func makeBoolAttribute(name: String) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = .booleanAttributeType
        attr.isOptional = false
        attr.defaultValue = false
        return attr
    }

    // MARK: - Save

    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("CoreData save error: \(error)")
            }
        }
    }

    // MARK: - Clear All

    func clearAll() {
        let entityNames = ["CachedWeeklySheet", "CachedHabit", "CachedHabitLog", "CachedDsaaLog"]
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try viewContext.execute(deleteRequest)
            } catch {
                print("Failed to clear \(entityName): \(error)")
            }
        }
        saveContext()
    }

    // MARK: - Weekly Sheet Cache

    func cacheWeeklySheet(_ sheet: WeeklySheet) {
        let context = viewContext

        // Remove existing cached sheets
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedWeeklySheet")
        fetchRequest.predicate = NSPredicate(format: "id == %@", sheet.id)
        if let results = try? context.fetch(fetchRequest) as? [NSManagedObject] {
            for obj in results {
                context.delete(obj)
            }
        }

        // Insert new
        guard let entity = NSEntityDescription.entity(forEntityName: "CachedWeeklySheet", in: context) else { return }
        let managed = NSManagedObject(entity: entity, insertInto: context)
        managed.setValue(sheet.id, forKey: "id")
        managed.setValue(sheet.weekStart, forKey: "weekStart")
        managed.setValue(sheet.weekLabel, forKey: "weekLabel")
        managed.setValue(sheet.status.rawValue, forKey: "status")

        if let jsonData = try? JSONEncoder().encode(sheet),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            managed.setValue(jsonString, forKey: "jsonData")
        }

        saveContext()
    }

    func getCachedSheet() -> WeeklySheet? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedWeeklySheet")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "weekStart", ascending: false)]
        fetchRequest.fetchLimit = 1

        guard let results = try? viewContext.fetch(fetchRequest) as? [NSManagedObject],
              let first = results.first,
              let jsonString = first.value(forKey: "jsonData") as? String,
              let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(WeeklySheet.self, from: jsonData)
    }

    // MARK: - Habits Cache

    func cacheHabits(_ habits: [Habit]) {
        let context = viewContext

        // Clear existing cached habits
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedHabit")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)

        // Insert new
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        guard let entity = NSEntityDescription.entity(forEntityName: "CachedHabit", in: context) else { return }

        for habit in habits {
            let managed = NSManagedObject(entity: entity, insertInto: context)
            managed.setValue(habit.id, forKey: "id")
            managed.setValue(habit.name, forKey: "name")
            managed.setValue(habit.category.rawValue, forKey: "category")

            if let jsonData = try? encoder.encode(habit),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                managed.setValue(jsonString, forKey: "jsonData")
            }
        }

        saveContext()
    }

    func getCachedHabits() -> [Habit] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedHabit")

        guard let results = try? viewContext.fetch(fetchRequest) as? [NSManagedObject] else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return results.compactMap { obj in
            guard let jsonString = obj.value(forKey: "jsonData") as? String,
                  let jsonData = jsonString.data(using: .utf8) else {
                return nil
            }
            return try? decoder.decode(Habit.self, from: jsonData)
        }
    }
}
