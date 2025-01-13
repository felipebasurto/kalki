import Foundation

struct WeightEntry: Identifiable, Codable {
    let id: UUID
    let weight: Double
    let date: Date
    let note: String?
    
    init(id: UUID = UUID(), weight: Double, date: Date = Date(), note: String? = nil) {
        self.id = id
        self.weight = weight
        self.date = date
        self.note = note
    }
} 