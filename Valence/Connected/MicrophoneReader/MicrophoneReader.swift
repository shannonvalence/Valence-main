//
//  MicrophoneReader.swift
//  Valence
//
//  Created by Pavel Holyavkin on 4/12/21.
//

import AVFoundation

public typealias MicrophoneReaderHandler = (_ audioPowerBuffer: [Double]) -> Void

class MicrophoneReader {

    private static let kIntToDoubleScale: Double = 32768.0

    private(set) var audioRecordingManager: AudioRecordingManager = AudioRecordingManager()
    
    func startReading(handler: @escaping MicrophoneReaderHandler) {
        let audioRecordingManager = AudioRecordingManager()
        self.audioRecordingManager = audioRecordingManager
        
        try? audioRecordingManager.setup() { (data, timestamp, timeScale, samplesCount, sampleRate) in
            let powers = data.withUnsafeBytes { rawPointer -> [Double] in
                rawPointer.bindMemory(to: Int16.self)
                    .map { Double($0)/Self.kIntToDoubleScale }
            }
//            print("sampleRate = \(sampleRate)") //44100
//            print("samplesCount = \(samplesCount)") //941 or 940
//            print("timeScale = \(timeScale)") //44100
//            print("powers.count = \(powers.count)") //samplesCount
            handler(powers)
        }
        
        audioRecordingManager.startRecording()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            audioRecordingManager.stopRecording()
//        }
    }
    
    func stopReading() {
        audioRecordingManager.stopRecording()
    }
}
