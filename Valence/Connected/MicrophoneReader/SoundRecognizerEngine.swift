//
//  SoundRecognizerEngine.swift
//  Valence
//
//  Created by Pavel Holyavkin on 4/12/21.
//

import Foundation
import CoreML
import RosaKit

public class SoundRecognizerEngine {
    
    private var model: newModel
//    private var model: model_v5
    private var samplesCollection: [Double] = []

    let melBasis: [[Double]]
    let sampleRate: Int
    let windowLength: Int

    public init(sampleRate: Int, windowLength length: Int) {
        self.model = newModel()
//        self.model = model_v5()
        
        self.sampleRate = sampleRate
        self.melBasis = [Double].createMelFilter(sampleRate: sampleRate, FTTCount: 1024, melsCount: 20)
        self.windowLength = length
    }
    
    public func predict(samples: [Double]) -> (percentage: Double, category: Int, title: String)? {
        var predicatedResult: (Double, Int, String)? = nil
        
        let bunchSize = self.windowLength
        
        let remaidToAddSamples = bunchSize - (self.samplesCollection.count)
        samplesCollection.append(contentsOf: samples[0 ..< min(remaidToAddSamples, samples.count)])

        if (samplesCollection.count) >= bunchSize {
            let collectionToPredict = samplesCollection
            samplesCollection = [Double]()
            
            let spectrogram = collectionToPredict.stft(nFFT: 1024, hopLength: 512).map { $0.map { pow($0, 2.0) } }
            let melSpectrogram = self.melBasis.dot(matrix: spectrogram)
            
            let powerSpectrogram = melSpectrogram.normalizeAudioPowerArray()
            let filteredSpectrogram = powerSpectrogram//.map { $0[0..<161] }

            do {
                let mlArray = try MLMultiArray(shape: [NSNumber(value: 1), NSNumber(value: 216)], dataType: .double)
//                let mlArray = try MLMultiArray(shape: [NSNumber(value: 1), NSNumber(value: 20), NSNumber(value: 259), NSNumber(value: 1)], dataType: .double)
                
                let flatSpectrogram = filteredSpectrogram.flatMap { $0 }
//                for index in 0 ..< flatSpectrogram.count {
//                    mlArray[index] = NSNumber(value: flatSpectrogram[index])
//                }
                let input = newModelInput(dense_16_input: mlArray)
//                let input = model_v5Input(conv2d_3_input: mlArray)
                let options = MLPredictionOptions()
                options.usesCPUOnly = true
                let result = try model.prediction(input: input, options: options)
                
                var array = [Double]()
                for index in 0 ..< result.Identity.count {
                    array.append(result.Identity[index].doubleValue)
                }
                
                let maxPercentage = array.reduce(0) { max($0, $1) }
                
                let category = (array.firstIndex(of: maxPercentage) ?? -1)
                
                
                let secondPercentage = array.reduce(0) { $1 == maxPercentage ? $0 : max($0, $1) }
                let secondCategory = (array.firstIndex(of: secondPercentage) ?? -1)
                
                let categoryName = CategoryRepository.indexToCategoryMap[category] ?? "\(category)"
                let secondCategoryName = CategoryRepository.indexToCategoryMap[secondCategory] ?? "\(secondCategory)"
                
                if category >= 0 {
                    print("🤖 \(getDate()) 1st prediction: \(categoryName)(\(category)) \(Int(maxPercentage*100))%. 2nd: \(secondCategoryName)(\(secondCategory)) - \(Int(secondPercentage*100))%")
                } else {
                    fatalError("category is less than 0?")
                }
                
                predicatedResult = (maxPercentage, category, categoryName)
            }
            catch {
                print("SoundRecognizerEngine Error: \(error)")
            }
        }
        
        return predicatedResult
        
    }
    
    private func getDate() -> String {
        let time = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let stringDate = timeFormatter.string(from: time)
        return stringDate
    }
}
