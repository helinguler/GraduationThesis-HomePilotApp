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
    let electricityUsage: Double? // Sadece elektrik kullanan cihazlar için
    let electricityCost: Double?
    let waterUsage: Double?       // Sadece su kullanan cihazlar için
    let waterCost: Double?
    let gasUsage: Double?         // Sadece gaz kullanan cihazlar için
    let gasCost: Double?
    let totalCost: Double         // Cihazın toplam maliyeti
    let usageTime: Double?        // Kullanım süresi (saat)
    let date: Date                // Kullanım tarihi
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
            return DeviceUsageResult(electricityUsage: nil, electricityCost: nil, waterUsage: nil, waterCost: nil, gasUsage: nil, gasCost: nil, totalCost: 0.0, usageTime: nil, date: Date())
        }

        let usageTime = validatedInputs["Usage Time"] ?? 0.0
        let adjustedTemperature = validatedInputs["Adjusted Temperature"] ?? 0.0
        let modeType = inputs["Mode Type"]?.lowercased() ?? "summer"
        let usageHours = CalculationHelper.convertMinutesToHours(minutes: Int(usageTime))
        let costPerKWh = 0.20

        var electricityUsage: Double = 0.0
        if modeType == "summer" {
            electricityUsage = adjustedTemperature < 24 ? 2.0 * usageHours : 1.2 * usageHours
        } else {
            electricityUsage = adjustedTemperature > 22 ? 2.5 * usageHours : 1.5 * usageHours
        }

        let electricityCost = CalculationHelper.calculateCost(usage: electricityUsage, rate: costPerKWh)
        return DeviceUsageResult(electricityUsage: electricityUsage, electricityCost: electricityCost, waterUsage: nil, waterCost: nil, gasUsage: nil, gasCost: nil, totalCost: electricityCost, usageTime: usageHours, date: Date())
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
            return DeviceUsageResult(
                electricityUsage: nil,
                electricityCost: nil,
                waterUsage: nil,
                waterCost: nil,
                gasUsage: nil,
                gasCost: nil,
                totalCost: 0.0,
                usageTime: nil,
                date: Date()
            )
        }

        let usageTime = validatedInputs["Usage Time"] ?? 0.0
        let programType = inputs["Program Type"]?.lowercased() ?? "normal"
        let extraWater = inputs["Extra Water"]?.lowercased() == "yes"
        let usageHours = CalculationHelper.convertMinutesToHours(minutes: Int(usageTime))
        let costPerLiterWater = 0.005
        let costPerKWh = 0.20

        var waterUsage: Double = programType == "eco" ? 30.0 * usageHours : 50.0 * usageHours
        if extraWater {
            waterUsage += 10.0 * usageHours
        }

        let electricityUsage: Double = programType == "eco" ? 0.085 * usageHours : 0.1 * usageHours
        let waterCost = CalculationHelper.calculateCost(usage: waterUsage, rate: costPerLiterWater)
        let electricityCost = CalculationHelper.calculateCost(usage: electricityUsage, rate: costPerKWh)
        let totalCost = waterCost + electricityCost

        return DeviceUsageResult(
            electricityUsage: electricityUsage,
            electricityCost: electricityCost,
            waterUsage: waterUsage,
            waterCost: waterCost,
            gasUsage: nil,
            gasCost: nil,
            totalCost: totalCost,
            usageTime: usageHours,
            date: Date()
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
            return DeviceUsageResult(electricityUsage: nil, electricityCost: nil, waterUsage: nil, waterCost: nil, gasUsage: nil, gasCost: nil, totalCost: 0.0, usageTime: nil, date: Date())
        }

        let costPerKWh = 0.15
        var kWhPerHour = 1.5
        if adjustedTemperature > 30 {
            kWhPerHour += Double(adjustedTemperature - 30) * 0.2
        }
        kWhPerHour += Double(numberOfRadiators) * 0.1

        let gasUsage = kWhPerHour * usageTime
        let gasCost = CalculationHelper.calculateCost(usage: gasUsage, rate: costPerKWh)

        return DeviceUsageResult(electricityUsage: nil, electricityCost: nil, waterUsage: nil, waterCost: nil, gasUsage: gasUsage, gasCost: gasCost, totalCost: gasCost, usageTime: usageTime, date: Date())
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
            return DeviceUsageResult(electricityUsage: nil, electricityCost: nil, waterUsage: nil, waterCost: nil, gasUsage: nil, gasCost: nil, totalCost: 0.0, usageTime: nil, date: Date())
        }

        let fanSpeed = inputs["Fan Speed"]?.lowercased() ?? "low"
        let pollenFilterCleaning = inputs["Pollen Filter Cleaning"]?.lowercased() == "yes"
        let costPerKWh = 0.18
        let usageHours = CalculationHelper.convertMinutesToHours(minutes: usageTime)

        var electricityUsage: Double = 0.5
        switch fanSpeed {
        case "medium": electricityUsage = 0.8
        case "high": electricityUsage = 1.2
        default: break
        }
        if pollenFilterCleaning {
            electricityUsage += 0.3
        }

        let electricityCost = CalculationHelper.calculateCost(usage: electricityUsage, rate: costPerKWh)
        return DeviceUsageResult(electricityUsage: electricityUsage, electricityCost: electricityCost, waterUsage: nil, waterCost: nil, gasUsage: nil, gasCost: nil, totalCost: electricityCost, usageTime: usageHours, date: Date())
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
            return DeviceUsageResult(electricityUsage: nil, electricityCost: nil, waterUsage: nil, waterCost: nil, gasUsage: nil, gasCost: nil, totalCost: 0.0, usageTime: nil, date: Date())
        }

        let usageTime = validatedInputs["Usage Time"] ?? 0.0
        let programType = inputs["Program Type"]?.lowercased() ?? "normal"
        let extraWater = inputs["Extra Water"]?.lowercased() == "yes"
        let usageHours = CalculationHelper.convertMinutesToHours(minutes: Int(usageTime))
        let costPerLiterWater = 0.005
        let costPerKWh = 0.20

        var waterUsage: Double = programType == "eco" ? 30.0 * usageHours : 50.0 * usageHours
        if extraWater {
            waterUsage += 10.0 * usageHours
        }

        let electricityUsage: Double = programType == "eco" ? 0.085 * usageHours : 0.1 * usageHours
        let waterCost = CalculationHelper.calculateCost(usage: waterUsage, rate: costPerLiterWater)
        let electricityCost = CalculationHelper.calculateCost(usage: electricityUsage, rate: costPerKWh)
        let totalCost = waterCost + electricityCost

        return DeviceUsageResult(electricityUsage: electricityUsage, electricityCost: electricityCost, waterUsage: waterUsage, waterCost: waterCost, gasUsage: nil, gasCost: nil, totalCost: totalCost, usageTime: usageHours, date: Date())
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
        guard let usageTime = Double(inputs["Usage Time"] ?? "0"),
              let adjustedTemperature = Double(inputs["Adjusted Temperature"] ?? "0"),
              let fanSpeed = inputs["Fan Speed"]?.lowercased() else {
            return DeviceUsageResult(
                electricityUsage: nil,
                electricityCost: nil,
                waterUsage: nil,
                waterCost: nil,
                gasUsage: nil,
                gasCost: nil,
                totalCost: 0.0,
                usageTime: nil,
                date: Date()
            )
        }

        let costPerUnitGas = 0.10
        let usageHours = CalculationHelper.convertMinutesToHours(minutes: Int(usageTime))

        // Gaz tüketimini hesapla
        var gasUsage: Double = 1.0 // Baz gaz tüketimi
        if adjustedTemperature > 120 {
            gasUsage += (adjustedTemperature - 120) * 0.05
        }

        switch fanSpeed {
        case "medium":
            gasUsage += 0.2
        case "high":
            gasUsage += 0.4
        default:
            break
        }

        // Toplam maliyet hesapla
        let gasCost = CalculationHelper.calculateCost(usage: gasUsage * usageHours, rate: costPerUnitGas)
        let totalCost = gasCost

        return DeviceUsageResult(
            electricityUsage: nil,
            electricityCost: nil,
            waterUsage: nil,
            waterCost: nil,
            gasUsage: gasUsage * usageHours,
            gasCost: gasCost,
            totalCost: totalCost,
            usageTime: usageHours,
            date: Date()
        )
    }
}
