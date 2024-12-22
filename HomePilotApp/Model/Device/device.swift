//
//  device.swift
//  HomePilotApp
//
//  Created by Helin Güler on 21.12.2024.
//

import Foundation

protocol DeviceProtocol {
    var name: String { get }
    var metrics: [DeviceMetric] { get }
    func calculateUsage(inputs: [String: String]) -> (usage: Double, cost: Double)
}

struct DeviceMetric {
    let name: String
    let placeholder: String
}

class AC: DeviceProtocol {
    var name: String = "AC"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Usage Time", placeholder: "Input minutes"),
        DeviceMetric(name: "Mode Type", placeholder: "Summer/Winter mode"),
        DeviceMetric(name: "Adjusted Temperature", placeholder: "Input an integer value"),
    ]
    
    func calculateUsage(inputs: [String: String]) -> (usage: Double, cost: Double) {
        let costPerKWh = 0.20 // Example cost per kWh in dollars
        
        //guard let usageTime = Double(inputs["Usage Time"] ?? "0") else { return (0, 0) }
        guard let adjustedTemperature = Int(inputs["Adjusted Temperature"] ?? "0"),
              let usageTime = Int(inputs["Usage Time"] ?? "0") else {
                    print("Invalid input. Please enter valid numbers for temperature and usage time.")
                    return (0.0, 0.0)
                }
        
        print("Adjusted Temperature: \(adjustedTemperature), Usage Time: \(usageTime)") // Değerleri kontrol et
        
        let usageHours = Double(usageTime) / 60.0
        var usage: Double = 0.0
        let modeType = inputs["Mode Type"] ?? "summer"
        
        if modeType.lowercased() == "summer" {
                    // Summer mode: lower temp -> higher kWh, higher temp -> lower kWh
                    if adjustedTemperature < 24 {
                        usage = 2.0 * usageHours // High consumption for low temperatures
                    } else {
                        usage = 1.2 * usageHours // Low consumption for high temperatures
                    }
        }
        else if modeType.lowercased() == "winter" {
                    // Winter mode: higher temp -> higher kWh, lower temp -> lower kWh
            if adjustedTemperature > 22 {
                usage = 2.5 * usageHours // High consumption for high temperatures
            }
            else {
                usage = 1.5 * usageHours // Low consumption for low temperatures
            }
        }
        else {
            print("Invalid mode type. Please choose either 'Summer' or 'Winter'.")
            return (0.0, 0.0)
        }
        
        let cost = usage * costPerKWh
        print("Usage: \(usage), Cost: \(cost)") // Sonuçları kontrol et
        return (usage, cost)
    }
}

class WashingMachine: DeviceProtocol {
    var name: String = "Washer"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Usage Time", placeholder: "Input minutes"),
        DeviceMetric(name: "Program Type", placeholder: "Eco/Normal"),
        DeviceMetric(name: "Extra Water", placeholder: "Yes/No")
    ]
    
    func calculateUsage(inputs: [String: String]) -> (usage: Double, cost: Double) {
        let costPerLiterWater = 0.005 // Example cost per liter of water
                
                // Convert inputs to appropriate types
                guard let usageTime = Int(inputs["Usage Time"] ?? "0") else {
                    print("Invalid input. Please enter a valid number for usage time.")
                    return (0.0, 0.0)
                }
                
                let programType = inputs["Program Type"]?.lowercased() ?? "normal"
                let extraWater = inputs["Extra Water"]?.lowercased() == "yes"
                
                let usageHours = Double(usageTime) / 60.0
                
                // Base water usage values
                var usage: Double = 0.0

                if programType == "eco" {
                    usage = 30.0 * usageHours // Lower water consumption for eco mode
                } else if programType == "normal" {
                    usage = 50.0 * usageHours // Higher water consumption for normal mode
                } else {
                    print("Invalid program type. Please choose either 'Eco' or 'Normal'.")
                    return (0.0, 0.0)
                }
                
                // Add extra water usage if applicable
                if extraWater {
                    usage += 10.0 * usageHours
                }
                
                // Calculate water cost
                let cost = usage * costPerLiterWater
                
                return (usage, cost)
        }
    
}

class Combi: DeviceProtocol {
    var name: String = "Combi"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Usage Time", placeholder: "Input hours"),       // Input hour not minute
        DeviceMetric(name: "Adjusted Temperature", placeholder: "Input an integer value"),
        DeviceMetric(name: "Number of Radiators", placeholder: "Input an integer value"),
    ]
    
    func calculateUsage(inputs: [String: String]) -> (usage: Double, cost: Double) {
            let costPerKWh = 0.15 // Example cost per kWh in dollars

            // Convert inputs to appropriate types
            guard let usageTime = Double(inputs["Usage Time"] ?? "0"),
                  let adjustedTemperature = Int(inputs["Adjusted Temperature"] ?? "0"),
                  let numberOfRadiators = Int(inputs["Number of Radiators"] ?? "0") else {
                print("Invalid input. Please enter valid numbers for usage time, temperature, and radiators.")
                return (0.0, 0.0)
            }

            // Base energy consumption per hour
            var kWhPerHour = 1.5 // Default base consumption

            // Adjust consumption based on temperature
            if adjustedTemperature > 30 {
                kWhPerHour += Double(adjustedTemperature - 30) * 0.2 // Extra 0.2 kWh for each degree above 30
            }

            // Adjust consumption based on number of radiators
            kWhPerHour += Double(numberOfRadiators) * 0.1 // Extra 0.1 kWh per radiator

            // Total energy consumption
            let usage = kWhPerHour * usageTime

            // Calculate total cost
            let cost = usage * costPerKWh

            return (usage, cost)
        }
    
}

