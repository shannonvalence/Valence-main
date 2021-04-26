//
//  AudioRecorder.swift
//  Valence
//
//  Created by Pavel Holyavkin on 4/12/21.
//

import AVFoundation

public typealias AudioRecorderDeviceNameHandler = (_ deviceName: String) -> Void

class AudioRecorder {

    private let session: AVCaptureSession

    private var currentCaptureInput: AVCaptureDeviceInput!

    private var connectedObserver: NSObjectProtocol?
    private var disconnectedObserver: NSObjectProtocol?

    private var currentDeviceName: String?
    
    var audioRecorderDeviceNameHandler: AudioRecorderDeviceNameHandler? {
        didSet {
            currentDeviceName.map { audioRecorderDeviceNameHandler?($0) }
        }
    }
    
    init(_ captureSession: AVCaptureSession) {
        self.session = captureSession
        
        self.connectedObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureDeviceWasConnected, object: nil, queue: OperationQueue.main) { [weak self] notification in
            if let audioCaptureDevice = notification.object as? AVCaptureDevice {
                self?.updateCurrentDeviceInfo(with: audioCaptureDevice)
            }
        }
        
        self.disconnectedObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureDeviceWasDisconnected, object: nil, queue: OperationQueue.main) { [weak self] _ in
            if let audioCaptureDevice = AVCaptureDevice.default(for: AVMediaType.audio) {
                self?.updateCurrentDeviceInfo(with: audioCaptureDevice)
            }
        }
    }

    func setupRecordingSession() throws {
        if self.currentCaptureInput == nil {
            
            if #available(OSX 10.14, *) {
                let microPhoneStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
                
                if microPhoneStatus == .denied || microPhoneStatus == .restricted {
                    return
                }
            }
            
            guard let audioCaptureDevice = AVCaptureDevice.default(for: AVMediaType.audio) else {
                return
            }
            
            self.updateCurrentDeviceInfo(with: audioCaptureDevice)
            
            let audioInput = try AVCaptureDeviceInput(device: audioCaptureDevice)
            self.currentCaptureInput = audioInput
            
            if self.session.canAddInput(audioInput) {
                self.session.addInput(audioInput)
            }
        }
    }
    
    private func updateCurrentDeviceInfo(with device: AVCaptureDevice) {
        currentDeviceName = device.localizedName
        audioRecorderDeviceNameHandler?(device.localizedName)
    }
}
