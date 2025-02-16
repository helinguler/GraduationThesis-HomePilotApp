//
//  HomeViewController.swift
//  HomePilotApp
//
//  Created by Helin Güler on 15.12.2024.
//

import UIKit
import CoreData
import FirebaseAuth

class HomeViewController: UIViewController {
    
    @IBOutlet weak var sourceCardsCollectionView: UICollectionView!
    @IBOutlet weak var deviceCardsCollectionView: UICollectionView!
    
    // Source Cards Variables
    var energyTypeLabel = ["Electricity", "Water", "Natural Gas"]
    var sourceAmountLabel = ["0 kWH", "0 L", "0 kwH"]
    var totalCostLabel = ["Total Cost: 0$", "Total Cost: 0$", "Total Cost: 0$"]
    var sourceCardsImages = ["1", "2", "3"]
    
    // Device Cards Variables
    var deviceNameLabel = ["Air Conditioning", "Washing Machine", "Combi", "Air Humidifier", "Dishwasher", "Oven"]
    var deviceCostLabel = ["Cost: 0$", "Cost: 0$", "Cost: 0$", "Cost: 0$", "Cost: 0$", "Cost: 0$"]
    var deviceCardsImages = ["a", "b", "c", "d", "e", "f"]
    
    // Adding timer to Source Cards
    var timer: Timer?
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadDeviceUsages()
        
        // Timer to Source Cards
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(moveToNext), userInfo: nil, repeats: true)

        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceUsageUpdate), name: Notification.Name("DeviceUsageUpdated"), object: nil)
    }
    
    @objc func handleDeviceUsageUpdate() {
        loadDeviceUsages()
    }
    
    // Cihaz verilerini Core Data'dan çekmek için
    func loadDeviceUsages() {
        if let currentUserUID = Auth.auth().currentUser?.uid,
           let currentUser = CoreDataManager.shared.fetchCurrentUser(uid: currentUserUID) {
            let usages = CoreDataManager.shared.fetchDeviceUsages(for: currentUser)
            updateSourceCards(with: usages)
            updateDeviceCards(with: usages)
        } else {
            print("No current user found or no usages available.")
        }
    }

    func updateUI(with usages: [DeviceUsage]) {
        // Kullanıcı arayüzünü güncellemek için bu fonksiyonu doldurun.
        for usage in usages {
            print("Device: \(String(describing: usage.deviceName)), Cost: \(usage.totalCost), Date: \(String(describing: usage.date))")
        }
        
        // Kaynak kartları güncellemesi için örnek
            updateSourceCards(with: usages)
    }
    
    // Update source cards with the usages
    func updateSourceCards(with usages: [DeviceUsage]) {
        var totalElectricityUsage: Double = 0.0
        var totalElectricityCost: Double = 0.0
        var totalWaterUsage: Double = 0.0
        var totalWaterCost: Double = 0.0
        var totalGasUsage: Double = 0.0
        var totalGasCost: Double = 0.0

        for usage in usages {
            totalElectricityUsage += usage.electricityUsage
            totalElectricityCost += usage.electricityCost
            totalWaterUsage += usage.waterUsage
            totalWaterCost += usage.waterCost
            totalGasUsage += usage.gasUsage
            totalGasCost += usage.gasCost
        }

        print("Electricity Usage: \(totalElectricityUsage), Cost: \(totalElectricityCost)")
            print("Water Usage: \(totalWaterUsage), Cost: \(totalWaterCost)")
            print("Gas Usage: \(totalGasUsage), Cost: \(totalGasCost)")
        
        sourceAmountLabel[0] = "\(String(format: "%.2f", totalElectricityUsage)) kWh"
        totalCostLabel[0] = "Total Cost: \(String(format: "%.2f", totalElectricityCost))$"

        sourceAmountLabel[1] = "\(String(format: "%.2f", totalWaterUsage)) L"
        totalCostLabel[1] = "Total Cost: \(String(format: "%.2f", totalWaterCost))$"

        sourceAmountLabel[2] = "\(String(format: "%.2f", totalGasUsage)) kWh"
        totalCostLabel[2] = "Total Cost: \(String(format: "%.2f", totalGasCost))$"

        sourceCardsCollectionView.reloadData()
    }
    
    func updateDeviceCards(with usages: [DeviceUsage]) {
        // Sabit cihaz isimleri
        let deviceNames = ["Air Conditioning", "Washing Machine", "Combi", "Air Humidifier", "Dishwasher", "Oven"]

        // Cihaz maliyetlerini saklamak için bir dictionary oluştur
        var deviceCostDictionary: [String: Double] = [:]
        for usage in usages {
            let normalizedDeviceName = normalizeDeviceName(usage.deviceName ?? "Unknown Device")
            deviceCostDictionary[normalizedDeviceName] = (deviceCostDictionary[normalizedDeviceName] ?? 0.0) + usage.totalCost
        }

        print("Device Cost Dictionary: \(deviceCostDictionary)") // Dictionary kontrolü

        // Sabit sıraya göre cihaz maliyetlerini güncelle
        deviceCostLabel = deviceNames.map { deviceName in
            let cost = deviceCostDictionary[deviceName] ?? 0.0
            return "Cost: \(String(format: "%.2f", cost))$"
        }

        print("Updated Device Cost Label: \(deviceCostLabel)") // Güncel maliyetleri kontrol et

        // Cihaz kartlarını yeniden yükle
        deviceCardsCollectionView.reloadData()
    }

    // her ana ekrana dönüşte Core Data'dan verilerin yeniden yüklenmesini sağlar ve UI güncellenir.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDeviceUsages()
    }

    // Moving Function for Timer
    @objc func moveToNext() {
        if currentIndex < sourceCardsImages.count - 1 {
            currentIndex = currentIndex + 1
        }
        else {
            currentIndex = 0
        }
        sourceCardsCollectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .right, animated: true)
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


