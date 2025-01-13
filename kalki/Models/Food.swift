import Foundation

public enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snacks = "Snacks"
    
    public var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snacks: return "carrot.fill"
        }
    }
}

public struct Food: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let calories: Double
    public let protein: Double
    public let carbs: Double
    public let fats: Double
    public let servingSize: String?
    public let timestamp: Date
    public let mealType: MealType
    
    public enum CodingKeys: String, CodingKey {
        case id, name, calories, protein, carbs, fats, servingSize, timestamp, mealType
    }
    
    public init(id: UUID? = nil, name: String, calories: Double, protein: Double, carbs: Double, fats: Double, servingSize: String? = nil, timestamp: Date = Date(), mealType: MealType = .snacks) {
        self.id = id ?? UUID()
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.calories = max(0, calories)
        self.protein = max(0, protein)
        self.carbs = max(0, carbs)
        self.fats = max(0, fats)
        self.servingSize = servingSize?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "1 serving"
        self.timestamp = timestamp
        self.mealType = mealType
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            id = try container.decode(UUID.self, forKey: .id)
        } catch {
            id = UUID()
            print("Generated new UUID due to decoding failure: \(error.localizedDescription)")
        }
        
        let rawName = try container.decode(String.self, forKey: .name)
        name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            throw DecodingError.dataCorruptedError(forKey: .name, in: container, debugDescription: "Name cannot be empty")
        }
        
        calories = max(0, try container.decode(Double.self, forKey: .calories))
        protein = max(0, try container.decode(Double.self, forKey: .protein))
        carbs = max(0, try container.decode(Double.self, forKey: .carbs))
        fats = max(0, try container.decode(Double.self, forKey: .fats))
        
        let rawServingSize = try container.decodeIfPresent(String.self, forKey: .servingSize)
        servingSize = (rawServingSize?.trimmingCharacters(in: .whitespacesAndNewlines)) ?? "1 serving"
        
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        mealType = try container.decodeIfPresent(MealType.self, forKey: .mealType) ?? .snacks
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(calories, forKey: .calories)
        try container.encode(protein, forKey: .protein)
        try container.encode(carbs, forKey: .carbs)
        try container.encode(fats, forKey: .fats)
        try container.encodeIfPresent(servingSize, forKey: .servingSize)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(mealType, forKey: .mealType)
    }
} 