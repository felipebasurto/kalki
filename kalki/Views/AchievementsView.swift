import SwiftUI

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AchievementsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Achievement.AchievementType.allCases, id: \.rawValue) { type in
                    Section(type.displayName) {
                        ForEach(viewModel.achievements.filter { $0.type == type }) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                    }
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundStyle(achievement.isUnlocked ? AppTheme.highlightColor : .secondary)
                .frame(width: 32)
            
            // Title and description
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(achievement.isUnlocked ? AppTheme.text.primary : .secondary)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Unlock status
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppTheme.highlightColor)
            } else if achievement.progress > 0 {
                // Show progress
                Text("\(achievement.progress)/\(achievement.requirement)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .opacity(achievement.isUnlocked ? 1 : 0.8)
    }
}

// MARK: - View Model
class AchievementsViewModel: ObservableObject {
    @Published private(set) var achievements: [Achievement]
    
    init() {
        // TODO: Load achievements from UserDefaults or other storage
        self.achievements = Achievement.allAchievements
    }
    
    func checkAchievements() {
        // TODO: Implement achievement checking logic
        // This will be called from various parts of the app to update achievements
    }
} 