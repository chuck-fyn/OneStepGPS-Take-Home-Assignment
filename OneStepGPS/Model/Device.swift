//
//  Device.swift
//  OneStepGPS
//
//  Created by Charles Prutting on 4/20/25.
//

import Foundation
import CoreLocation

// MARK: - Main Response Structure
struct FleetResponse: Codable {
    let resultList: [Device]
    
    enum CodingKeys: String, CodingKey {
        case resultList = "result_list"
    }
}

// MARK: - Device Model
struct Device: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let make: String
    let model: String
    let location: CLLocationCoordinate2D?
    let lastUpdated: Date
    let batteryVoltage: Double?
    let currentSpeed: SpeedInfo?
    let driveStatus: DriveStatus
    let isOnline: Bool
    let factoryID: String
    let activatedAt: Date?
    
    var coordinate: CLLocationCoordinate2D? { location }
    
    // Custom Equatable implementation with floating-point precision handling
    static func == (lhs: Device, rhs: Device) -> Bool {
        // Compare coordinates with floating-point precision tolerance
        let coordinateEqual: Bool
        if let lhsCoord = lhs.location, let rhsCoord = rhs.location {
            coordinateEqual = abs(lhsCoord.latitude - rhsCoord.latitude) < 0.000001 &&
                             abs(lhsCoord.longitude - rhsCoord.longitude) < 0.000001
        } else {
            coordinateEqual = lhs.location == nil && rhs.location == nil
        }
        
        // Compare dates with direct equality (Date is Equatable)
        let datesEqual = lhs.lastUpdated == rhs.lastUpdated
        
        // Compare optional activatedAt dates
        let activatedAtEqual: Bool
        if let lhsDate = lhs.activatedAt, let rhsDate = rhs.activatedAt {
            activatedAtEqual = lhsDate == rhsDate
        } else {
            activatedAtEqual = lhs.activatedAt == nil && rhs.activatedAt == nil
        }
        
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.make == rhs.make &&
               lhs.model == rhs.model &&
               coordinateEqual &&
               datesEqual &&
               lhs.batteryVoltage == rhs.batteryVoltage &&
               lhs.currentSpeed == rhs.currentSpeed &&
               lhs.driveStatus == rhs.driveStatus &&
               lhs.isOnline == rhs.isOnline &&
               lhs.factoryID == rhs.factoryID &&
               activatedAtEqual
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "device_id"
        case name = "display_name"
        case make
        case model
        case lastUpdated = "updated_at"
        case latestDevicePoint = "latest_accurate_device_point"
        case online
        case factoryID = "factory_id"
        case activatedAt = "activated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Direct properties
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        make = try container.decode(String.self, forKey: .make)
        model = try container.decode(String.self, forKey: .model)
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
        isOnline = try container.decode(Bool.self, forKey: .online)
        factoryID = try container.decode(String.self, forKey: .factoryID)
        activatedAt = try? container.decode(Date.self, forKey: .activatedAt)
        
        // Nested device point data
        let pointContainer = try container.nestedContainer(
            keyedBy: DevicePointCodingKeys.self,
            forKey: .latestDevicePoint
        )
        
        // Location from top-level lat/lng
        let lat = try pointContainer.decode(Double.self, forKey: .latitude)
        let lng = try pointContainer.decode(Double.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        // Device point details
        let detailContainer = try pointContainer.nestedContainer(
            keyedBy: DeviceDetailCodingKeys.self,
            forKey: .details
        )
        
        batteryVoltage = try? detailContainer.decode(Double.self, forKey: .externalVoltage)
        currentSpeed = try? detailContainer.decode(SpeedInfo.self, forKey: .speed)
        
        // Device state
        let stateContainer = try pointContainer.nestedContainer(
            keyedBy: DeviceStateCodingKeys.self,
            forKey: .state
        )
        
        driveStatus = try stateContainer.decode(DriveStatus.self, forKey: .status)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(make, forKey: .make)
        try container.encode(model, forKey: .model)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encode(isOnline, forKey: .online)
        try container.encode(factoryID, forKey: .factoryID)
        try container.encodeIfPresent(activatedAt, forKey: .activatedAt)
        
        var pointContainer = container.nestedContainer(
            keyedBy: DevicePointCodingKeys.self,
            forKey: .latestDevicePoint
        )
        
        try pointContainer.encode(location?.latitude, forKey: .latitude)
        try pointContainer.encode(location?.longitude, forKey: .longitude)
        
        var detailContainer = pointContainer.nestedContainer(
            keyedBy: DeviceDetailCodingKeys.self,
            forKey: .details
        )
        
        try detailContainer.encodeIfPresent(batteryVoltage, forKey: .externalVoltage)
        try detailContainer.encodeIfPresent(currentSpeed, forKey: .speed)
        
        var stateContainer = pointContainer.nestedContainer(
            keyedBy: DeviceStateCodingKeys.self,
            forKey: .state
        )
        
        try stateContainer.encode(driveStatus, forKey: .status)
    }
    
    // Nested Coding Keys
    private enum DevicePointCodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
        case details = "device_point_detail"
        case state = "device_state"
    }
    
    private enum DeviceDetailCodingKeys: String, CodingKey {
        case externalVoltage = "external_volt"
        case speed
    }
    
    private enum DeviceStateCodingKeys: String, CodingKey {
        case status = "drive_status"
    }
}

// MARK: - Supporting Types

enum DriveStatus: String, Codable {
    case parked = "parked"
    case off = "off"
    case idle = "idle"
    case driving = "driving"
    case unknown
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = DriveStatus(rawValue: rawValue) ?? .unknown
    }
}

struct SpeedInfo: Codable, Equatable {
    let value: Double
    let unit: String
    let display: String
    
    var speedInMPH: Double {
        unit.lowercased() == "km/h" ? value * 0.621371 : value
    }
    
    var localizedDescription: String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        
        if unit == "km/h" {
            let measurement = Measurement(value: value, unit: UnitSpeed.kilometersPerHour)
            return formatter.string(from: measurement)
        } else if unit == "mph" {
            let measurement = Measurement(value: value, unit: UnitSpeed.milesPerHour)
            return formatter.string(from: measurement)
        }
        
        return display
    }
}

// MARK: - Date Decoding Strategy

extension JSONDecoder {
    static var fleetDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        return decoder
    }
}

// MARK: - Convenience Extensions

extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let latitude = try container.decode(Double.self)
        let longitude = try container.decode(Double.self)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(latitude)
        try container.encode(longitude)
    }
}
