//
//  DeviceListView.swift
//  OneStepGPS
//
//  Created by Charles Prutting on 4/22/25.
//

import SwiftUI

struct DeviceListView: View {
    @EnvironmentObject var viewModel: FleetViewModel
    @State private var searchText = ""
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.devices.isEmpty && viewModel.error == nil {
                    ContentUnavailableView("No Devices Found", systemImage: "car")
                } else if let error = viewModel.error {
                    ContentUnavailableView {
                        Label("Error Loading Devices", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error.localizedDescription)
                    } actions: {
                        Button("Retry") {
                            Task {
                                await fetchDevicesWithErrorHandling()
                            }
                        }
                    }
                } else {
                    List(filteredDevices) { device in
                        NavigationLink {
                            DeviceDetailView(device: device)
                        } label: {
                            DeviceRowView(device: device)
                        }
                        .swipeActions {
                            Button {
                                viewModel.userPreferences.hiddenDeviceIDs.insert(device.id)
                                viewModel.savePreferences()
                            } label: {
                                Label("Hide", systemImage: "eye.slash")
                            }
                            .tint(.indigo)
                        }
                    }
                    .searchable(text: $searchText)
                }
            }
            .navigationTitle("Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        sortMenu
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        PreferencesView()
                    } label: {
                        Label("Preferences", systemImage: "gearshape")
                    }
                }
            }
            .refreshable {
                Task {
                    await fetchDevicesWithErrorHandling()
                }
            }
            .alert("Error Loading Devices",
                   isPresented: $showErrorAlert,
                   presenting: viewModel.error) { error in
                Button("OK", role: .cancel) { }
                Button("Retry") {
                    Task {
                        await fetchDevicesWithErrorHandling()
                    }
                }
            } message: { error in
                Text(error.localizedDescription)
            }
        }
        .task {
            await fetchDevicesWithErrorHandling()
        }
    }
    
    private var filteredDevices: [Device] {
        if searchText.isEmpty {
            return viewModel.displayedDevices
        } else {
            return viewModel.displayedDevices.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.id.localizedCaseInsensitiveContains(searchText) ||
                $0.driveStatus.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var sortMenu: some View {
        Picker("Sort By", selection: $viewModel.userPreferences.sortOrder) {
            Label("Name", systemImage: "textformat").tag(UserPreferences.SortOrder.byName)
            Label("Status", systemImage: "checkmark.circle").tag(UserPreferences.SortOrder.byStatus)
            Label("Recent", systemImage: "clock").tag(UserPreferences.SortOrder.byRecentUpdate)
        }
        .onChange(of: viewModel.userPreferences.sortOrder) { _, _ in
            viewModel.savePreferences()
        }
    }
    
    private func fetchDevicesWithErrorHandling() async {
        do {
            try await viewModel.fetchDevices()
        } catch {
            showErrorAlert = true
        }
    }
}

// MARK: - Subviews

struct DeviceRowView: View {
    let device: Device
    
    var body: some View {
        HStack(spacing: 12) {
            statusIndicator
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.headline)
                
                HStack(spacing: 16) {
                    // Speed display
                    if let speed = device.currentSpeed {
                        Label(speed.display, systemImage: "speedometer")
                    } else {
                        Label("--", systemImage: "questionmark")
                            .foregroundColor(.secondary)
                    }
                    
                    // Drive status
                    Text(driveStatusDescription(device.driveStatus.rawValue))
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Battery voltage display
            if let voltage = device.batteryVoltage {
                HStack(spacing: 4) {
                    Image(systemName: batteryIcon(for: voltage))
                    Text("\(String(format: "%.1f", voltage))V")
                        .font(.caption)
                }
                .foregroundColor(batteryColor(for: voltage))
            } else {
                Image(systemName: "battery.slash")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Status Indicator
    private var statusIndicator: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 12, height: 12)
    }
    
    private var statusColor: Color {
        switch device.driveStatus.rawValue.lowercased() {
        case "off": return .gray
        case "idle": return .yellow
        case "moving": return .green
        default: return .blue
        }
    }
    
    // MARK: - Helper Methods
    private func driveStatusDescription(_ status: String) -> String {
        switch status.lowercased() {
        case "off": return "Parked"
        case "idle": return "Idling"
        case "moving": return "In Motion"
        default: return status.capitalized
        }
    }
    
    private func batteryIcon(for voltage: Double) -> String {
        switch voltage {
        case ..<11.5: return "battery.0"
        case 11.5..<12.0: return "battery.25"
        case 12.0..<12.5: return "battery.50"
        case 12.5..<13.0: return "battery.75"
        default: return "battery.100"
        }
    }
    
    private func batteryColor(for voltage: Double) -> Color {
        switch voltage {
        case ..<11.5: return .red
        case 11.5..<12.5: return .yellow
        default: return .green
        }
    }
}
