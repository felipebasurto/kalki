# Kalki

Kalki is a feature-rich iOS application built with SwiftUI and Core Data that helps users track their nutrition, exercise, and overall health. The app provides detailed food logging, weight tracking, personalized goals, and an achievements system—all wrapped in a polished, responsive interface.

> **Project Status:** *Halfway done.*  
> I never got the chance to add the planned AI nutritional analysis capabilities before putting the project on hold.

## Overview

Kalki is designed to empower users with a comprehensive set of tools to monitor and improve their daily habits. Key highlights include:

- **Food Logging & Planned AI Analysis:**  
  Log meals with an intended feature for AI-powered nutritional analysis. (Note: AI capabilities were planned but remain unimplemented.)

- **Weight & Progress Tracking:**  
  Log, view, and manage your weight entries with real-time graph updates and calendar-based progress tracking.

- **Personalized Health Calculators:**  
  Calculate Basal Metabolic Rate (BMR) and Total Daily Energy Expenditure (TDEE) using industry-standard formulas.

- **Achievements & Rewards:**  
  Unlock achievements (e.g., “Perfect Week”, “Marathoner”) as you consistently meet your nutrition and exercise goals.

- **Dynamic UI:**  
  Enjoy engaging animations, responsive progress indicators, and adaptive themes for both light and dark modes.

## Features

- **Food Logging:**  
  Quickly log meals and receive a basic nutritional breakdown, with plans for advanced AI analysis in the future.

- **Weight Tracking:**  
  Monitor weight evolution over time with interactive charts and calendar views.

- **Personalized Health Calculators:**  
  Determine daily calorie needs and protein targets using the Mifflin-St Jeor Equation and other calculations.

- **Achievements & Progress:**  
  Earn badges and track your progress as you hit your daily health goals.

- **Adaptive User Interface:**  
  Sleek, animated UI components and customizable themes.

## Installation

### Prerequisites

- **Xcode 14+** with Swift 5.0 or later
- macOS with iOS development tools installed

### Steps

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/felipebasurto-kalki.git
   cd felipebasurto-kalki
   ```

2. **Open the Project in Xcode:**

   Open the `kalki.xcodeproj` file in Xcode.

3. **Configure Your Environment:**

   - (Optional) Run the icon resizing script to generate proper app icons:

     ```bash
     chmod +x resize_icons.sh
     ./resize_icons.sh
     ```
   - If you plan to explore AI nutrition analysis in the future, set your OpenAI API key in the Settings or directly in `kalki/Config/AppConfig.swift`. (Note: This functionality is not active in the current version.)

4. **Build and Run:**

   Build the project and run it on a simulator or real device.

## Directory Structure

```plaintext
felipebasurto-kalki/
├── Info.plist                # App configuration file
├── resize_icons.sh           # Shell script to resize app icons
├── .cursorrules              # Development guidelines and best practices
├── kalki/                   # Main source code and asset folder
│   ├── Assets.xcassets/      # App icons, color sets, and images
│   ├── Config/              # App configuration files
│   ├── Extensions/          # Swift extensions used throughout the app
│   ├── Models/              # Data models and Core Data schema
│   ├── Preview Content/     # Assets for SwiftUI previews
│   ├── Resources/           # Fonts and other resources
│   ├── Services/            # Networking, Core Data management, and planned AI services
│   ├── Theme/               # Custom themes and theme management
│   ├── Utilities/           # Utility classes (e.g., Logger)
│   ├── ViewModels/          # MVVM view models supporting the UI
│   └── Views/               # All SwiftUI views and related UI components
└── Tests/                   # Unit tests and UI tests
```

## Configuration

- **API Key:**  
  For accurate food analysis in future versions, update your OpenAI API key in Settings or in `kalki/Config/AppConfig.swift`. (Currently, AI features are not implemented.)

- **Theme Preferences:**  
  The app uses `ThemeManager` to manage the user’s theme preference (light, dark, or system).

## Usage

- **Food Logging:**  
  Add food entries via the “Add Food” interface. Although the app was designed to support AI analysis of food descriptions, the AI functionality remains unimplemented.

- **Weight Tracking:**  
  Log your weight entries to view progress via interactive graphs and calendar views.

- **Calculate Health Goals:**  
  Use the built-in calculator to determine your BMR, TDEE, and recommended protein intake based on your profile.

- **Achievements & Progress:**  
  Monitor your streaks and unlock achievements as you consistently meet your health goals.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a feature branch (e.g., `feature/your-feature-name`).
3. Commit your changes with clear and concise commit messages.
4. Open a pull request outlining your changes.

## Contact

For questions or issues, please contact me!
```
