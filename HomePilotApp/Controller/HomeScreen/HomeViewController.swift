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
    var sourceAmountLabel = ["0 kWH", "0 m³", "0 kwH"]
    var totalCostLabel = ["Total Cost: 0$", "Total Cost: 10$", "Total Cost: 20$"]
    var sourceCardsImages = ["1", "2", "3"]
    
    // Device Cards Variables
    var deviceNameLabel = ["AC", "Washing Machine", "Natural Gas", "Water Despenser"]
    var deviceCostLabel = ["Cost: 0$", "Cost: 10$", "Cost: 20$", "Cost: 30$"]
    //var deviceAddButton = []
    var deviceCardsImages = ["a", "b", "c", "d"]
    
    
    // Adding timer to Source Cards
    var timer: Timer?
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Timer to Source Cards
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(moveToNext), userInfo: nil, repeats: true)
        
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
}
