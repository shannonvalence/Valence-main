//
//  BuzzDevice.swift
//  Valence
//
//  Created by Matthew Kaulfers on 2/4/21.
//

import Foundation
import BuzzBLE

protocol BuzzDeviceDelegate {
    func buzzFinished()
}

class BuzzDeviceManager: BuzzDelegate {
    var buzzManager: BuzzManager?
    var buzzDevice: Buzz?
    var buzzBattery: Int?
    var buzzUUID: UUID?
    var runCount = 0
    var delegate: TestViewController?
    
    init() {
        buzzManager = BuzzManager()
    }
    
    func scan() {
        buzzManager!.startScanning(timeoutSecs: -1, assumeDisappearanceAfter: 1)
    }
    
    func stop() {
        buzzManager?.stopScanning()
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
    
    func runHappy(completion: (() -> Void)? = nil) {
        setMotorPattern(motors: [[0,0,0,150],
                                 [0,0,150,0],
                                 [0,150,0,0],
                                 [150,0,0,0]], motorRunTime: 0.25) {
            completion?()
        }
    }
    
    func runSad(completion: (() -> Void)? = nil) {
        setMotorPattern(motors: [[150,0,0,0],
                                 [0,0,0,150]], motorRunTime: 0.5) {
            completion?()
        }
    }
    
    func runSurprised(completion: (() -> Void)? = nil) {
        setMotorPattern(motors: [[75,0,75,0],
                                 [0,225,0,0]], motorRunTime: 0.5) {
            completion?()
        }
    }
    
    func runFearful(completion: (() -> Void)? = nil) {
        setMotorPattern(motors: [[175,0,0,0],
                                 [0,50,0,0],
                                 [0,0,175,0],
                                 [0,0,0,50]], motorRunTime: 0.25) {
            completion?()
        }
    }
    
    func runDisgust(completion: (() -> Void)? = nil) {
        setMotorPattern(motors: [[0,100,100,0]], motorRunTime: 1) {
            completion?()
        }
    }
    
    func runAngry(completion: (() -> Void)? = nil) {
        setMotorPattern(motors: [[255,0,0,255]], motorRunTime: 0.75) {
            completion?()
        }
    }
    
    func runNeutral(completion: (() -> Void)? = nil) {
        setMotorPattern(motors: [[30,30,30,30]], motorRunTime: 1) {
            completion?()
        }
    }
    
    func setMotorPattern(motors: [[UInt8]], motorRunTime seconds: Double, completion: @escaping () -> Void) {
        buzzDevice?.clearMotorsQueue()
        var motorIndex = 0
        Timer.scheduledTimer(withTimeInterval: seconds, repeats: true) { t in
            self.buzzDevice?.stopMotors()
            self.buzzDevice?.setMotorVibration(motors[motorIndex][0],
                                               motors[motorIndex][1],
                                               motors[motorIndex][2],
                                               motors[motorIndex][3])
            
            motorIndex += 1
            if motorIndex == motors.count {
                t.invalidate()
                Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
                    self.buzzDevice?.stopMotors()
                    completion()
                }
            }
        }
    }
    
    func runEmotion(emotionName: Emotion) {
        switch emotionName {
        case .Angry:
            self.runAngry() {
                self.repeatEmotionBuzz(emotionName: emotionName)
            }
        case .Disgust:
            self.runDisgust() {
                self.repeatEmotionBuzz(emotionName: emotionName)
            }
        case .Fearful:
            self.runFearful() {
                self.repeatEmotionBuzz(emotionName: emotionName)
            }
        case .Happy:
            self.runHappy() {
                self.repeatEmotionBuzz(emotionName: emotionName)
            }
        case .Neutral:
            self.runNeutral() {
                self.repeatEmotionBuzz(emotionName: emotionName)
            }
        case .Sad:
            self.runSad() {
                self.repeatEmotionBuzz(emotionName: emotionName)
            }
        case .Surprise:
            self.runSurprised() {
                self.repeatEmotionBuzz(emotionName: emotionName)
            }
        default:
            fatalError("no index category available")
        }
    }
    
    func buzz10Times(emotionName: Emotion) {
        runCount = 0
        runEmotion(emotionName: emotionName)
    }
    
    func repeatEmotionBuzz(emotionName: Emotion) {
        self.runCount += 1
        if runCount < 10 {
            self.runEmotion(emotionName: emotionName)
        } else {
            delegate?.buzzFinished()
        }
    }
}
