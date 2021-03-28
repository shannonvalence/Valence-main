//
//  BuzzDevice.swift
//  Valence
//
//  Created by Matthew Kaulfers on 2/4/21.
//

import Foundation
import BuzzBLE

class BuzzDeviceManager: BuzzManagerDelegate, BuzzDelegate {
    var buzzManager: BuzzManager?
    var buzzDevice: Buzz?
    var buzzBattery: Int?
    var buzzUUID: UUID?
    
    init() {
        buzzManager = BuzzManager()
        buzzManager?.delegate = self 
    }
    
    func scan() {
        buzzManager!.startScanning(timeoutSecs: -1, assumeDisappearanceAfter: 1)
    }
    
    
    func didUpdateState(_ buzzManager: BuzzManager, to state: BuzzManagerState) {
    }
    
    func didDiscover(_ buzzManager: BuzzManager, uuid: UUID, advertisementData: [String : Any], rssi: NSNumber) {
        print("Did discover: \(uuid)")
        buzzManager.connectToBuzz(havingUUID: uuid)
    }
    
    func didRediscover(_ buzzManager: BuzzManager, uuid: UUID, advertisementData: [String : Any], rssi: NSNumber) {
        print("Did rediscover: \(uuid)")
        buzzManager.connectToBuzz(havingUUID: uuid)
    }
    
    func didDisappear(_ buzzManager: BuzzManager, uuid: UUID) {
        print("Did disappear: \(uuid)")
    }
    
    
    func didConnectTo(_ buzzManager: BuzzManager, uuid: UUID) {
        print("Did connect to: \(uuid)")
        buzzUUID = uuid
        buzzDevice = buzzManager.getBuzz(uuid: uuid)
        buzzDevice?.delegate = self
        buzzDevice?.enableCommunication()
        buzzManager.stopScanning()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "buzzConnected"), object: nil)
    }
    
    func didDisconnectFrom(_ buzzManager: BuzzManager, uuid: UUID, error: Error?) {
        print("Did disconnect from: \(uuid)")
        buzzDevice = nil
        scan()
    }
    
    //MARK: - BuzzDelegate
    func buzz(_ buzz: Buzz, isCommunicationEnabled: Bool, error: Error?) {
        if let error = error {
            print("BuzzDelegate.isCommunicationEnabled: \(isCommunicationEnabled), error: \(error))")
        } else {
            if isCommunicationEnabled {
                print("BuzzDelegate.isCommunicationEnabled: communication enabled, requesting device and battery info and then authorizing...")
                buzz.requestBatteryInfo() // TODO: Add a timer to update battery level periodically
                buzz.requestDeviceInfo()
                buzz.authorize()
            } else {
                // TODO:
                print("BuzzDelegate.isCommunicationEnabled: failed to enable communication. Um...darn.")
            }
        }
    }
    
    func buzz(_ buzz: Buzz, isAuthorized: Bool, errorMessage: String?) {
        if isAuthorized {
            // now that we're authorized, disable the mic, enable motors, and stop the motors
            buzz.disableMic()
            buzz.enableMotors()
            buzz.clearMotorsQueue()
            buzz.requestBatteryInfo()
        } else {
            // TODO:
            print("Failed to authorize: \(String(describing: errorMessage))")
        }
    }
    
    func buzz(_ buzz: Buzz, batteryInfo: Buzz.BatteryInfo) {
        print("BuzzDelegate.batteryInfo: \(batteryInfo)")
        buzzBattery = batteryInfo.level
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "batteryUpdated"), object: nil)
    }
    
    func runHappy() {
        setMotorPattern(motors: [[0,125,0,0],
                                 [0,0,125,0]], motorRunTime: 0.5)
    }
    
    func runSad() {
        setMotorPattern(motors: [[75, 0, 0, 0],
                                 [0, 75, 0, 0],
                                 [0, 0, 75, 0],
                                 [0, 0, 0, 75]], motorRunTime: 0.5)
    }
    
    func runSurprised() {
        setMotorPattern(motors: [[0,75,75,0]], motorRunTime: 1)
    }
    
    func runFearful() {
        setMotorPattern(motors: [[150,0,0,0],
                                 [0,150,0,0],
                                 [0,0,150,0]], motorRunTime: 0.5)
    }
    
    func runDisgust() {
        setMotorPattern(motors: [[0,100,0,0],
                                 [0,0,100,0]], motorRunTime: 0.5)
    }
    
    func runAngry() {
        setMotorPattern(motors: [[250,0,0,250]], motorRunTime: 1)
    }
    
    func runNeutral() {
        setMotorPattern(motors: [[30,30,30,30]], motorRunTime: 1)
    }
    
    func setMotorPattern(motors: [[UInt8]], motorRunTime seconds: Double) {
        buzzDevice?.clearMotorsQueue()
        var motorIndex = 0
        Timer.scheduledTimer(withTimeInterval: seconds, repeats: true) { t in
            self.buzzDevice?.stopMotors()
            self.buzzDevice?.setMotorVibration(motors[motorIndex][0], motors[motorIndex][1], motors[motorIndex][2], motors[motorIndex][3])
            
            if motorIndex != motors.count - 1 {
                motorIndex += 1
            } else {
                t.invalidate()
                Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { t in
                    self.buzzDevice?.stopMotors()
                    t.invalidate()
                }
            }
        }
    }
    
}
