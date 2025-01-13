import SwiftUI

/// CalcView provides a user interface for calculating daily nutritional needs.
///
/// - Views:
///   - StatCard: Displays user stats with appropriate formatting and styling.
///   - ResultRow: Displays calculation results with appropriate formatting and styling.
struct CalcView: View {
    @AppStorage("userWeight") private var weight = ""
    @AppStorage("userHeight") private var height = ""
    @AppStorage("userAge") private var age = ""
    @AppStorage("userGender") private var gender = "Male"
    @AppStorage("userActivityLevel") private var activityLevel = "Moderate Exercise"
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal = "2000"
    @AppStorage("dailyProteinGoal") private var dailyProteinGoal = "150"
    @AppStorage("useMetricSystem") private var useMetricSystem = true
    
    @StateObject private var weightTracker = WeightTrackingService()
    @State private var showingResults = false
    @State private var animatingStats = false
    @State private var showingSaveConfirmation = false
    @State private var showingAddWeight = false
    @State private var newWeight = ""
    @State private var weightNote = ""
    
    @State private var bmr: Double = 0
    @State private var tdee: Double = 0
    @State private var recommendedProtein: Double = 0
    
    let activityMultipliers = [
        "Sedentary": 1.2,
        "Light Exercise": 1.375,
        "Moderate Exercise": 1.55,
        "Heavy Exercise": 1.725,
        "Athlete": 1.9
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Calculate Your Needs")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color("PrimaryBlue"))
                
                // Weight tracking section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Weight Tracking")
                            .font(.headline)
                            .foregroundStyle(Color("PrimaryBlue"))
                        
                        Spacer()
                        
                        Button {
                            showingAddWeight = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(AppTheme.accentColor)
                        }
                    }
                    
                    WeightGraph(entries: weightTracker.weightEntries, useMetricSystem: useMetricSystem)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 2)
                
                // Current Stats Card with hover effect
                VStack(spacing: 16) {
                    Text("Your Stats")
                        .font(.headline)
                        .foregroundStyle(Color("PrimaryBlue"))
                    
                    HStack(spacing: 20) {
                        StatCard(
                            value: weight,
                            unit: useMetricSystem ? "kg" : "lbs",
                            label: "Weight",
                            icon: "scalemass",
                            color: AppTheme.accentColor
                        )
                        .scaleEffect(animatingStats ? 1 : 0.9)
                        
                        StatCard(
                            value: height,
                            unit: useMetricSystem ? "cm" : "in",
                            label: "Height",
                            icon: "ruler",
                            color: AppTheme.highlightColor
                        )
                        .scaleEffect(animatingStats ? 1 : 0.9)
                        
                        StatCard(
                            value: age,
                            unit: "yrs",
                            label: "Age",
                            icon: "calendar",
                            color: Color("PrimaryBlue")
                        )
                        .scaleEffect(animatingStats ? 1 : 0.9)
                    }
                }
                .padding()
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        animatingStats = true
                    }
                }
                
                // Calculate Button with haptic feedback
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    calculateNeeds()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showingResults = true
                    }
                } label: {
                    Text("Calculate Needs")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            AppTheme.accentColor
                                .opacity(weight.isEmpty || height.isEmpty || age.isEmpty ? 0.5 : 1)
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(weight.isEmpty || height.isEmpty || age.isEmpty)
                
                if showingResults {
                    // Results Card with animations
                    VStack(spacing: 20) {
                        Text("Your Daily Needs")
                            .font(.headline)
                        
                        VStack(spacing: 16) {
                            ResultRow(
                                label: "Basal Metabolic Rate",
                                value: Int(bmr),
                                unit: "calories",
                                description: "Calories burned at complete rest",
                                color: AppTheme.primaryColor
                            )
                            
                            Divider()
                            
                            ResultRow(
                                label: "Total Daily Energy",
                                value: Int(tdee),
                                unit: "calories",
                                description: "Calories needed to maintain weight",
                                color: AppTheme.accentColor
                            )
                            
                            Divider()
                            
                            ResultRow(
                                label: "Protein Target",
                                value: Int(recommendedProtein),
                                unit: "grams",
                                description: "Recommended daily protein intake",
                                color: AppTheme.highlightColor
                            )
                        }
                        
                        // Save Goals Button with confirmation
                        Button(role: .none) {
                            showingSaveConfirmation = true
                            saveGoals()
                        } label: {
                            Text("Save")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(showingSaveConfirmation ? AppTheme.successColor : AppTheme.primaryColor)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding()
        }
        .navigationTitle("Calculator")
        .background(AppTheme.background)
        .sheet(isPresented: $showingAddWeight) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Weight", text: $newWeight)
                            .keyboardType(.decimalPad)
                        
                        TextField("Note (optional)", text: $weightNote)
                    }
                }
                .navigationTitle("Add Weight Entry")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingAddWeight = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            if let weightValue = Double(newWeight) {
                                weightTracker.addWeightEntry(
                                    weight: useMetricSystem ? weightValue : weightValue / 2.20462,
                                    note: weightNote.isEmpty ? nil : weightNote
                                )
                                showingAddWeight = false
                                newWeight = ""
                                weightNote = ""
                            }
                        }
                        .disabled(Double(newWeight) == nil)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                animatingStats = true
            }
        }
    }
    
    private func calculateNeeds() {
        guard let weightKg = Double(weight),
              let heightCm = Double(height),
              let ageYears = Double(age) else {
            // Handle invalid input
            print("Invalid input: Please enter valid weight, height, and age.")
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
    }
    
    private func saveGoals() {
        dailyCalorieGoal = String(Int(tdee))
        dailyProteinGoal = String(Int(recommendedProtein))
    }
}

struct StatCard: View {
    let value: String
    let unit: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            VStack(spacing: 4) {
                Text(value.isEmpty ? "--" : value)
                    .font(.headline)
                + Text(" \(unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationStack {
        CalcView()
    }
} 