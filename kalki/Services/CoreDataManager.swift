import CoreData
import Foundation
import OSLog

class CoreDataManager {
    static let shared = CoreDataManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CoreData")
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "kalki")
        container.loadPersistentStores { description, error in
            if let error = error {
                self.logger.error("Core Data failed to load: \(error.localizedDescription)")
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                logger.error("Error saving context: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Food Operations
    
    func createFood(from food: Food) -> FoodEntity? {
        let entity = FoodEntity(context: viewContext)
        
        // Directly assign the UUID
        entity.id = food.id  // Direct assignment of UUID
        
        // Set other properties
        entity.name = food.name.trimmingCharacters(in: .whitespacesAndNewlines)
        entity.calories = max(0, food.calories)
        entity.protein = max(0, food.protein)
        entity.carbs = max(0, food.carbs)
        entity.fats = max(0, food.fats)
        entity.servingSize = food.servingSize?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "1 serving"
        entity.timestamp = food.timestamp
        entity.mealType = food.mealType.rawValue

        // Log the entity state for debugging
        logger.debug("Creating food entity with ID: \(String(describing: entity.id))")

        // Validate all required fields before saving
        guard let entityId = entity.id,
              let name = entity.name, !name.isEmpty,
              let servingSize = entity.servingSize, !servingSize.isEmpty,
              let mealType = entity.mealType, !mealType.isEmpty else {
            let error = "Required fields missing - ID: \(entity.id == nil), Name: \(entity.name?.isEmpty ?? true), ServingSize: \(entity.servingSize?.isEmpty ?? true), MealType: \(entity.mealType?.isEmpty ?? true)"
            logger.error("\(error)")
            viewContext.delete(entity)
            return nil
        }

        do {
            try viewContext.save()
            logger.debug("Successfully saved food entity with ID: \(entityId)")
            return entity
        } catch {
            logger.error("Error saving food entity: \(error.localizedDescription)")
            viewContext.delete(entity)
            return nil
        }
    }
    
    func updateFood(_ food: Food) -> FoodEntity? {
        let request: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", food.id as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            if let existingEntity = results.first {
                // Update properties but preserve the ID
                existingEntity.name = food.name.trimmingCharacters(in: .whitespacesAndNewlines)
                existingEntity.calories = max(0, food.calories)
                existingEntity.protein = max(0, food.protein)
                existingEntity.carbs = max(0, food.carbs)
                existingEntity.fats = max(0, food.fats)
                existingEntity.servingSize = food.servingSize?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "1 serving"
                existingEntity.timestamp = food.timestamp
                existingEntity.mealType = food.mealType.rawValue
                
                try viewContext.save()
                return existingEntity
            } else {
                // If entity doesn't exist, create a new one
                return createFood(from: food)
            }
        } catch {
            logger.error("Error updating food: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchFoods() -> [Food] {
        let request: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FoodEntity.timestamp, ascending: false)]
        
        do {
            let entities = try viewContext.fetch(request)
            return entities.compactMap { entity in
                guard let id = entity.id,
                      let name = entity.name,
                      let mealTypeString = entity.mealType,
                      let timestamp = entity.timestamp,
                      let mealType = MealType(rawValue: mealTypeString) else {
                    logger.error("Error parsing food entity: missing required properties")
                    return nil
                }
                
                return Food(
                    id: id,
                    name: name,
                    calories: entity.calories,
                    protein: entity.protein,
                    carbs: entity.carbs,
                    fats: entity.fats,
                    servingSize: entity.servingSize,
                    timestamp: timestamp,
                    mealType: mealType
                )
            }
        } catch {
            logger.error("Error fetching foods: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteFood(_ food: Food) {
        let request: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", food.id as CVarArg)
        
        do {
            let entities = try viewContext.fetch(request)
            entities.forEach { viewContext.delete($0) }
            try viewContext.save()
        } catch {
            logger.error("Error deleting food: \(error.localizedDescription)")
        }
    }
    
    func deleteAllFoods() {
        let request: NSFetchRequest<NSFetchRequestResult> = FoodEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: viewContext) as? NSBatchDeleteResult
            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
            try viewContext.save()
        } catch {
            logger.error("Error deleting all foods: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Weight Entry Operations
    
    func createWeightEntry(_ entry: WeightEntry) -> WeightEntryMO {
        let entity = WeightEntryMO(context: viewContext)
        entity.id = entry.id
        entity.weight = entry.weight
        entity.date = entry.date
        entity.note = entry.note
        save()
        return entity
    }
    
    func fetchWeightEntries() -> [WeightEntry] {
        let request = WeightEntryMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WeightEntryMO.date, ascending: false)]
        
        do {
            let entities = try viewContext.fetch(request)
            return entities.compactMap { entity in
                guard let id = entity.id,
                      let date = entity.date else {
                    logger.error("Error parsing weight entry: missing required properties")
                    return nil
                }
                return WeightEntry(
                    id: id,
                    weight: entity.weight,
                    date: date,
                    note: entity.note
                )
            }
        } catch {
            logger.error("Error fetching weight entries: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteWeightEntry(_ entry: WeightEntry) {
        let request = WeightEntryMO.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", entry.id as CVarArg)
        
        do {
            let entities = try viewContext.fetch(request)
            entities.forEach { viewContext.delete($0) }
            save()
        } catch {
            logger.error("Error deleting weight entry: \(error.localizedDescription)")
        }
    }
} 
