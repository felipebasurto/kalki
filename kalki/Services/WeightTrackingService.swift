import Foundation
import CoreData

class WeightTrackingService: ObservableObject {
    private let coreDataManager: CoreDataManager
    @Published private(set) var weightEntries: [WeightEntry] = []
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
        loadWeightEntries()
    }
    
    func addWeightEntry(weight: Double, note: String? = nil) {
        let entry = WeightEntry(weight: weight, note: note)
        _ = coreDataManager.createWeightEntry(entry)
        weightEntries.append(entry)
        weightEntries.sort { $0.date > $1.date }
    }
    
    private func loadWeightEntries() {
        weightEntries = coreDataManager.fetchWeightEntries()
    }
    
    func deleteWeightEntry(id: UUID) {
        if let entry = weightEntries.first(where: { $0.id == id }) {
            coreDataManager.deleteWeightEntry(entry)
            weightEntries.removeAll { $0.id == id }
        }
    }
} 