import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    Text("Daily ritual to heal your Plantar Fasciitis")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 20)

                    List(Ritual.exercises) { ex in
                        NavigationLink(value: ex) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ex.title).font(.headline)
                                Text(ex.subtitle).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Solemate")
                    .navigationDestination(for: Exercise.self) { ex in
                        ExerciseDetail(ex: ex)
                    }

                    Text(DurationCalculator.formatDuration(
                                            DurationCalculator.calculateTotalDuration(for: Ritual.exercises)
                                            ))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()

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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }
}

#Preview {
    HomeView()
}
