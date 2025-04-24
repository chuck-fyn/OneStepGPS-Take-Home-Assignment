//
//  DeviceDetailView.swift
//  OneStepGPS
//
//  Created by Charles Prutting on 4/21/25.
//

import SwiftUI
import MapKit

struct DeviceDetailView: View {
    let device: Device
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                
                Divider()
                
                // Status and Speed Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader("CURRENT STATUS")
                    
                    HStack(spacing: 10) {
                        statusIndicator
                        Text(driveStatusDescription(device.driveStatus.rawValue))
                            .font(.headline)
                    }
                    
                    if let speed = device.currentSpeed {
                        DetailRow(
                            icon: "speedometer",
                            title: "Current Speed",
                            value: speed.display,
                            valueColor: .primary
                        )
                    }
                    
                    DetailRow(
                        icon: "clock",
                        title: "Last Updated",
                        value: device.lastUpdated.formatted(date: .abbreviated, time: .shortened),
                        valueColor: .secondary
                    )
                }
                
                // Battery Section
                if let voltage = device.batteryVoltage {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("BATTERY STATUS")
                        
                        HStack(spacing: 16) {
                            Image(systemName: batteryIcon(for: voltage))
                                .font(.title)
                                .foregroundColor(batteryColor(for: voltage))
                            
                            VStack(alignment: .leading) {
                                Text("\(String(format: "%.1f", voltage))V")
                                    .font(.title2)
                                
                                Text(batteryStatusDescription(for: voltage))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Location Section
                if let location = device.location {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("LOCATION")
                        
                        DetailRow(
                            icon: "mappin.and.ellipse",
                            title: "Coordinates",
                            value: "\(location.latitude.formatted()), \(location.longitude.formatted())",
                            valueColor: .secondary
                        )
                        
                        Button {
                            openInMaps()
                        } label: {
                            Label("Open in Maps", systemImage: "map")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(device.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Subviews
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(device.make + " " + device.model)
                    .font(.title2)
                
                Text("ID: \(device.id)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            OnlineIndicator(isOnline: device.isOnline)
        }
    }
    
    private var statusIndicator: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 14, height: 14)
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
    private func openInMaps() {
        guard let location = device.coordinate else { return }
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location))
        mapItem.name = device.name
        mapItem.openInMaps()
    }
    
    private func driveStatusDescription(_ status: String) -> String {
        switch status.lowercased() {
        case "off": return "Parked"
        case "idle": return "Engine Idling"
        case "moving": return "Currently Moving"
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
    
    private func batteryStatusDescription(for voltage: Double) -> String {
        switch voltage {
        case ..<11.5: return "Critical (Needs Charge)"
        case 11.5..<12.0: return "Low"
        case 12.0..<12.5: return "Medium"
        case 12.5..<13.0: return "Good"
        default: return "Excellent"
        }
    }
}

// MARK: - Reusable Components

struct SectionHeader: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
            .textCase(.uppercase)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let valueColor: Color
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
                .foregroundColor(valueColor)
        }
    }
}

struct OnlineIndicator: View {
    let isOnline: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isOnline ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            
            Text(isOnline ? "Online" : "Offline")
                .font(.caption)
        }
        .padding(6)
        .background(.thinMaterial)
        .clipShape(Capsule())
    }
}
