import Foundation

typealias WeightLog = WeightEntry

class WeightLogViewModel: ObservableObject {
    @Published var logs: [WeightLog] = []
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
        loadLogs()
    }
    
    func addLog(_ weight: Double) {
        let entry = WeightEntry(weight: weight)
        _ = coreDataManager.createWeightEntry(entry)
        logs.append(entry)
        logs.sort { $0.date > $1.date }
    }
    
    private func loadLogs() {
        logs = coreDataManager.fetchWeightEntries()
    }
    
    func deleteLog(_ log: WeightLog) {
        coreDataManager.deleteWeightEntry(log)
        if let index = logs.firstIndex(where: { $0.id == log.id }) {
            logs.remove(at: index)
        }
    }
} 