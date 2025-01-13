import SwiftUI

struct FoodLogView: View {
    @ObservedObject var viewModel: FoodLogViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingAddFood = false
    @State private var showingEditFood = false
    @State private var selectedFood: Food?
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @State private var showingDeleteAlert = false
    @State private var foodToDelete: Food?
    @State private var slideDirection: Edge = .trailing
    @AppStorage("hasSeenMealBreakdownTip") private var hasSeenMealBreakdownTip = false
    @State private var showingTip = false
    @State private var hasShownTipForToday = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }
    
    private var foodsByMeal: [(id: String, mealType: MealType, foods: [Food])] {
        let calendar = Calendar.current
        let todaysFoods = viewModel.foods.filter {
            calendar.isDate($0.timestamp, inSameDayAs: selectedDate)
        }
        
        let grouped = Dictionary(grouping: todaysFoods) { $0.mealType }
        let sortedKeys: [MealType] = [.breakfast, .lunch, .dinner, .snacks]
        
        return sortedKeys.map { mealType in
            let stableId = "\(selectedDate.timeIntervalSince1970)_\(mealType.rawValue)"
            let foods = (grouped[mealType] ?? []).sorted { $0.timestamp < $1.timestamp }
            return (id: stableId, mealType: mealType, foods: foods)
        }
    }
    
    private var totalCalories: Int {
        foodsByMeal.flatMap { $0.foods }.reduce(0) { $0 + Int($1.calories) }
    }
    
    private var totalCarbs: Double {
        foodsByMeal.flatMap { $0.foods }.reduce(0) { $0 + $1.carbs }
    }
    
    private var totalProtein: Double {
        foodsByMeal.flatMap { $0.foods }.reduce(0) { $0 + $1.protein }
    }
    
    private var totalFat: Double {
        foodsByMeal.flatMap { $0.foods }.reduce(0) { $0 + $1.fats }
    }
    
    private let minimumDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
    
    private func moveDate(by days: Int) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .day, value: days, to: selectedDate) {
            if newDate <= Date() {
                slideDirection = days < 0 ? .trailing : .leading
                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                    selectedDate = calendar.startOfDay(for: newDate)
                }
            }
        }
    }
    
    private func foodRow(_ food: Food) -> some View {
        FoodRow(food: food)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedFood = food
                showingEditFood = true
            }
            .contextMenu {
                Button {
                    selectedFood = food
                    showingEditFood = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    foodToDelete = food
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
    
    private var hasAllMealTypes: Bool {
        let mealTypes = Set(foodsByMeal.filter { !$0.foods.isEmpty }.map { $0.mealType })
        return mealTypes.count == MealType.allCases.count
    }
    
    private var shouldShowTip: Bool {
        !hasShownTipForToday && hasAllMealTypes && !hasSeenMealBreakdownTip && showingTip
    }
    
    private var calorieCircleView: some View {
        ZStack(alignment: .topTrailing) {
            CalorieCircle(
                caloriesEaten: totalCalories,
                caloriesBurned: 651,
                calorieGoal: 2500,
                mealBreakdown: foodsByMeal.map { section in
                    (mealType: section.mealType,
                     calories: section.foods.reduce(0) { $0 + Int($1.calories) })
                }
            )
            .onChange(of: hasAllMealTypes) { _, newValue in
                if newValue && !hasShownTipForToday && !hasSeenMealBreakdownTip {
                    showingTip = true
                    hasShownTipForToday = true
                    // Auto-dismiss after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showingTip = false
                            hasSeenMealBreakdownTip = true
                        }
                    }
                }
            }
            
            if shouldShowTip {
                Text("Tap to see meal breakdown!")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("PrimaryBlue"))
                    )
                    .padding(.trailing, 24)
                    .padding(.top, 12)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var macroProgressView: some View {
        HStack(spacing: 12) {
            MacroProgressBar(
                label: "Carbs",
                current: totalCarbs,
                target: 359,
                color: AppTheme.highlightColor
            )
            
            MacroProgressBar(
                label: "Protein",
                current: totalProtein,
                target: 143,
                color: AppTheme.accentColor
            )
            
            MacroProgressBar(
                label: "Fat",
                current: totalFat,
                target: 96,
                color: AppTheme.successColor
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(.systemGray4).opacity(colorScheme == .dark ? 0.3 : 0.12), radius: 8, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    private var dateNavigationView: some View {
        HStack {
            Button {
                moveDate(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            
            Button {
                showingDatePicker = true
            } label: {
                Text(dateFormatter.string(from: selectedDate).uppercased())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Button {
                moveDate(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .disabled(Calendar.current.isDateInToday(selectedDate))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color(.systemGray4).opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 6, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color("PrimaryBlue"))
            
            Text("No meals logged today")
                .font(.title3)
                .foregroundStyle(Color("PrimaryBlue"))
            
            Text("Tap + to add your first meal")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 32)
        .transition(.scale.combined(with: .opacity))
    }
    
    private func mealSectionView(_ section: (id: String, mealType: MealType, foods: [Food])) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: section.mealType.icon)
                    .foregroundStyle(Color("PrimaryBlue"))
                Text(section.mealType.rawValue)
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryBlue"))
            }
            .padding(.bottom, 4)
            
            ForEach(section.foods) { food in
                foodRow(food)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color(.systemGray4).opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 4, x: 0, y: 2)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.8)
                                .combined(with: .opacity)
                                .combined(with: .offset(x: slideDirection == .leading ? 20 : -20, y: 0)),
                            removal: .scale(scale: 0.8)
                                .combined(with: .opacity)
                                .combined(with: .offset(x: slideDirection == .leading ? -20 : 20, y: 0))
                        )
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(.systemGray4).opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 12, x: 0, y: 5)
    }
    
    private var addButton: some View {
        Button {
            showingAddFood = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(AppTheme.accentColor)
                        .shadow(color: Color(.systemGray4).opacity(colorScheme == .dark ? 0.3 : 0.2), radius: 8, x: 0, y: 4)
                )
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private func slideTransition(scale: Double) -> AnyTransition {
        .asymmetric(
            insertion: .scale(scale: scale)
                .combined(with: .opacity)
                .combined(with: .offset(x: slideDirection == .leading ? 20 : -20, y: 0)),
            removal: .scale(scale: scale)
                .combined(with: .opacity)
                .combined(with: .offset(x: slideDirection == .leading ? -20 : 20, y: 0))
        )
    }
    
    private func foodSectionsView(_ sections: [(id: String, mealType: MealType, foods: [Food])]) -> some View {
        VStack(spacing: 16) {
            ForEach(sections, id: \.id) { section in
                if !section.foods.isEmpty {
                    mealSectionView(section)
                        .transition(slideTransition(scale: 0.95))
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        VStack(spacing: 16) {
                            calorieCircleView
                            macroProgressView
                            dateNavigationView
                            
                            if foodsByMeal.flatMap({ $0.foods }).isEmpty {
                                emptyStateView
                            } else {
                                foodSectionsView(foodsByMeal)
                                    .padding(.horizontal)
                            }
                            
                            Color.clear.frame(height: 80)
                        }
                    }
                }
            }
            
            addButton
        }
        .navigationTitle("Food Log")
        .sheet(isPresented: $showingAddFood) {
            AddFoodView(viewModel: viewModel, selectedDate: selectedDate)
        }
        .sheet(isPresented: $showingEditFood) {
            if let food = selectedFood {
                EditFoodView(viewModel: viewModel, food: food)
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(
                selectedDate: $selectedDate,
                minimumDate: minimumDate,
                maximumDate: Date()
            )
        }
        .alert("Delete Food", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let food = foodToDelete {
                    withAnimation {
                        viewModel.deleteFood(food)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this food entry?")
        }
    }
}

#Preview {
    FoodLogView(viewModel: FoodLogViewModel())
} 
