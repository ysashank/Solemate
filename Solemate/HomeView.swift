//
//  HomeView.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 31.08.25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    Text("Daily ritual to heal your Plantar Fasciitis")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                        .padding(.horizontal ,18)
                    
                    List(Ritual.exercises) { ex in
                        NavigationLink(value: ex) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ex.title).font(.headline)
                                Text(ex.subtitle).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                    }
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
                        Image(systemName: "play.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color.primary)
                            .frame(width: 100, height: 100)
                            .overlay(Circle()
                                .stroke(Color.secondary, lineWidth: 1)
                            )
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
