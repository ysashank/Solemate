import SwiftUI

struct ExerciseDetail: View {
    let ex: Exercise

    var body: some View {
        List {
            Section {
                ForEach(Array(ex.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.body.monospacedDigit())
                            .foregroundStyle(Color.foregroundSecondary)
                            .frame(width: 28, alignment: .trailing)
                            .accessibilityHidden(true)

                        Text(step)
                            .font(.body)
                            .foregroundStyle(Color.foregroundPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ex.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.foregroundSecondary)
                }
                .textCase(nil)
                .padding(.top, 4)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(ex.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetail(ex: Ritual.exercises.first!)
    }
}
