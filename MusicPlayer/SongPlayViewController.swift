//
//  SongPlayViewController.swift
//  MusicPlayer
//
//  Created by 李世文 on 2020/9/22.
//

import UIKit
import AVFoundation
import MediaPlayer

class SongPlayViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var singerNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songTotleTimeLabel: UILabel!
    @IBOutlet weak var songPlayTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    //歌單
    var songs: [Song]!
    //播放歌單
    var songsPlay: [Song]!
    //目前播放歌曲index
    var selectRow: Int!
    //隨機播放狀態
    var randomState = false
    //重複播放狀態
    var repeatStatus = "All"
    //播放器
    let player = AVPlayer()
    var playerItem: AVPlayerItem!
    //播放監測標記
    var timeObserverToken: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        //設定播放歌單
        songsPlay = songs
        //設定鎖定畫面＆控制中心元件操作
        setupRemoteTransportControls()
        //設定播放歌曲資訊
        setInfo()
        //播放
        player.play()
        addPeriodicTimeObserver()
        //設定鎖定畫面＆控制中心歌曲資訊
        setupNowPlaying()
        //notfication-歌曲播放結束通知
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { (_) in
            //判斷重複播放狀態
            if self.repeatStatus == "All"{
                self.changeSong(changeTyp: "nextSong")
            }else if self.repeatStatus == "One"{
                let playTime = CMTime(value: CMTimeValue(0), timescale: 1)
                self.player.seek(to: playTime)
                self.player.play()
            }else{
                //判斷是否為最後一首歌
                if self.selectRow != self.songs.count - 1{
                    self.changeSong(changeTyp: "nextSong")
                }else{
                    let playTime = CMTime(value: CMTimeValue(0), timescale: 1)
                    self.player.seek(to: playTime)
                    self.playButton.setImage(UIImage(systemName: "play"), for: .normal)
                }
            }
        }
    }
    
    //播放歌曲資訊設定
    func setInfo(){
        //設定View
        albumImageView.image = UIImage(named: songsPlay[selectRow].musicImageName)
        songNameLabel.text = songsPlay[selectRow].songName
        singerNameLabel.text = songsPlay[selectRow].singerName
        //設定播放器
        let fileURL = Bundle.main.url(forResource: songsPlay[selectRow].songName, withExtension: "mp3")!
        playerItem = AVPlayerItem(url: fileURL)
        player.replaceCurrentItem(with: playerItem)
        //設定歌曲時間相關Label
        let duration = playerItem.asset.duration
        let seconds = CMTimeGetSeconds(duration)
        songTotleTimeLabel.text = formatSongTime(totalSeconds: Int(seconds))
        songPlayTimeLabel.text = "00:00"
        //設定slider
        timeSlider.maximumValue = Float(seconds)
        timeSlider.value = 0
    }
    
    //時間格式轉換
    func formatSongTime(totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        var time: String!
        if minutes < 10{
            time = "0\(minutes):"
        }else{
            time = "\(minutes):"
        }
        if seconds < 10{
            time += "0\(seconds)"
        }else{
            time += "\(seconds)"
        }
        return time
    }
    
    //產生播放監測標記
    func addPeriodicTimeObserver(){
        //每0.1秒通知
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { (time) in
            //設定時間label以及slider
            self.songPlayTimeLabel.text = self.formatSongTime(totalSeconds: Int(time.seconds))
            self.timeSlider.setValue(Float(time.seconds), animated: true)
        })
    }
    
    //移除播放監測標記
    func removePerPeriodicTimeObserver(){
        if let timeObserverToken = timeObserverToken{
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    //播放、暫停
    @IBAction func playAndStop(_ sender: Any) {
        if player.timeControlStatus == .playing{
            //若目前播放中
            playButton.setImage(UIImage(systemName: "play"), for: .normal)
            player.pause()
            
        }else{
            //若目前沒在播
            playButton.setImage(UIImage(systemName: "pause"), for: .normal)
            player.play()
        }
        //設定鎖定畫面＆控制中心歌曲資訊
        setupNowPlaying()
    }
    
    //上一首、下一首
    @IBAction func changeSongPlay(_ sender: UIButton) {
        randomStateCheck()
        changeSong(changeTyp: sender.restorationIdentifier!)
        //設定鎖定畫面＆控制中心歌曲資訊
        setupNowPlaying()
    }
    
    //歌曲轉換
    func changeSong(changeTyp: String){
        //判斷上一首或下一首
        if changeTyp == "nextSong"{
            if selectRow == songs.count - 1{
                selectRow = 0
            }else{
                selectRow += 1
            }
        }else{
            if selectRow == 0{
                selectRow = songs.count - 1
            }else{
                selectRow -= 1
            }
        }
        playButton.setImage(UIImage(systemName: "pause"), for: .normal)
        setInfo()
        player.play()
    }
    
    //slider事件-按下
    @IBAction func sliderTouchDown(_ sender: UISlider) {
        if timeObserverToken != nil{
            removePerPeriodicTimeObserver()
        }
    }
    
    //slider事件-拉動
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let songPlayTime = sender.value
        songPlayTimeLabel.text = formatSongTime(totalSeconds: Int(songPlayTime))
    }
    
    //slider事件-放開inside
    @IBAction func sliderTouchUpInside(_ sender: UISlider) {
        sliderTouchUp(sender: sender)
    }
    
    //slider事件-放開outside
    @IBAction func sliderTouchUpOutside(_ sender: UISlider) {
        sliderTouchUp(sender: sender)
    }
    
    //調整歌曲播放的區段
    func sliderTouchUp(sender: UISlider){
        let playTime = CMTime(value: CMTimeValue(sender.value), timescale: 1)
        player.seek(to: playTime)
        //延遲0.5秒加TimeObserver，讓秒數顯示正確
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.addPeriodicTimeObserver()
            //設定鎖定畫面＆控制中心歌曲資訊
            self.setupNowPlaying()
        }
    }
    
    //隨機狀態切換
    @IBAction func randomChange(_ sender: UIButton) {
        if randomState == false{
            randomState = true
            sender.tintColor = UIColor.label
        }else{
            randomState = false
            sender.tintColor = UIColor.gray
        }
        randomStateCheck()
    }
    
    //判斷隨機狀態做歌單的處理
    func randomStateCheck() {
        if randomState{
            songsPlay = songs.shuffled()
        }else{
            songsPlay = songs
        }
        selectRow = songsPlay.firstIndex(where: { (song) -> Bool in
            song.songName == songNameLabel.text
        })
    }
    
    //重複播放狀態切換
    @IBAction func repeatStatusChange(_ sender: UIButton) {
        if repeatStatus == "All"{
            repeatStatus = "One"
            sender.setImage(UIImage(systemName: "repeat.1"), for: .normal)
        }else if repeatStatus == "One"{
            repeatStatus = "No"
            sender.setImage(UIImage(systemName: "repeat"), for: .normal)
            sender.tintColor = UIColor.gray
        }else{
            repeatStatus = "All"
            sender.tintColor = UIColor.label
        }
    }
    
    //設定鎖定畫面＆控制中心播放元件操作
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                self.player.play()
                playButton.setImage(UIImage(systemName: "pause"), for: .normal)
                setupNowPlaying()
                return .success
            }
            return .commandFailed
        }
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                self.player.pause()
                playButton.setImage(UIImage(systemName: "play"), for: .normal)
                setupNowPlaying()
                return .success
            }
            return .commandFailed
        }
        //下一首
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            randomStateCheck()
            changeSong(changeTyp: "nextSong")
            setupNowPlaying()
            return .success
        }
        //上一首
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            randomStateCheck()
            changeSong(changeTyp: "preSong")
            setupNowPlaying()
            return .success
        }
        
    }
    
    //設定鎖定畫面＆控制中心播放資訊
    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = songsPlay[selectRow].songName
        nowPlayingInfo[MPMediaItemPropertyArtist] = songsPlay[selectRow].singerName
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = songsPlay[selectRow].albumName
        if let image = UIImage(named: songsPlay[selectRow].musicImageName) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
                }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
