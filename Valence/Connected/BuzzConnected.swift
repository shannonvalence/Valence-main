//
//  BuzzConnected.swift
//  Valence
//
//  Created by Matthew Kaulfers on 2/2/21.
//

import Foundation
import UIKit
import BuzzBLE
import FirebaseAuth

class BuzzConnected: UIViewController {
    
    @IBOutlet weak var batteryLabel: UILabel!
    var buzzManager: BuzzDeviceManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateBattery), name: NSNotification.Name(rawValue: "batteryUpdated"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is TrainViewController {
            let dest = segue.destination as! TrainViewController
            dest.buzzManager = buzzManager
        } else {
            
        }
    }
    
    @objc func updateBattery() {
        batteryLabel.text = "Battery: \(buzzManager!.buzzBattery!)%"
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            let sb = UIStoryboard(name: "Main", bundle: .main)
            let vc = sb.instantiateInitialViewController()
            
            if vc != nil {
                present(vc!, animated: true, completion: nil)
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
