//
//  MainViewModel.swift
//  Valence
//
//  Created by Pavel Holyavkin on 4/12/21.
//

import Foundation
import Combine

class RecognizeModel: ObservableObject {

    @Published var prediction: (categoryIndex: Int, categoryTitle: String, percentage: Int) = (0, "", 0)
    var microphoneReader = MicrophoneReader()
    let soundRecognizerEngine = SoundRecognizerEngine(sampleRate: 44100, windowLength: 132300)
    
    func setup() {
        
//        let operationQueue = OperationQueue()
//        operationQueue.maxConcurrentOperationCount = 1

        microphoneReader.startReading { [weak self] samples in
            guard let `self` = self else { return }
            
//            operationQueue.waitUntilAllOperationsAreFinished()
//            operationQueue.addOperation {
                if let result = self.soundRecognizerEngine.predict(samples: samples) {
//                    if result.0 > 0.4
//                    {
                        DispatchQueue.main.async {
                            self.prediction = (result.category, result.title, Int(round(result.percentage * 100)))
                        }
                    }
//                }
//            }
        }
    }
    
    func stopRecognizing() {
        microphoneReader.stopReading()
    }
}
