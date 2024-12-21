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
}

struct DeviceMetric {
    let name: String
    let placeholder: String
}

class AC: DeviceProtocol {
    var name: String = "AC"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Çalışma Süresi (saat)", placeholder: "Örn: 5"),
        DeviceMetric(name: "Güç Tüketimi (W)", placeholder: "Örn: 1500"),
        DeviceMetric(name: "Hedef Sıcaklık (°C)", placeholder: "Örn: 24"),
        DeviceMetric(name: "Fan Hızı", placeholder: "Düşük/Orta/Yüksek")
    ]
}

class WashingMachine: DeviceProtocol {
    var name: String = "Washing Machine"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Çalıştırma Sayısı", placeholder: "Örn: 2"),
        DeviceMetric(name: "Program Türü", placeholder: "Eko/Normal"),
        DeviceMetric(name: "Su Tüketimi (litre)", placeholder: "Örn: 50")
    ]
}

class NaturalGas: DeviceProtocol {
    var name: String = "Natural Gas"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Kullanım Türü", placeholder: "Isıtma/Sıcak Su"),
        DeviceMetric(name: "Kullanım Süresi (saat)", placeholder: "Örn: 3"),
        DeviceMetric(name: "Doğal Gaz Tüketimi (m³)", placeholder: "Örn: 5")
    ]
}

class WaterDispenser: DeviceProtocol {
    var name: String = "Water Dispenser"
    var metrics: [DeviceMetric] = [
        DeviceMetric(name: "Çalışma Süresi (saat)", placeholder: "Örn: 6"),
        DeviceMetric(name: "Sıcak/Soğuk Modu", placeholder: "Açık/Kapalı"),
        DeviceMetric(name: "Güç Tüketimi (W)", placeholder: "Örn: 300")
    ]
}
