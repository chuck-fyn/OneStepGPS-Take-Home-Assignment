//
//  PreferencesView.swift
//  OneStepGPS
//
//  Created by Charles Prutting on 4/21/25.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var viewModel: FleetViewModel
    
    var body: some View {
        Form {
            Section("Display Options") {
                Picker("Sort Order", selection: $viewModel.userPreferences.sortOrder) {
                    Text("By Name").tag(UserPreferences.SortOrder.byName)
                    Text("By Status").tag(UserPreferences.SortOrder.byStatus)
                    Text("By Recent").tag(UserPreferences.SortOrder.byRecentUpdate)
                }
                
                Stepper(
                    "Refresh every \(Int(viewModel.userPreferences.mapRefreshInterval)) seconds",
                    value: $viewModel.userPreferences.mapRefreshInterval,
                    in: 10...300,
                    step: 10
                )
            }
            
            Section("Hidden Devices") {
                if viewModel.userPreferences.hiddenDeviceIDs.isEmpty {
                    Text("No hidden devices")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.devices.filter { viewModel.userPreferences.hiddenDeviceIDs.contains($0.id) }) { device in
                        HStack {
                            Text(device.name)
                            Spacer()
                            Button {
                                viewModel.userPreferences.hiddenDeviceIDs.remove(device.id)
                            } label: {
                                Image(systemName: "eye")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Preferences")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.savePreferences()
        }
    }
}
