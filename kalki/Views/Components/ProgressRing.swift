import SwiftUI

/// ProgressRing displays a circular progress indicator with customizable color and thickness.
struct ProgressRing: View {
    let progress: Double
    let color: Color
    let thickness: CGFloat
    
    @State private var animatedProgress: Double = 0
    @State private var scale: CGFloat = 0.8
    @Environment(\.colorScheme) private var colorScheme
    
    init(progress: Double, color: Color = AppTheme.ringColors.primary, thickness: CGFloat = 12) {
        // Ensure progress is a valid number between 0 and 1
        let validProgress = if progress.isNaN || progress.isInfinite {
            0.0
        } else {
            max(0, min(progress, 1))
        }
        self.progress = validProgress
        self.color = color
        self.thickness = thickness
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    color.opacity(colorScheme == .dark ? 0.15 : 0.2),
                    lineWidth: thickness
                )
                .shadow(
                    color: Color(.systemGray4).opacity(colorScheme == .dark ? 0.3 : 0.2),
                    radius: thickness/4,
                    x: 0,
                    y: thickness/8
                )
            
            // Progress ring with glow
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: thickness,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .shadow(
                    color: Color(.systemGray4).opacity(0.3),
                    radius: thickness/3,
                    x: 0,
                    y: thickness/6
                )
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

/// ProgressRings composes multiple ProgressRing components to display different types of progress.
struct ProgressRings: View {
    let calorieProgress: Double
    let proteinProgress: Double
    let exerciseProgress: Double
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @Environment(\.colorScheme) private var colorScheme
    
    private func validateProgress(_ value: Double) -> Double {
        if value.isNaN || value.isInfinite {
            return 0.0
        }
        return max(0, min(value, 1))
    }
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(AppTheme.accentColor)
                .opacity(colorScheme == .dark ? 0.08 : 0.05)
                .blur(radius: 15)
                .scaleEffect(1.2)
            
            // Connecting lines
            Circle()
                .trim(from: 0.2, to: 0.3)
                .stroke(Color(.systemGray4).opacity(colorScheme == .dark ? 0.3 : 0.4), lineWidth: 1)
                .frame(width: 135, height: 135)
            
            Circle()
                .trim(from: 0.7, to: 0.8)
                .stroke(Color(.systemGray4).opacity(colorScheme == .dark ? 0.3 : 0.4), lineWidth: 1)
                .frame(width: 105, height: 105)
            
            // Exercise ring (outer)
            ProgressRing(
                progress: validateProgress(exerciseProgress),
                color: AppTheme.ringColors.tertiary,
                thickness: 16
            )
            .frame(width: 120, height: 120)
            
            // Protein ring (middle)
            ProgressRing(
                progress: validateProgress(proteinProgress),
                color: AppTheme.ringColors.secondary,
                thickness: 16
            )
            .frame(width: 90, height: 90)
            
            // Calorie ring (inner)
            ProgressRing(
                progress: validateProgress(calorieProgress),
                color: AppTheme.ringColors.primary,
                thickness: 16
            )
            .frame(width: 60, height: 60)
        }
        .frame(width: 120, height: 120) // Constrain overall size
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressRings(
            calorieProgress: 0.7,
            proteinProgress: 0.5,
            exerciseProgress: 0.3
        )
        
        ProgressRing(progress: 0.75)
            .frame(width: 100, height: 100)
    }
    .padding()
    .background(Color.black)
} 