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
import Combine

class BuzzConnected: UIViewController {
    private var recognizeModel = RecognizeModel()
    private var cancellable: AnyCancellable?
    @IBOutlet weak var batteryLabel: UILabel!
    var buzzManager: BuzzDeviceManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateBattery), name: NSNotification.Name(rawValue: "batteryUpdated"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cancellable = recognizeModel.objectWillChange.sink { [weak self] in
            self?.recognized()
        }
        recognizeModel.setup()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        buzzManager?.buzzDevice?.stopMotors()
        recognizeModel.stopRecognizing()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is TrainViewController {
            let dest = segue.destination as! TrainViewController
            dest.buzzManager = buzzManager
        } else if segue.destination is TestViewController {
            let dest = segue.destination as! TestViewController
            dest.buzzManager = buzzManager
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
    
    func recognized() {
//        print("\(recognizeModel.prediction.categoryTitle) (\(recognizeModel.prediction.categoryIndex)) \(recognizeModel.prediction.percentage) %")
        switch recognizeModel.prediction.categoryIndex {
        case 0:
            buzzManager?.runAngry()
        case 1:
            buzzManager?.runDisgust()
        case 2:
            buzzManager?.runFearful()
        case 3:
            buzzManager?.runHappy()
        case 4:
            buzzManager?.runNeutral()
        case 5:
            buzzManager?.runSad()
        case 6:
            buzzManager?.runSurprised()
        default:
            fatalError("no index category available")
        }
    }
}
