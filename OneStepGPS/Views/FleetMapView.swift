//
//  FleetMapView.swift
//  OneStepGPS
//
//  Created by Charles Prutting on 4/21/25.
//

import SwiftUI
import MapKit

struct FleetMapView: View {
    @EnvironmentObject var viewModel: FleetViewModel
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedDeviceID: String?
    @State private var showDetail = false
    @State private var showErrorAlert = false
    
    private var selectedDevice: Device? {
        viewModel.devices.first { $0.id == selectedDeviceID }
    }
    
    var body: some View {
        Map(position: $cameraPosition, selection: $selectedDeviceID) {
            ForEach(viewModel.displayedDevices) { device in
                if let coordinate = device.coordinate {
                    Annotation(
                        device.name,
                        coordinate: coordinate,
                        anchor: .bottom
                    ) {
                        MapDeviceMarker(device: device)
                            .onTapGesture {
                                selectedDeviceID = device.id
                                showDetail = true
                            }
                    }
                    .tag(device.id)
                }
            }
        }
        .mapControls {
//            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .sheet(isPresented: $showDetail) {
            if let device = selectedDevice {
                DeviceDetailView(device: device)
                    .presentationDetents([.medium, .large])
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
        .task {
            await fetchDevicesWithErrorHandling()
        }
        .onChange(of: viewModel.devices) { _, _ in
//            if let firstLocation = viewModel.displayedDevices.compactMap({ $0.coordinate }).first {
//                cameraPosition = .region(MKCoordinateRegion(
//                    center: firstLocation,
//                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//                )
//            )}
        }
        .overlay(alignment: .topLeading) {
            HStack(spacing: 16) {
                Button {
                    Task {
                        await fetchDevicesWithErrorHandling()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .padding(10)
                        .background(Material.thickMaterial)
                        .clipShape(Circle())
                }
            }
            .padding()
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

struct MapDeviceMarker: View {
    let device: Device
    
    var body: some View {
        VStack(spacing: 0) {
            // Status-colored vehicle icon
            Image(systemName: "car.fill")
                .font(.title)
                .foregroundColor(statusColor)
                .background(
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 30, height: 30)
                )
            
            // Speed display if available
            if let speed = device.currentSpeed {
                Text("\(Int(speed.speedInMPH))")
                    .font(.system(size: 10, weight: .bold))
                    .padding(4)
                    .background(statusColor.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .offset(y: -6)
            }
            
            // Battery indicator for map view
            if let voltage = device.batteryVoltage {
                Text("\(String(format: "%.1f", voltage))V")
                    .font(.system(size: 8, weight: .bold))
                    .padding(2)
                    .background(batteryColor(for: voltage).opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .offset(y: -4)
            }
        }
    }
    
    private var statusColor: Color {
        switch device.driveStatus.rawValue.lowercased() {
        case "off": return .gray
        case "idle": return .yellow
        case "moving": return .green
        default: return .blue
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
