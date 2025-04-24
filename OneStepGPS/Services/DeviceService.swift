//
//  DeviceService.swift
//  OneStepGPS
//
//  Created by Charles Prutting on 4/20/25.
//

import Foundation

class DeviceService {
    private let apiKey = "Xl-8_ceibpMHqr4YZ72uFy5xQfjbOPXstocE8b_Zkmw"
    private let session = URLSession.shared
    
    func fetchDevices() async throws -> [Device] {
        guard let url = URL(string: "https://track.onestepgps.com/v3/api/public/device?latest_point=true&api-key=\(apiKey)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        let decoder = JSONDecoder.fleetDecoder
        return try decoder.decode(FleetResponse.self, from: data).resultList
    }
    
    func fetchDevicesRawData() async throws -> Data {
        guard let url = URL(string: "https://track.onestepgps.com/v3/api/public/device?latest_point=true&api-key=\(apiKey)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await session.data(from: url)
        return data
    }
    
    enum APIError: Error {
        case invalidURL, invalidResponse
    }
}

