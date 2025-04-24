//
//  ErrorView.swift
//  OneStepGPS
//
//  Created by Charles Prutting on 4/22/25.
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Error loading devices")
                .font(.title2)
            Text(error.localizedDescription)
                .foregroundColor(.secondary)
                .padding()
        }
    }
}
