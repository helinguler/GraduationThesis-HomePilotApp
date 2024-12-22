//
//  device.swift
//  HomePilotApp
//
//  Created by Helin Güler on 21.12.2024.
//

import Foundation

// Protocol: Every device implements this protocol
protocol DeviceProtocol {
    var name: String { get }
    var metrics: [DeviceMetric] { get }
    func calculateUsage(inputs: [String: String]) -> DeviceUsageResult
}

// Metric Structure: To define the user inputs required by the devices
struct DeviceMetric {
    let name: String
    let placeholder: String
}

// Calculation Results: Standard result structure that all devices will return
struct DeviceUsageResult {
    let usage: Double
    let cost: Double
    let waterUsage: Double?  // Electricity usage (for washing machine and dishwasher )
    let waterCost: Double?   // Electricity cost (for washing machine and dishwasher )
}

// Helper Class: Common calculation and validation operations
struct CalculationHelper {
    static func calculateCost(usage: Double, rate: Double) -> Double {
        return usage * rate
    }
    
    static func convertMinutesToHours(minutes: Int) -> Double {
        return Double(minutes) / 60.0
    }
    
    static func validateInputs(_ inputs: [String: String], keys: [String]) -> [String: Double]? {
        var validated: [String: Double] = [:]
        for key in keys {
            guard let value = inputs[key], let doubleValue = Double(value) else {
                print("Invalid input for key: \(key)")
                return nil
            }
            validated[key] = doubleValue
        }
        return validated
    }
}

class AC: DeviceProtocol {
    var name: String = "AC"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Usage Time", placeholder: "Input minutes"),
        DeviceMetric(name: "Mode Type", placeholder: "Summer/Winter mode"),
        DeviceMetric(name: "Adjusted Temperature", placeholder: "Input an integer value")
    ]
    
    func calculateUsage(inputs: [String: String]) -> DeviceUsageResult {
        guard let validatedInputs = CalculationHelper.validateInputs(inputs, keys: ["Usage Time", "Adjusted Temperature"]) else {
            return DeviceUsageResult(usage: 0.0, cost: 0.0, waterUsage: nil, waterCost: nil)
        }
        
        let usageTime = validatedInputs["Usage Time"] ?? 0.0
        let adjustedTemperature = validatedInputs["Adjusted Temperature"] ?? 0.0
        let modeType = inputs["Mode Type"]?.lowercased() ?? "summer"
        let usageHours = CalculationHelper.convertMinutesToHours(minutes: Int(usageTime))
        let costPerKWh = 0.20
        
        var usage: Double = 0.0
        if modeType == "summer" {
            usage = adjustedTemperature < 24 ? 2.0 * usageHours : 1.2 * usageHours
        } else if modeType == "winter" {
            usage = adjustedTemperature > 22 ? 2.5 * usageHours : 1.5 * usageHours
        }
        
        let cost = CalculationHelper.calculateCost(usage: usage, rate: costPerKWh)
        
        return DeviceUsageResult(
            usage: usage,
            cost: cost,
            waterUsage: nil,
            waterCost: nil
        )
    }
}

class WashingMachine: DeviceProtocol {
    var name: String = "Washer"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Usage Time", placeholder: "Input minutes"),
        DeviceMetric(name: "Program Type", placeholder: "Eco/Normal"),
        DeviceMetric(name: "Extra Water", placeholder: "Yes/No")
    ]
    
    func calculateUsage(inputs: [String: String]) -> DeviceUsageResult {
        guard let validatedInputs = CalculationHelper.validateInputs(inputs, keys: ["Usage Time"]) else {
            return DeviceUsageResult(usage: 0.0, cost: 0.0, waterUsage: nil, waterCost: nil)
        }
        
        let usageTime = validatedInputs["Usage Time"] ?? 0.0
        let programType = inputs["Program Type"]?.lowercased() ?? "normal"
        let extraWater = inputs["Extra Water"]?.lowercased() == "yes"
        let usageHours = CalculationHelper.convertMinutesToHours(minutes: Int(usageTime))
        let costPerLiterWater = 0.005
        let costPerKWh = 0.20  // Assuming a cost per kWh for electricity

        var waterUsage: Double = programType == "eco" ? 30.0 * usageHours : 50.0 * usageHours
        if extraWater {
            waterUsage += 10.0 * usageHours  // Additional water usage
        }
        
        var electricityUsage: Double = 0.1 * usageHours  // Base electricity usage per hour
        if programType == "eco" {
            electricityUsage *= 0.85  // Reduced electricity usage in eco mode
        }
        
        let waterCost = CalculationHelper.calculateCost(usage: waterUsage, rate: costPerLiterWater)
        let electricityCost = CalculationHelper.calculateCost(usage: electricityUsage, rate: costPerKWh)
        
        return DeviceUsageResult(
            usage: electricityUsage,  // Total water usage
            cost: electricityCost,  // Total cost for water
            waterUsage: waterUsage,  // Electricity usage
            waterCost: waterCost  // Cost for electricity used
        )
    }
}


