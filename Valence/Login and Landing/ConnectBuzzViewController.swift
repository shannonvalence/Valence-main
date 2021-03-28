//
//  ConnectBuzzViewController.swift
//  Valence
//
//  Created by Matthew Kaulfers on 1/31/21.
//

import UIKit
import AVFoundation
import BuzzBLE
import FirebaseAuth

class ConnectBuzzViewController: UIViewController {
    //MARK: - Class Properties
    ///@IBOutlets
    @IBOutlet weak var informationLabel: UILabel!
    
    ///Custom Properties
    var audioPlayer : AVAudioPlayer!
    var audioRecorder : AVAudioRecorder!
    var buzzManager = BuzzDeviceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func connectTapped(_ sender: Any) {
        buzzManager.scan()
        NotificationCenter.default.addObserver(self, selector: #selector(self.connectionMade), name: NSNotification.Name(rawValue: "buzzConnected"), object: nil)
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            let sb = UIStoryboard(name: "Main", bundle: .main)
            let vc = sb.instantiateInitialViewController()
            
            if vc != nil {
                present(vc!, animated: true, completion: nil)
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc func connectionMade() {
        performSegue(withIdentifier: "toConnected", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nc = segue.destination as! UINavigationController
        let vc = nc.topViewController as! BuzzConnected
        vc.buzzManager = buzzManager
    }
}

//MARK: Audio Recording Extension.
extension ConnectBuzzViewController: AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    func playButtonClicked(sender : AnyObject){
        
        let dispatchQueue = DispatchQueue.global(qos: .background)
        dispatchQueue.async(execute: {
            
            if let data = NSData(contentsOfFile: self.audioFilePath())
            {
                do{
                    let session = AVAudioSession.sharedInstance()
                    
                    try session.setCategory(AVAudioSession.Category.playback)
                    try session.setActive(true)
                    
                    self.audioPlayer = try AVAudioPlayer(data: data as Data)
                    self.audioPlayer.delegate = self
                    self.audioPlayer.prepareToPlay()
                    self.audioPlayer.play()
                }
                catch{
                    print("\(error)")
                }
            }
        });
    }
    
    func stopRecording(sender : AnyObject){
        
        if let player = self.audioPlayer{
            player.stop()
        }
        
        if let record = self.audioRecorder{
            
            record.stop()
        }
        
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setActive(false)
        }
        catch{
            print("\(error)")
        }
    }
    
    func startRecording(){
        
        do{
            
            let fileURL = URL(string: self.audioFilePath())!
            self.audioRecorder = try AVAudioRecorder(url: fileURL, settings: self.audioRecorderSettings() as! [String : AnyObject])
            
            if let recorder = self.audioRecorder{
                recorder.delegate = self
                
                if recorder.record() && recorder.prepareToRecord(){
                    print("Audio recording started successfully")
                }
            }
        }
        catch{
            print("\(error)")
        }
    }
    
    func audioFilePath() -> String{
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let filePath = path.stringByAppendingPathComponent(path: "test.caf") as String
        return filePath
    }
    
    func audioRecorderSettings() -> NSDictionary{
        
        let settings = [AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)), AVSampleRateKey : NSNumber(value: Float(16000.0)), AVNumberOfChannelsKey : NSNumber(value: 1), AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]
        
        return settings as NSDictionary
    }
    
    //MARK: AVAudioPlayerDelegate methods
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        if flag == true{
            print("Player stops playing successfully")
        }
        else{
            print("Player interrupted")
        }
    }
    
    //MARK: AVAudioRecorderDelegate methods
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if flag == true{
            print("Recording stops successfully")
        }
        else{
            print("Stopping recording failed")
        }
    }
}
