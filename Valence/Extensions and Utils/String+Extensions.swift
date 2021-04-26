//
//  String+Extensions.swift
//  Valence
//
//  Created by Pavel Holyavkin on 4/16/21.
//

import Foundation

extension String {
    func getEmotionName() -> String {
        let filename = URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
        let emotionName = filename.components(separatedBy: "_").first ?? Emotion.Silence.rawValue
        print(emotionName)
        return emotionName
    }
}
