//
//  DeviceViewController.swift
//  HomePilotApp
//
//  Created by Helin Güler on 21.12.2024.
//

import UIKit

class DeviceViewController: UIViewController {

    @IBOutlet weak var deviceNameLabel: UILabel!
    
    var deviceNameTitle: String?
    
    @IBOutlet weak var devicePicker: UISegmentedControl!
    @IBOutlet weak var metricContainer: UIStackView!
    
    var devices: [DeviceProtocol] = [AC(), WashingMachine(), NaturalGas(), WaterDispenser()]
    var selectedDeviceIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDevicePicker()
        loadDeviceMetrics()

        // Do any additional setup after loading the view.
        deviceNameLabel.text = deviceNameTitle
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