// Delegate and DataSource for SourceCardsCollectionView
extension HomeViewController: UICalendarViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == sourceCardsCollectionView {
            return sourceCardsImages.count
        }
        else if collectionView == deviceCardsCollectionView {
            return deviceCardsImages.count
        }
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == sourceCardsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sourcecell", for: indexPath) as! SourceCardsCollectionViewCell
                    
            // Set SourceCardsCollectionView-specific data
            cell.energyTypeLabel.text = energyTypeLabel[indexPath.row]
            cell.sourceAmountLabel.text = sourceAmountLabel[indexPath.row]
            cell.totalCostLabel.text = totalCostLabel[indexPath.row]
            cell.sourceCardsImage.image = UIImage(named: sourceCardsImages[indexPath.row])
                    
            return cell
            
        }
        else if collectionView == deviceCardsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "devicecell", for: indexPath) as! DeviceCardsCollectionViewCell
            
            // Setting Border to devicecell
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.gray.cgColor
            cell.layer.cornerRadius = 25
                
            // Setting DeviceCardsCollectionView-specific data
            cell.deviceNameLabel.text = deviceNameLabel[indexPath.row]
            cell.deviceCostLabel.text = deviceCostLabel[indexPath.row]
            cell.deviceCardsImage.image = UIImage(named: deviceCardsImages[indexPath.row])
                    
            return cell
        }
        
        // Default return to avoid compilation issues
        return UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == sourceCardsCollectionView {
            return CGSize(width: sourceCardsCollectionView.frame.width, height: sourceCardsCollectionView.frame.height)
        }
        else if collectionView == deviceCardsCollectionView {
            let spacing: CGFloat = 10
            let totalSpacing = spacing * 3
            let width = (collectionView.frame.width - totalSpacing) / 2
            
            return CGSize(width: width, height: width)
            
            //let size = (sourceCardsCollectionView.frame.width - 20) / 2
            //return CGSize(width: size, height: size)
        }
         
        return CGSize.zero
    }
    
    // from DeviceCollectionViewCell to Device Screen (DeviceViewController)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeviceViewController") as! DeviceViewController
        
        vc.selectedDeviceIndex = indexPath.row
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func normalizeDeviceName(_ deviceName: String) -> String {
            switch deviceName.lowercased() {
            case "ac", "air conditioning":
                return "Air Conditioning"
            case "washer", "washing machine":
                return "Washing Machine"
            case "dishwasher":
                return "Dishwasher"
            case "combi", "boiler":
                return "Combi"
            case "humidifier", "air humidifier":
                return "Air Humidifier"
            case "oven":
                return "Oven"
            default:
                return "Unknown Device"
            }
        }
}
