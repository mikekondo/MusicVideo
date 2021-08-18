//
//  MusicModel.swift
//  tictok_mikever
//
//  Created by 近藤米功 on 2021/08/18.
//

import Foundation
import SwiftyJSON
import Alamofire
protocol MusicProtocol {
    func catchData(count:Int)
}
class MusicModel{
    var artistNameArray = [String]()
    var trackCensoredNameArray = [String]()
    var previewUrlArray = [String]()
    var artworkUrl100Array = [String]()
    var musicDelegate:MusicProtocol?
    //JSON解析
    func setData(resultCount:Int,encodeUrlString:String){
        //Alamfireによる通信
        AF.request(encodeUrlString, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
            //responseの値表示
            print("response:",response)
            //一旦配列に入っているものすべてを削除する(蓄積防止)
            self.artistNameArray.removeAll()
            self.trackCensoredNameArray.removeAll()
            self.previewUrlArray.removeAll()
            self.artworkUrl100Array.removeAll()
            switch response.result{
            case .success:
                do {
                    let json:JSON = try JSON(data: response.data!)
                    for i in 0...resultCount-1{
                        //もしartistNameがnilだったら
                        if json["results"][i]["artistName"].string == nil{
                            print("ヒットしませんでした")
                            return
                        }
                        self.artistNameArray.append(json["results"][i]["artistName"].string!)
                        self.trackCensoredNameArray.append(json["results"][i]["trackCensoredName"].string!)
                        self.previewUrlArray.append(json["results"][i]["previewUrl"].string!)
                        self.artworkUrl100Array.append(json["results"][i]["artworkUrl100"].string!)
                    }
                    //全てのデータを取得している状態
                    self.musicDelegate?.catchData(count:1)
                } catch  {
                }
                break
            case .failure(_):break
            }
        }
    }
}
