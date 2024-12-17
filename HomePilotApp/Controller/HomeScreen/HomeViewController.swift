//
//  HomeViewController.swift
//  HomePilotApp
//
//  Created by Helin Güler on 15.12.2024.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var sourceCardsCollectionView: UICollectionView!
    
    var sourceCardsImages = ["1", "2", "3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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

extension HomeViewController: UICalendarViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sourceCardsImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = sourceCardsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SourceCardsCollectionViewCell
        
        cell.sourceCardsImage.image = UIImage(named: sourceCardsImages[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: sourceCardsCollectionView.frame.width, height: sourceCardsCollectionView.frame.height)
    }
}