class AirHumidifier: DeviceProtocol {
    var name: String = "Air Humidifier"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Usage Time", placeholder: "Input minutes"),
        DeviceMetric(name: "Fan Speed", placeholder: "Low/Medium/High"),
        DeviceMetric(name: "Pollen Filter Cleaning", placeholder: "Yes/No")
    ]
    
    // Method to calculate energy usage and cost
        func calculateUsage(inputs: [String: String]) -> (usage: Double, cost: Double) {
            let costPerKWh = 0.18 // Example cost per kWh in dollars

            // Convert inputs to appropriate types
            guard let usageTime = Int(inputs["Usage Time"] ?? "0") else {
                print("Invalid input. Please enter a valid number for usage time.")
                return (0.0, 0.0)
            }

            let fanSpeed = inputs["Fan Speed"]?.lowercased() ?? "low"
            let pollenFilterCleaning = inputs["Pollen Filter Cleaning"]?.lowercased() == "yes"

            let usageHours = Double(usageTime) / 60.0

            // Base energy consumption values
            var kWhPerHour = 0.5 // Default for low fan speed

            switch fanSpeed {
            case "medium":
                kWhPerHour = 0.8
            case "high":
                kWhPerHour = 1.2
            default:
                kWhPerHour = 0.5
            }

            // Add extra consumption for pollen filter cleaning
            if pollenFilterCleaning {
                kWhPerHour += 0.3
            }

            // Total energy consumption
            let usage = kWhPerHour * usageHours

            // Calculate total cost
            let cost = usage * costPerKWh

            return (usage, cost)
        }
    
}

class Dishwasher: DeviceProtocol {
    var name: String = "Dishwasher"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Usage Time", placeholder: "Input minutes"),
        DeviceMetric(name: "Program Type", placeholder: "Eco/Normal"),
        DeviceMetric(name: "Extra Water", placeholder: "Yes/No")
    ]
    
    func calculateUsage(inputs: [String: String]) -> (usage: Double, cost: Double) {
        let costPerLiterWater = 0.005 // Example cost per liter of water
                
                // Convert inputs to appropriate types
                guard let usageTime = Int(inputs["Usage Time"] ?? "0") else {
                    print("Invalid input. Please enter a valid number for usage time.")
                    return (0.0, 0.0)
                }
                
                let programType = inputs["Program Type"]?.lowercased() ?? "normal"
                let extraWater = inputs["Extra Water"]?.lowercased() == "yes"
                
                let usageHours = Double(usageTime) / 60.0
                
                // Base water usage values
                var usage: Double = 0.0

                if programType == "eco" {
                    usage = 30.0 * usageHours // Lower water consumption for eco mode
                } else if programType == "normal" {
                    usage = 50.0 * usageHours // Higher water consumption for normal mode
                } else {
                    print("Invalid program type. Please choose either 'Eco' or 'Normal'.")
                    return (0.0, 0.0)
                }
                
                // Add extra water usage if applicable
                if extraWater {
                    usage += 10.0 * usageHours
                }
                
                // Calculate water cost
                let cost = usage * costPerLiterWater
                
                return (usage, cost)
        }
    
}

class Oven: DeviceProtocol {
    var name: String = "Oven"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Usage Time", placeholder: "Input minutes"),   
        DeviceMetric(name: "Adjusted Temperature", placeholder: "Input an integer value"),
        DeviceMetric(name: "Fan Speed", placeholder: "Low/Medium/High")
    ]
    
    func calculateUsage(inputs: [String: String]) -> (usage: Double, cost: Double) {
            let costPerUnitGas = 0.10 // Example cost per unit of gas in dollars

            // Convert inputs to appropriate types
            guard let usageTime = Int(inputs["Usage Time"] ?? "0"),
                  let adjustedTemperature = Int(inputs["Adjusted Temperature"] ?? "0") else {
                print("Invalid input. Please enter valid numbers for usage time and temperature.")
                return (0.0, 0.0)
            }

            let fanSpeed = inputs["Fan Speed"]?.lowercased() ?? "low"

            let usageHours = Double(usageTime) / 60.0

            // Base gas consumption values
            var gasPerHour = 1.0 // Default base gas consumption

            // Adjust gas consumption based on temperature
            if adjustedTemperature > 120 {
                gasPerHour += Double(adjustedTemperature - 120) * 0.05 // Extra 0.05 units for each degree above 120
            }

            // Adjust gas consumption based on fan speed
            switch fanSpeed {
            case "medium":
                gasPerHour += 0.2
            case "high":
                gasPerHour += 0.4
            default:
                gasPerHour += 0.0
            }

            // Total gas consumption
            let usage = gasPerHour * usageHours

            // Calculate total cost
            let cost = usage * costPerUnitGas

            return (usage, cost)
        }
    
}
