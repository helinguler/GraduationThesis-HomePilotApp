//
//  HomeViewController.swift
//  HomePilotApp
//
//  Created by Helin Güler on 15.12.2024.
//

import UIKit

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
    var deviceCostLabel = ["Cost: 0$", "Cost: 10$", "Cost: 20$", "Cost: 30$", "Cost: 30$", "Cost: 30$"]
    var deviceCardsImages = ["a", "b", "c", "d", "a", "a"]
    
    
    // Adding timer to Source Cards
    var timer: Timer?
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Timer to Source Cards
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(moveToNext), userInfo: nil, repeats: true)
        
        // Total cost güncelleme
        NotificationCenter.default.addObserver(self, selector: #selector(updateTotalCost(_:)), name: Notification.Name("UpdateTotalCost"), object: nil)
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
    
    // Total cost için func
    @objc func updateTotalCost(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
                  let deviceName = userInfo["deviceName"] as? String,
                  let cost = userInfo["cost"] as? Double,
                  let index = userInfo["index"] as? Int else {
                return
            }
            
            // Cihaz Kartı Maliyetini Güncelle
        /*
            deviceCostLabel[index] = "Cost: \(cost)$"
            deviceCardsCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
         */
        // Cihaz maliyetini güncelle
        let currentCostText = deviceCostLabel[index]
        let currentCost = Double(currentCostText.components(separatedBy: " ")[1].dropLast()) ?? 0
        let updatedCost = currentCost + cost  // Bu satırda newCost yerine cost kullanılmalı
        deviceCostLabel[index] = formatCost(updatedCost)  // Maliyeti formatlı şekilde güncelle
            deviceCardsCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])


            // Cihaza bağlı olarak kaynak kartını güncelle
            switch deviceName {
            case "Washer", "Dishwasher":
                let waterCost = userInfo["waterCost"] as? Double ?? 0
                let waterUsage = userInfo["waterUsage"] as? Double ?? 0
                let electricityCost = cost
                let electricityUsage = userInfo["electricityUsage"] as? Double ?? 0
                updateSourceCard(type: "Water", newCost: waterCost, newConsumption: waterUsage)
                updateSourceCard(type: "Electricity", newCost: electricityCost, newConsumption: electricityUsage)
            case "AC", "Air Humidifier":
                let electricityUsage = userInfo["electricityUsage"] as? Double ?? 0
                updateSourceCard(type: "Electricity", newCost: cost, newConsumption: electricityUsage)
            case "Combi", "Oven":
                let gasUsage = userInfo["electricityUsage"] as? Double ?? 0  // Bu gaz kullanımı olmalı
                updateSourceCard(type: "Natural Gas", newCost: cost, newConsumption: gasUsage)
            default: break
            }
    }
    
    func updateSourceCard(type: String, newCost: Double, newConsumption: Double) {
        if let index = energyTypeLabel.firstIndex(of: type) {
                // Maliyeti güncelle
                let currentCostText = totalCostLabel[index]
                let currentCost = Double(currentCostText.components(separatedBy: " ")[2].dropLast()) ?? 0
                let updatedCost = currentCost + newCost
                totalCostLabel[index] = formatTotalCost(updatedCost)  // Formatlı maliyet metni

                // Tüketimi güncelle
                let currentConsumptionText = sourceAmountLabel[index]
                let currentConsumption = Double(currentConsumptionText.components(separatedBy: " ")[0]) ?? 0
                let updatedConsumption = currentConsumption + newConsumption
                sourceAmountLabel[index] = formatConsumption(updatedConsumption, for: type)
                
                // Belirli kartı yeniden yükle
                sourceCardsCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
    }
    
    func updateTotalCostLabel(newCost: Double) {
        // Mevcut toplam maliyeti güncellemek için label'ı düzenle
        if let totalCostLabel = sourceCardsCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? SourceCardsCollectionViewCell {
            let currentCostText = totalCostLabel.totalCostLabel.text ?? "Total Cost: 0$"
            let currentCost = Double(currentCostText.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines).dropLast()) ?? 0.0
            let updatedCost = currentCost + newCost
            totalCostLabel.totalCostLabel.text = "Total Cost: \(String(format: "%.2f", updatedCost))$"
        }
    }
    
    func formatCost(_ cost: Double) -> String {
        return String(format: "Cost: %.2f$", cost)
    }

    func formatTotalCost(_ cost: Double) -> String {
        return String(format: "Total Cost: %.2f$", cost)
    }
    
    func formatConsumption(_ consumption: Double, for type: String) -> String {
        let unit = type == "Electricity" ? "kWh" : "L"
        return String(format: "%.2f %@", consumption, unit)
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
}

