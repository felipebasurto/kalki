import Foundation

/// OpenAI-based implementation of the NutritionService protocol.
class OpenAINutritionService: NutritionService {
    private let apiKey: String
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func analyzeFood(_ name: String) async throws -> Food {
        // Use a simpler prompt for basic analysis
        return try await analyzeWithAI(name, detailed: false)
    }
    
    func analyzeDetailedFood(_ description: String) async throws -> Food {
        return try await analyzeWithAI(description, detailed: true)
    }
    
    private func analyzeWithAI(_ description: String, detailed: Bool) async throws -> Food {
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        Analyze the following food description and return a JSON object with nutritional information.
        Food description: "\(description)"
        
        Return format:
        {
            "name": "descriptive name",
            "calories": number,
            "protein": number (in grams),
            "carbs": number (in grams),
            "fats": number (in grams),
            "servingSize": "serving size description",
            "mealType": "breakfast/lunch/dinner/snack" (optional)
        }
        
        \(detailed ? "Provide detailed analysis including ingredients and portion sizes." : "Provide basic nutritional estimates.")
        Be conservative with estimates. If unsure, provide lower estimates.
        """
        
        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are a nutrition expert that analyzes food descriptions and provides detailed nutritional information."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 500
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let content = response.choices.first?.message.content,
              let jsonData = content.data(using: .utf8),
              let nutritionInfo = try? JSONDecoder().decode(Food.self, from: jsonData) else {
            throw NSError(domain: "OpenAINutritionService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse nutrition information"])
        }
        
        return nutritionInfo
    }
}

private struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
} 