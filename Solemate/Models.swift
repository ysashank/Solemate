//
//  Models.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 31.08.25.
//

import Foundation

struct Exercise: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let sets: Int
    let reps: Int?
    let holdSeconds: Int
    let perSide: Bool
    let steps: [String]
}

enum PhaseKind { case prep, work, restSet, done }

struct Phase: Identifiable {
    let id = UUID()
    let kind: PhaseKind
    let exercise: Exercise
    let set: Int
    let rep: Int?
    let side: String?
    let seconds: Int
    let nextTitle: String?
}
