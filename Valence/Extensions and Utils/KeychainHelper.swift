//
//  KeychainHelper.swift
//  Valence
//
//  Created by Pavel Holyavkin on 4/19/21.
//

import Foundation
import KeychainAccess

enum UserId: String {
    case deviceId
    case sessionId
    case overallScore
}

class KeychainHelper {
    static var shared = KeychainHelper()
    
    func getDeviceId() -> String {
        let keychain = Keychain()
        if let deviceId = keychain[UserId.deviceId.rawValue] {
            return deviceId
        } else {
            let newDeviceId = UUID().uuidString
            keychain[UserId.deviceId.rawValue] = newDeviceId
            NSLog(">>> Generated a new deviceId = \(newDeviceId)")
            return newDeviceId
        }
    }
    
    func setSessionId() {
        let keychain = Keychain()
        keychain[UserId.sessionId.rawValue] = UUID().uuidString
    }
    
    func getSessionId() -> String {
        let keychain = Keychain()
        return keychain[UserId.sessionId.rawValue]!
    }
}
