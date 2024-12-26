//
//  DeviceViewController.swift
//  HomePilotApp
//
//  Created by Helin Güler on 21.12.2024.
//

import UIKit

class DeviceViewController: UIViewController {
    
    @IBOutlet weak var devicePicker: UISegmentedControl!
    @IBOutlet weak var metricContainer: UIStackView!
    @IBOutlet weak var calculateButton: UIButton!
    
    
    var devices: [DeviceProtocol] = [AC(), WashingMachine(), Combi(), AirHumidifier(), Dishwasher(), Oven()]
    var selectedDeviceIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDevicePicker()
        loadDeviceMetrics()
        
        // Do any additional setup after loading the view.
    }
    
    func setupDevicePicker() {
        devicePicker.removeAllSegments()
        for (index, device) in devices.enumerated() {
            devicePicker.insertSegment(withTitle: device.name, at: index, animated: false)
        }
        devicePicker.selectedSegmentIndex = selectedDeviceIndex
        devicePicker.addTarget(self, action: #selector(deviceChanged), for: .valueChanged)
    }
    
    @objc func deviceChanged() {
        selectedDeviceIndex = devicePicker.selectedSegmentIndex
        loadDeviceMetrics()
    }
    
    func loadDeviceMetrics() {
        // Önceki metrikleri temizle
        metricContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Yeni cihazın metriklerini yükle
        let selectedDevice = devices[selectedDeviceIndex]
        for metric in selectedDevice.metrics {
            let metricView = DynamicMetricView(metric: metric)
            metricContainer.addArrangedSubview(metricView)
        }
    }
    
    @IBAction func calculateButtonTapped(_ sender: Any) {let selectedDevice = devices[selectedDeviceIndex]
        var inputs: [String: String] = [:]

        for (index, metricView) in metricContainer.arrangedSubviews.enumerated() {
            if let dynamicMetricView = metricView as? DynamicMetricView {
                let metricName = selectedDevice.metrics[index].name
                let inputValue = dynamicMetricView.textField.text ?? ""
                inputs[metricName] = inputValue
            }
        }

        let result = selectedDevice.calculateUsage(inputs: inputs)
        showCalculationResult(result: result)
        
        let userInfo: [String: Any] = [
            "deviceName": selectedDevice.name,
            "cost": result.cost,
            "electricityUsage": result.usage,
            "waterUsage": result.waterUsage ?? 0,
            "waterCost": result.waterCost ?? 0,
            "index": selectedDeviceIndex
        ]
        NotificationCenter.default.post(name: Notification.Name("UpdateTotalCost"), object: nil, userInfo: userInfo)



    }
    
    func showCalculationResult(result: DeviceUsageResult) {
        var message = "You have used \(String(format: "%.2f", result.usage)) kWh. This will cost you $\(String(format: "%.2f", result.cost))"

            // Check if there is electricity usage and cost data available
            if let waterUsage = result.waterUsage, let waterCost = result.waterCost {
                message += "\n\nWater used: \(String(format: "%.2f", waterUsage)) L. This will cost you $\(String(format: "%.2f", waterCost))"
            }

            let alertController = UIAlertController(title: "Energy Consumption", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            present(alertController, animated: true)
    }
    

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
