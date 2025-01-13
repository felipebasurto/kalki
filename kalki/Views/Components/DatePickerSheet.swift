import SwiftUI

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    let minimumDate: Date
    let maximumDate: Date
    
    @State private var tempDate: Date
    
    init(selectedDate: Binding<Date>, minimumDate: Date, maximumDate: Date) {
        self._selectedDate = selectedDate
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $tempDate,
                    in: minimumDate...maximumDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
            }
            .navigationTitle("Choose Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedDate = Calendar.current.startOfDay(for: tempDate)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    DatePickerSheet(
        selectedDate: .constant(Date()),
        minimumDate: Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!,
        maximumDate: Date()
    )
} 