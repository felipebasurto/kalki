import SwiftUI

struct EditFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FoodLogViewModel
    let food: Food
    
    @State private var name: String
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fats: String
    @State private var servingSize: String
    @State private var mealType: MealType
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case name, servingSize, calories, protein, carbs, fats
    }
    
    init(viewModel: FoodLogViewModel, food: Food) {
        self.viewModel = viewModel
        self.food = food
        
        // Initialize state with food values
        _name = State(initialValue: food.name)
        _calories = State(initialValue: String(format: "%.1f", food.calories))
        _protein = State(initialValue: String(format: "%.1f", food.protein))
        _carbs = State(initialValue: String(format: "%.1f", food.carbs))
        _fats = State(initialValue: String(format: "%.1f", food.fats))
        _servingSize = State(initialValue: food.servingSize ?? "")
        _mealType = State(initialValue: food.mealType)
    }
    
    private var hasChanges: Bool {
        let currentCalories = Double(calories) ?? food.calories
        let currentProtein = Double(protein) ?? food.protein
        let currentCarbs = Double(carbs) ?? food.carbs
        let currentFats = Double(fats) ?? food.fats
        
        return name != food.name ||
            abs(currentCalories - food.calories) > 0.01 ||
            abs(currentProtein - food.protein) > 0.01 ||
            abs(currentCarbs - food.carbs) > 0.01 ||
            abs(currentFats - food.fats) > 0.01 ||
            mealType != food.mealType
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Food Details") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .name)
                    
                    TextField("Serving Size", text: $servingSize)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .servingSize)
                }
                
                Section("Nutrition") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .calories)
                        Text("kcal")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .protein)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .carbs)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Fats")
                        Spacer()
                        TextField("0", text: $fats)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .fats)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Meal Type") {
                    Picker("Meal", selection: $mealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }
            }
            .navigationTitle("Edit Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        focusedField = nil
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        focusedField = nil
                        if let index = viewModel.foods.firstIndex(where: { $0.id == food.id }),
                           let caloriesValue = Double(calories),
                           let proteinValue = Double(protein),
                           let carbsValue = Double(carbs),
                           let fatsValue = Double(fats) {
                            viewModel.updateFood(
                                at: index,
                                name: name,
                                calories: caloriesValue,
                                protein: proteinValue,
                                carbs: carbsValue,
                                fats: fatsValue,
                                servingSize: servingSize.isEmpty ? nil : servingSize,
                                mealType: mealType
                            )
                            dismiss()
                        }
                    }
                    .disabled(!hasChanges || name.isEmpty)
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }
}

#Preview {
    EditFoodView(
        viewModel: FoodLogViewModel(nutritionService: MockNutritionService()),
        food: Food(
            name: "Chicken Breast",
            calories: 165,
            protein: 31,
            carbs: 0,
            fats: 3.6,
            servingSize: "100g",
            mealType: .lunch
        )
    )
} 