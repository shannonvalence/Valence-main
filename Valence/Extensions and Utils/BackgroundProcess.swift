//
//  BackgroundProcess.swift
//  Valence
//
//  Created by Matthew Kaulfers on 1/31/21.
//

import AVFoundation

let sharedAudioProcess = AudioProcess()

class AudioProcess {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    init() {
        
    }
}
