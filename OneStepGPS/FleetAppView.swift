//
//  FleetAppView.swift
//  OneStepGPS
//
//  Created by Charles Prutting on 4/20/25.
//

import SwiftUI

struct FleetAppView: View {
    @StateObject private var viewModel = FleetViewModel()
    
    var body: some View {
        TabView {
            NavigationStack {
                DeviceListView()
            }
            .tabItem {
                Label("Devices", systemImage: "list.bullet")
            }
            
            NavigationStack {
                FleetMapView()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
        }
        .environmentObject(viewModel)
    }
}
