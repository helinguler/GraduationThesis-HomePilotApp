//
//  HomeViewController.swift
//  HomePilotApp
//
//  Created by Helin Güler on 15.12.2024.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var sourceCardsCollectionView: UICollectionView!
    
    var energyTypeLabel = ["Electricity", "Water", "Natural Gas"]
    var sourceAmountLabel = ["0 kWH", "0 m³", "0 kwH"]
    var totalCostLabel = ["Total Cost: 0$", "Total Cost: 10$", "Total Cost: 20$"]
    var sourceCardsImages = ["1", "2", "3"]
    
    // Adding timer
    var timer: Timer?
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        return sourceCardsImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = sourceCardsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SourceCardsCollectionViewCell
        
        // Set the labels
        cell.energyTypeLabel.text = energyTypeLabel[indexPath.row]
        cell.sourceAmountLabel.text = sourceAmountLabel[indexPath.row]
        cell.totalCostLabel.text = totalCostLabel[indexPath.row]
        
        // Set the image
        cell.sourceCardsImage.image = UIImage(named: sourceCardsImages[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: sourceCardsCollectionView.frame.width, height: sourceCardsCollectionView.frame.height)
    }
}
