//
//  FleetViewModel.swift
//  OneStepGPS
//
//  Created by Charles Prutting on 4/20/25.
//

import SwiftUI
import MapKit

class FleetViewModel: ObservableObject {
    @Published var devices: [Device] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var userPreferences = UserPreferences()
    
    private let deviceService = DeviceService()
    private let preferencesStore = PreferencesStore()
    private var refreshTimer: Timer?
    
    init() {
        loadPreferences()
        startAutoRefresh()
    }
    
    deinit {
        stopAutoRefresh()
    }
    
    func loadPreferences() {
        userPreferences = preferencesStore.preferences
    }
    
    func savePreferences() {
        preferencesStore.save()
        startAutoRefresh() // Restart timer with new interval
    }
    
    @MainActor
    func fetchDevices() async throws {
        isLoading = true
        error = nil
        
        do {
            //for debugging JSON decoding
            let data = try await deviceService.fetchDevicesRawData() // Add this method
            print(String(data: data, encoding: .utf8) ?? "Couldn't print JSON")
            
            devices = try await deviceService.fetchDevices()
            
            for device in devices {
                print("This is the speed:", device.currentSpeed)
            }
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
        
        isLoading = false
    }
    
    func startAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: userPreferences.mapRefreshInterval,
            repeats: true
        ) { [weak self] _ in
            Task { [weak self] in
                try? await self?.fetchDevices()
            }
        }
    }
    
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    var displayedDevices: [Device] {
        var result = devices
        
        if !userPreferences.hiddenDeviceIDs.isEmpty {
            result = result.filter { !userPreferences.hiddenDeviceIDs.contains($0.id) }
        }
        
        switch userPreferences.sortOrder {
        case .byName: return result.sorted { $0.name < $1.name }
        case .byStatus: return result.sorted { $0.driveStatus.rawValue < $1.driveStatus.rawValue }
        case .byRecentUpdate: return result.sorted { $0.lastUpdated > $1.lastUpdated }
        }
    }
}
