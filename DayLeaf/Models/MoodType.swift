//
//  MoodType.swift
//  DayLeaf
//

import Foundation

enum MoodType: String, Codable, CaseIterable, Identifiable {
    case verySad = "verySad"
    case sad = "sad"
    case neutral = "neutral"
    case happy = "happy"
    case veryHappy = "veryHappy"
    case excited = "excited"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .verySad: return "😭"
        case .sad:     return "😞"
        case .neutral: return "😐"
        case .happy:   return "🙂"
        case .veryHappy: return "😄"
        case .excited: return "🤩"
        }
    }

    var label: String {
        switch self {
        case .verySad:   return "Very Sad"
        case .sad:       return "Sad"
        case .neutral:   return "Neutral"
        case .happy:     return "Happy"
        case .veryHappy: return "Very Happy"
        case .excited:   return "Excited"
        }
    }

    var color: String {
        switch self {
        case .verySad:   return "MoodVerySad"
        case .sad:       return "MoodSad"
        case .neutral:   return "MoodNeutral"
        case .happy:     return "MoodHappy"
        case .veryHappy: return "MoodVeryHappy"
        case .excited:   return "MoodExcited"
        }
    }
}
