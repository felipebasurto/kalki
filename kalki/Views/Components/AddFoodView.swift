import SwiftUI

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FoodLogViewModel
    let selectedDate: Date
    
    @State private var foodName = ""
    @State private var selectedMealType: MealType = .breakfast
    @State private var isAnalyzing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showingFoodAdded = false
    @State private var analyzedFood: Food?
    @FocusState private var isFoodNameFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Food Details") {
                    TextField("Food description", text: $foodName, axis: .vertical)
                        .lineLimit(3...6)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(isAnalyzing)
                        .focused($isFoodNameFocused)
                    
                    Picker("Meal Type", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .disabled(isAnalyzing)
                }
                
                if isAnalyzing {
                    Section {
                        HStack {
                            Spacer()
                            AIAnalyzingAnimation()
                            Spacer()
                        }
                    }
                }
                
                if let food = analyzedFood {
                    Section {
                        FoodAnalysisCard(food: food)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isFoodNameFocused = false
                        dismiss()
                    }
                    .disabled(isAnalyzing)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        isFoodNameFocused = false
                        addFood()
                    }
                    .disabled(foodName.isEmpty || isAnalyzing)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            isFoodNameFocused = false
                        }
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if showingFoodAdded {
                    FoodAddedAnimation()
                }
            }
        }
        .interactiveDismissDisabled(isAnalyzing)
    }
    
    private func addFood() {
        guard !foodName.isEmpty else { return }
        
        // Don't allow adding foods in future dates
        guard selectedDate <= Date() else {
            errorMessage = "Cannot add foods for future dates"
            showError = true
            return
        }
        
        // Create a timestamp that preserves today's time but uses the selected date
        let now = Date()
        let calendar = Calendar.current
        let selectedComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: now)
        let timestamp = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                    minute: timeComponents.minute ?? 0,
                                    second: 0,
                                    of: calendar.date(from: selectedComponents) ?? selectedDate) ?? selectedDate
        
        Task {
            isAnalyzing = true
            do {
                // First analyze the food
                let analyzed = try await viewModel.analyzeFood(foodName)
                withAnimation {
                    analyzedFood = Food(
                        name: analyzed.name,
                        calories: analyzed.calories,
                        protein: analyzed.protein,
                        carbs: analyzed.carbs,
                        fats: analyzed.fats,
                        servingSize: analyzed.servingSize,
                        timestamp: timestamp,
                        mealType: selectedMealType
                    )
                }
                
                // Then add it to the log
                try await viewModel.addFood(foodName, mealType: selectedMealType, timestamp: timestamp)
                showingFoodAdded = true
                // Dismiss after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    isFoodNameFocused = false
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isAnalyzing = false
        }
    }
}

#Preview {
    AddFoodView(
        viewModel: FoodLogViewModel(nutritionService: MockNutritionService()),
        selectedDate: Date()
    )
} 