//
//  TrainViewController.swift
//  Valence
//
//  Created by Matthew Kaulfers on 2/4/21.
//

import Foundation
import UIKit
import BuzzBLE

class TrainViewController: UIViewController {
    
    var buzzManager: BuzzDeviceManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        buzzManager?.buzzDevice?.stopMotors()
    }
    
    //MARK: - Button Tapped Controls
    
    @IBAction func happyTapped(_ sender: Any) {
        buzzManager?.runHappy()
    }
    
    @IBAction func sadTapped(_ sender: Any) {
        buzzManager?.runSad()
    }
    
    @IBAction func surpriseTapped(_ sender: Any) {
        buzzManager?.runSurprised()
    }
    
    @IBAction func fearfulTapped(_ sender: Any) {
        buzzManager?.runFearful()
    }
    
    @IBAction func disgustTapped(_ sender: Any) {
        buzzManager?.runDisgust()
    }
    
    @IBAction func angryTapped(_ sender: Any) {
        buzzManager?.runAngry()
    }
    
    @IBAction func neutralTapped(_ sender: Any) {
        buzzManager?.runNeutral()
    }
}
