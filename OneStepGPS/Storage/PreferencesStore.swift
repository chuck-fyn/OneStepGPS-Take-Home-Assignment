//
//  UserDefaultsManager.swift
//  OneStepGPS
//
//  Created by Charles Prutting on 4/21/25.
//

import Foundation

class PreferencesStore: ObservableObject {
    @Published var preferences: UserPreferences
    private let defaults = UserDefaults.standard
    private let key = "userPreferences"
    
    init() {
        if let data = defaults.data(forKey: key),
           let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            preferences = prefs
        } else {
            preferences = UserPreferences()
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(preferences) {
            defaults.set(data, forKey: key)
        }
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    var hiddenDeviceIDs: Set<String> = []
    var sortOrder: SortOrder = .byName
    var mapRefreshInterval: TimeInterval = 30
    var customDeviceIcons: [String: String] = [:] // deviceID: iconName
    
    enum SortOrder: String, Codable {
        case byName, byStatus, byRecentUpdate
    }
}
