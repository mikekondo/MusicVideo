//
//  MusicSelectViewController.swift
//  tictok_mikever
//
//  Created by 近藤米功 on 2021/08/18.
//

import UIKit
import SDWebImage
import AVFoundation
import SwiftVideoGenerator
class MusicSelectViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate, MusicProtocol{
    var musicModel = MusicModel()
    var player:AVAudioPlayer?
    var musicURL:URL?
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ナビゲーションバーを隠す
        self.navigationController?.isNavigationBarHidden = true
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicModel.artistNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let artWorkImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let musicNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        let artistNameLabel = cell.contentView.viewWithTag(3) as! UILabel
        //写真、音楽名、アーティスト名の格納
        artWorkImageView.sd_setImage(with: URL(string: musicModel.artworkUrl100Array[indexPath.row]), completed: nil)
        musicNameLabel.text = musicModel.trackCensoredNameArray[indexPath.row]
        artistNameLabel.text = musicModel.artistNameArray[indexPath.row]
        //楽曲再生ボタンの作成
        let musicPlayButton = UIButton(frame: CGRect(x: 37, y: 15, width: 70, height: 70))
        musicPlayButton.setImage(UIImage(named:"play"), for: .normal)
        //ボタンを押したとき
        musicPlayButton.addTarget(self, action: #selector(playButtonTap(_:)), for:.touchUpInside)
        musicPlayButton.tag = indexPath.row
        //セルにmusicButtonを追加(StoryBoardにないから)
        cell.contentView.addSubview(musicPlayButton)
        //favButton作成
        let favButton = UIButton(frame: CGRect(x: 302, y: 50, width: 70, height: 70))
        favButton.setImage(UIImage(named:"fav"), for: .normal)
        //ボタンを押したとき
        favButton.addTarget(self, action: #selector(favButtonTap(_:)), for:.touchUpInside)
        favButton.tag = indexPath.row
        //セルにmusicButtonを追加(StoryBoardにないから)
        cell.contentView.addSubview(favButton)
        return cell
    }
    //returnボタンを押した時のtextFieldの処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textFieldの値でJSON解析を行う
        refleshData()
        textField.resignFirstResponder()
        return true
    }
    //セルの高さを返す
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    func catchData(count: Int) {
        if count == 1{
            tableView.reloadData()
        }
    }
    @objc func playButtonTap(_ sender:UIButton){
        //音楽を止める
        if player?.isPlaying == true{
            player?.stop()
        }
        //sender.tagはindexPath.rowすなわちplayButton.tagと一緒
        let url = URL(string: musicModel.previewUrlArray[sender.tag])
        downLoadMusicURL(url: url!)
    }
    @objc func favButtonTap(_ sender:UIButton){
        //音声が流れている時止める
        if player?.isPlaying == true{
            player?.stop()
        }
        //値を渡しながら画面遷移
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let CameraVC = storyboard.instantiateViewController(withIdentifier: "CameraVC") as! CameraViewController
        //sender.tagを用いて、musicURLを取得
        musicURL = URL(string: self.musicModel.previewUrlArray[sender.tag])!
        //CameraViewControllerにmusicURLを渡す
        CameraVC.cameraMusicURL = musicURL
        //CameraViewControllerに画面遷移
        self.navigationController?.pushViewController(CameraVC, animated: true)
    }
    //ダウンロードメソッド
    func downLoadMusicURL(url:URL){
      var downloadTask:URLSessionDownloadTask
      downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (url, response, error) in
        self.play(url: url!)
      })
      downloadTask.resume()
    }
    //音楽再生メソッド
    func play(url:URL){
      do {
        player = try AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.volume = 1.0
        player?.play()
      } catch let error as NSError {
        print(error.description)
      }
    }
    //iTunesAPIのJSON解析
    func refleshData(){
        //テキストフィールドの中にアーティスト名が入ってたらアーティスト名を用いてitunesAPIを用いる
        if textField.text?.isEmpty != nil{
            let urlString = "https://itunes.apple.com/search?term=\(String(describing:textField.text!))&entity=song&contry=jp"
            //urlStringをエンコードする
            let encodeUrlString:String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            //委任
            musicModel.musicDelegate = self
            musicModel.setData(resultCount: 50, encodeUrlString: encodeUrlString)
            //キーボードを閉じる
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        refleshData()
    }
}

