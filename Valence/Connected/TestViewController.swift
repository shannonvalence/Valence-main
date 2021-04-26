//
//  TestViewController.swift
//  Valence
//
//  Created by Pavel Holyavkin on 4/14/21.
//

import Foundation
import AVFoundation
import UIKit
import BuzzBLE
import Firebase

class TestViewController: UIViewController {
    
    @IBOutlet weak var overallScoreLbl: UILabel!
    @IBOutlet weak var happyButton: UIButton!
    @IBOutlet weak var sadButton: UIButton!
    @IBOutlet weak var surpriseButton: UIButton!
    @IBOutlet weak var fearfulButton: UIButton!
    @IBOutlet weak var disgustButton: UIButton!
    @IBOutlet weak var angryButton: UIButton!
    @IBOutlet weak var neutralButton: UIButton!
    
    var answerPopup: UILabel?
    var buzzManager: BuzzDeviceManager?
    var player: AVAudioPlayer?
    private var sounds: [String] = []
    private var storageRef: StorageReference?
    private var dbRef: DatabaseReference!
    private var emotionName: String = ""
    private var userAnswer: String = "0"
    private var totalAnswers: Int = 0
    private var correctAnswers: Int = 0
    private var overallScore: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSounds()
        dbRef = Database.database().reference()
        listenDb()
        happyButton.isHidden = true
        sadButton.isHidden = true
        surpriseButton.isHidden = true
        fearfulButton.isHidden = true
        disgustButton.isHidden = true
        angryButton.isHidden = true
        neutralButton.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopBuzz()
    }
    
    private func getSounds() {
        let storage = Storage.storage()
        storageRef = storage.reference()
        let soundsRef = storageRef?.child("TestAudio")
        soundsRef?.listAll { (result, error) in
            if let error = error {
                print(error)
                return
            }
            for sound in result.items {
//                print(sound.fullPath)
                self.sounds.append(sound.fullPath)
                self.storageRef?.child(sound.fullPath)
            }
        }
    }
    
    //MARK: - Button Tapped Controls

    @IBAction func playSoundTapped(_ sender: Any) {
        guard let randomSound = sounds.randomElement() else { return }
        let starsRef = storageRef?.child(randomSound)
        // Download in memory with a maximum allowed size of 1MB
        starsRef?.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                guard let data = data else { return }
                print("download random sound...")
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)
                    
                    self.player = try AVAudioPlayer(data: data)
                    guard let player = self.player else { return }
                    self.emotionName = randomSound.getEmotionName()
                    
                    player.play()
                    self.startBuzz()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.stopBuzz()
                    }
                    self.showButtons()
                    
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    private func showButtons() {
        happyButton.isHidden = false
        sadButton.isHidden = false
        surpriseButton.isHidden = false
        fearfulButton.isHidden = false
        disgustButton.isHidden = false
        angryButton.isHidden = false
        neutralButton.isHidden = false
    }
    
    private func startBuzz() {
        buzzManager?.buzz10Times(emotionName: Emotion(rawValue: emotionName)!)
    }
    
    private func stopBuzz() {
        buzzManager?.buzzDevice?.stopMotors()
    }
    
    @IBAction func happyTapped(_ sender: Any) {
        userAnswer = Emotion.Happy.rawValue
        showPopup()
    }
    
    @IBAction func sadTapped(_ sender: Any) {
        userAnswer = Emotion.Sad.rawValue
        showPopup()
    }
    
    @IBAction func surpriseTapped(_ sender: Any) {
        userAnswer = Emotion.Surprise.rawValue
        showPopup()
    }
    
    @IBAction func fearfulTapped(_ sender: Any) {
        userAnswer = Emotion.Fearful.rawValue
        showPopup()
    }
    
    @IBAction func disgustTapped(_ sender: Any) {
        userAnswer = Emotion.Disgust.rawValue
        showPopup()
    }
    
    @IBAction func angryTapped(_ sender: Any) {
        userAnswer = Emotion.Angry.rawValue
        showPopup()
    }
    
    @IBAction func neutralTapped(_ sender: Any) {
        userAnswer = Emotion.Neutral.rawValue
        showPopup()
    }
    
    // Popup
    
    private func showPopup() {
        let correct: Bool
        if emotionName == userAnswer {
            correct = true
        } else {
            correct = false
        }
        
        player?.stop()
        stopBuzz()
        saveToDb(isCorrect: correct)
        
        let view = UIWindow.main
        answerPopup = UILabel(frame: view.bounds)
        answerPopup?.backgroundColor = correct ? .green : .red
        answerPopup?.text = correct ? "Correct" : "Wrong"
        answerPopup?.textAlignment = .center
        answerPopup?.font = answerPopup?.font.withSize(50)
        answerPopup?.textColor = .white
        
        // show on screen
        view.addSubview(answerPopup!)
        
        // set the timer
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.dismissPopup), userInfo: nil, repeats: false)
    }
    
    @objc func dismissPopup(){
        if answerPopup != nil {
            answerPopup?.removeFromSuperview()
        }
    }
    
    private func saveToDb(isCorrect: Bool) {
        let deviceId = KeychainHelper.shared.getDeviceId()
        let sessionId = KeychainHelper.shared.getSessionId()
        
        calculateScore(isCorrect: isCorrect)
        
        let test = try? TestResult(timestamp: Date(),
                              correctAnswer: emotionName,
                              userAnswer: userAnswer,
                              isCorrect: isCorrect ? 1 : 0).asDictionary()
        let user = try? User(deviceId: deviceId,
                        correctAnswers: correctAnswers,
                        totalAnswers: totalAnswers,
                        overallScore: overallScore).asDictionary()
        dbRef.child("UserTests").child(deviceId).child(sessionId).child(Date().getDateInStringPT).setValue(test)
        dbRef.child("Users").child(deviceId).setValue(user)
    }
    
    private func listenDb() {
        let deviceId = KeychainHelper.shared.getDeviceId()
        dbRef.child("Users").child(deviceId).observe(DataEventType.value, with: { (snapshot) in
            let user = snapshot.value as? [String: Any] ?? [:]
            self.correctAnswers = user["correctAnswers"] as? Int ?? 0
            self.totalAnswers = user["totalAnswers"] as? Int ?? 0
            self.overallScore = user["overallScore"] as? Int ?? 0
            self.overallScoreLbl.text = "Overall Score: \(self.overallScore)%"
            print(self.overallScore)
        })
    }
        
    private func calculateScore(isCorrect: Bool) {
        totalAnswers += 1
        if isCorrect {
            correctAnswers += 1
        }
        let percentage = Double(correctAnswers) / Double(totalAnswers) * 100
        overallScoreLbl.text = "Overall Score: \(percentage)%"
        overallScore = Int(percentage)
    }
}

enum Emotion: String {
    case Angry
    case Disgust
    case Fearful
    case Happy
    case Neutral
    case Sad
    case Surprise
    case Silence
}

struct User: Codable {
    let deviceId: String
    let correctAnswers: Int
    let totalAnswers: Int
    let overallScore: Int
}

struct TestResult: Codable {
    let timestamp: Date
    let correctAnswer: String
    let userAnswer: String
    let isCorrect: Int
}