class Combi: DeviceProtocol {
    var name: String = "Combi"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Usage Time", placeholder: "Input hours"),
        DeviceMetric(name: "Adjusted Temperature", placeholder: "Input an integer value"),
        DeviceMetric(name: "Number of Radiators", placeholder: "Input an integer value")
    ]
    
    func calculateUsage(inputs: [String: String]) -> DeviceUsageResult {
        guard let usageTime = Double(inputs["Usage Time"] ?? "0"),
              let adjustedTemperature = Int(inputs["Adjusted Temperature"] ?? "0"),
              let numberOfRadiators = Int(inputs["Number of Radiators"] ?? "0") else {
            return DeviceUsageResult(usage: 0.0, cost: 0.0, waterUsage: nil, waterCost: nil)
        }

        let costPerKWh = 0.15
        var kWhPerHour = 1.5
        
        if adjustedTemperature > 30 {
            kWhPerHour += Double(adjustedTemperature - 30) * 0.2
        }
        kWhPerHour += Double(numberOfRadiators) * 0.1

        let usage = kWhPerHour * usageTime
        let cost = CalculationHelper.calculateCost(usage: usage, rate: costPerKWh)
        
        return DeviceUsageResult(
            usage: usage,
            cost: cost,
            waterUsage: nil,
            waterCost: nil
        )
    }
}

class AirHumidifier: DeviceProtocol {
    var name: String = "Air Humidifier"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Usage Time", placeholder: "Input minutes"),
        DeviceMetric(name: "Fan Speed", placeholder: "Low/Medium/High"),
        DeviceMetric(name: "Pollen Filter Cleaning", placeholder: "Yes/No")
    ]
    
    func calculateUsage(inputs: [String: String]) -> DeviceUsageResult {
        guard let usageTime = Int(inputs["Usage Time"] ?? "0") else {
            return DeviceUsageResult(usage: 0.0, cost: 0.0, waterUsage: nil, waterCost: nil)
        }

        let fanSpeed = inputs["Fan Speed"]?.lowercased() ?? "low"
        let pollenFilterCleaning = inputs["Pollen Filter Cleaning"]?.lowercased() == "yes"
        let costPerKWh = 0.18
        let usageHours = CalculationHelper.convertMinutesToHours(minutes: usageTime)

        var kWhPerHour = 0.5  // Default for low fan speed
        switch fanSpeed {
        case "medium":
            kWhPerHour = 0.8
        case "high":
            kWhPerHour = 1.2
        default:
            break
        }
        if pollenFilterCleaning {
            kWhPerHour += 0.3
        }

        let usage = kWhPerHour * usageHours
        let cost = CalculationHelper.calculateCost(usage: usage, rate: costPerKWh)
        
        return DeviceUsageResult(
            usage: usage,
            cost: cost,
            waterUsage: nil,
            waterCost: nil
        )
    }
}

class Dishwasher: DeviceProtocol {
    var name: String = "Dishwasher"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Usage Time", placeholder: "Input minutes"),
        DeviceMetric(name: "Program Type", placeholder: "Eco/Normal"),
        DeviceMetric(name: "Extra Water", placeholder: "Yes/No")
    ]
    
    func calculateUsage(inputs: [String: String]) -> DeviceUsageResult {
        guard let validatedInputs = CalculationHelper.validateInputs(inputs, keys: ["Usage Time"]) else {
            return DeviceUsageResult(usage: 0.0, cost: 0.0, waterUsage: nil, waterCost: nil)
        }
        
        let usageTime = validatedInputs["Usage Time"] ?? 0.0
        let programType = inputs["Program Type"]?.lowercased() ?? "normal"
        let extraWater = inputs["Extra Water"]?.lowercased() == "yes"
        let usageHours = CalculationHelper.convertMinutesToHours(minutes: Int(usageTime))
        let costPerLiterWater = 0.005
        let costPerKWh = 0.20  // Assuming a cost per kWh for electricity

        var waterUsage: Double = programType == "eco" ? 30.0 * usageHours : 50.0 * usageHours
        if extraWater {
            waterUsage += 10.0 * usageHours  // Additional water usage
        }
        
        var electricityUsage: Double = 0.1 * usageHours  // Base electricity usage per hour
        if programType == "eco" {
            electricityUsage *= 0.85  // Reduced electricity usage in eco mode
        }
        
        let waterCost = CalculationHelper.calculateCost(usage: waterUsage, rate: costPerLiterWater)
        let electricityCost = CalculationHelper.calculateCost(usage: electricityUsage, rate: costPerKWh)
        
        return DeviceUsageResult(
            usage: electricityUsage,  // Total water usage
            cost: electricityCost,  // Total cost for water
            waterUsage: waterUsage,  // Electricity usage
            waterCost: waterCost  // Cost for electricity used
        )
    }
}

class Oven: DeviceProtocol {
    var name: String = "Oven"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Usage Time", placeholder: "Input minutes"),
        DeviceMetric(name: "Adjusted Temperature", placeholder: "Input an integer value"),
        DeviceMetric(name: "Fan Speed", placeholder: "Low/Medium/High")
    ]
    
    func calculateUsage(inputs: [String: String]) -> DeviceUsageResult {
        guard let usageTime = Int(inputs["Usage Time"] ?? "0"),
              let adjustedTemperature = Int(inputs["Adjusted Temperature"] ?? "0") else {
            return DeviceUsageResult(usage: 0.0, cost: 0.0, waterUsage: nil, waterCost: nil)
        }

        let fanSpeed = inputs["Fan Speed"]?.lowercased() ?? "low"
        let costPerUnitGas = 0.10
        let usageHours = CalculationHelper.convertMinutesToHours(minutes: usageTime)

        var gasPerHour = 1.0  // Default base gas consumption
        if adjustedTemperature > 120 {
            gasPerHour += Double(adjustedTemperature - 120) * 0.05
        }
        switch fanSpeed {
        case "medium":
            gasPerHour += 0.2
        case "high":
            gasPerHour += 0.4
        default:
            break
        }

        let usage = gasPerHour * usageHours
        let cost = CalculationHelper.calculateCost(usage: usage, rate: costPerUnitGas)
        
        return DeviceUsageResult(
            usage: usage,
            cost: cost,
            waterUsage: nil,
            waterCost: nil
        )
    }
}
