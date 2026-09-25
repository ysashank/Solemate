import SwiftUI

struct HomeView: View {
    private let total = DurationCalculator.calculateTotalDuration(for: Ritual.exercises)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Daily ritual to heal your Plantar Fasciitis")
                    .foregroundStyle(Color.foregroundSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 20)

                List(Ritual.exercises) { ex in
                    NavigationLink(value: ex) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ex.title)
                                .font(.headline)
                                .foregroundStyle(Color.foregroundPrimary)
                            Text(ex.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(Color.foregroundSecondary)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Solemate")
                .navigationDestination(for: Exercise.self) { ex in
                    ExerciseDetail(ex: ex)
                }

                Text(DurationCalculator.formatDuration(total))
                    .font(.caption)
                    .foregroundStyle(Color.foregroundSecondary)
                    .padding()
                    .accessibilityLabel("Total ritual duration \(DurationCalculator.formatDuration(total))")

                NavigationLink(destination: PlayerView()) {
                    Text("Start")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.foregroundPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 26)
                        .background(Color.buttonSurface, in: Capsule())
                }
                .accessibilityLabel("Start ritual")
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            .background(Color.backgroundGrouped)
        }
    }
}

#Preview {
    HomeView()
}
