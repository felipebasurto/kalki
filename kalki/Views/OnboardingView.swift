import SwiftUI

/// OnboardingView provides a user interface for onboarding new users.
///
/// - Views:
///   - UserInfoForm: Collects user information and shows calculated goals.
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // User data
    @AppStorage("userWeight") private var weight = ""
    @AppStorage("userHeight") private var height = ""
    @AppStorage("userAge") private var age = ""
    @AppStorage("userGender") private var gender = "Male"
    @AppStorage("userActivityLevel") private var activityLevel = "Moderate Exercise"
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal = ""
    @AppStorage("dailyProteinGoal") private var dailyProteinGoal = ""
    @AppStorage("dailyExerciseGoal") private var dailyExerciseGoal = ""
    @AppStorage("useMetricSystem") private var useMetricSystem = true
    
    @State private var bmr: Double = 0
    @State private var tdee: Double = 0
    @State private var recommendedProtein: Double = 0
    @State private var recommendedExercise: Double = 0
    @State private var showingGoals = false
    
    let genders = ["Male", "Female"]
    let activityLevels = ["Sedentary", "Light Exercise", "Moderate Exercise", "Heavy Exercise", "Athlete"]
    let activityMultipliers = [
        "Sedentary": 1.2,
        "Light Exercise": 1.375,
        "Moderate Exercise": 1.55,
        "Heavy Exercise": 1.725,
        "Athlete": 1.9
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // Welcome header
                Section {
                    VStack(spacing: 8) {
                        Text("Welcome to kalki")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Let's set up your personal goals")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: "figure.run")
                            .font(.system(size: 80))
                            .foregroundStyle(AppTheme.accentColor)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
                
                Section("Personal Information") {
                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender)
                        }
                    }
                    
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        Text(useMetricSystem ? "kg" : "lbs")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        TextField("Height", text: $height)
                            .keyboardType(.decimalPad)
                        Text(useMetricSystem ? "cm" : "in")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                        Text("years")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Activity Level") {
                    Picker("Activity", selection: $activityLevel) {
                        ForEach(activityLevels, id: \.self) { level in
                            Text(level)
                        }
                    }
                }
                
                Section {
                    Toggle("Use Metric System", isOn: $useMetricSystem)
                }
                
                if showingGoals {
                    Section("Your Daily Goals") {
                        GoalRow(
                            label: "Basal Metabolic Rate",
                            value: Int(bmr),
                            unit: "calories",
                            description: "Calories burned at complete rest",
                            color: AppTheme.ringColors.primary
                        )
                        
                        GoalRow(
                            label: "Total Daily Energy",
                            value: Int(tdee),
                            unit: "calories",
                            description: "Calories needed to maintain weight",
                            color: AppTheme.ringColors.secondary
                        )
                        
                        GoalRow(
                            label: "Protein Target",
                            value: Int(recommendedProtein),
                            unit: "grams",
                            description: "Recommended daily protein intake",
                            color: AppTheme.ringColors.tertiary
                        )
                        
                        GoalRow(
                            label: "Exercise Target",
                            value: Int(recommendedExercise),
                            unit: "calories",
                            description: "Recommended daily active calories",
                            color: AppTheme.ringColors.tertiary
                        )
                    }
                }
                
                Section {
                    Button {
                        if showingGoals {
                            saveGoals()
                            hasCompletedOnboarding = true
                        } else {
                            calculateNeeds()
                            withAnimation {
                                showingGoals = true
                            }
                        }
                    } label: {
                        Text(showingGoals ? "Save & Continue" : "Calculate Goals")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .disabled(!canCalculate)
                    .listRowBackground(
                        AppTheme.accentColor
                            .opacity(canCalculate ? 1 : 0.5)
                    )
                    .foregroundColor(.white)
                }
            }
        }
        .onChange(of: useMetricSystem) { oldValue, newValue in
            if showingGoals {
                calculateNeeds()
            }
        }
    }
    
    private var canCalculate: Bool {
        !weight.isEmpty && !height.isEmpty && !age.isEmpty
    }
    
    private func calculateNeeds() {
        guard let weightKg = Double(weight),
              let heightCm = Double(height),
              let ageYears = Double(age) else {
            return
        }
        
        // Convert to metric if needed
        let weightInKg = useMetricSystem ? weightKg : weightKg * 0.453592
        let heightInCm = useMetricSystem ? heightCm : heightCm * 2.54
        
        // Calculate BMR using Mifflin-St Jeor Equation
        if gender == "Male" {
            bmr = (10 * weightInKg) + (6.25 * heightInCm) - (5 * ageYears) + 5
        } else {
            bmr = (10 * weightInKg) + (6.25 * heightInCm) - (5 * ageYears) - 161
        }
        
        // Calculate TDEE
        if let multiplier = activityMultipliers[activityLevel] {
            tdee = bmr * multiplier
        }
        
        // Calculate protein needs (1.6-2.2g per kg of body weight)
        recommendedProtein = weightInKg * 1.8 // Using middle of range
        
        // Calculate recommended exercise calories (15-25% of TDEE)
        recommendedExercise = tdee * 0.2 // Using 20% as a default target
    }
    
    private func saveGoals() {
        dailyCalorieGoal = String(Int(tdee))
        dailyProteinGoal = String(Int(recommendedProtein))
        dailyExerciseGoal = String(Int(recommendedExercise))
    }
}

#Preview {
    OnboardingView()
} 