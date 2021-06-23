//
//  MicrophoneReader.swift
//  Valence
//
//  Created by Pavel Holyavkin on 4/12/21.
//

import AVFoundation

public typealias MicrophoneReaderHandler = (_ audioPowerBuffer: [Double], _ silenceDetected: Bool) -> Void

class MicrophoneReader {

    private static let kIntToDoubleScale: Double = 32768.0
    private let silenceThreshold: Float = -40

    private(set) var audioRecordingManager: AudioRecordingManager = AudioRecordingManager()
    
    func startReading(handler: @escaping MicrophoneReaderHandler) {
        let audioRecordingManager = AudioRecordingManager()
        self.audioRecordingManager = audioRecordingManager
        
        try? audioRecordingManager.setup() { (data, timestamp, timeScale, samplesCount, sampleRate, db) in
            let powers = data.withUnsafeBytes { rawPointer -> [Double] in
                rawPointer.bindMemory(to: Int16.self)
                    .map { Double($0)/Self.kIntToDoubleScale }
            }
//            print("sampleRate = \(sampleRate)") //44100
//            print("samplesCount = \(samplesCount)") //941 or 940
//            print("timeScale = \(timeScale)") //44100
//            print("powers.count = \(powers.count)") //samplesCount
            let silenceDetected = db < self.silenceThreshold
            handler(powers, silenceDetected)
        }
        
        audioRecordingManager.startRecording()
    }
    
    func stopReading() {
        audioRecordingManager.stopRecording()
    }
}
