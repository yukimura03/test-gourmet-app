//
//  GetApiModel.swift
//  Gourmet-app
//
//  Created by minagi on 2019/01/20.
//  Copyright © 2019 minagi. All rights reserved.
//

import UIKit

class GetApiModel {
    /// レストラン情報から必要な項目だけを抜き出す箱です
    struct apiData: Codable {
        let total_hit_count: Int
        let rest: [restaurantsData]
    }
    struct restaurantsData: Codable {
        let name: String
        let address: String
        let tel: String
        let budget: Int
        let access: Access
        let image_url: image
        
        struct Access: Codable {
            let station: String
            let walk: String
        }
        
        struct image: Codable {
            let shop_image1: String
        }
    }
    
    /// レストランデータを１店舗ずつ区切って入れる配列
    var restInfo = [restaurantsData]()
    /// 現在の状態
    /// 0=読み込み中　1=読み込み完了、2=再読み込み中
    var status = 0
    
    // URLを構成する項目
    /// 自分で発行したKey
    let id = "a6cababca853c93d265f18664e323093"
    /// １ページに載せる店舗数
    let hitPerPage = 50
    /// 何ページ目
    var offsetPage = 1
    /// 前の画面で選んだエリアのエリアコードを受け取る
    var areacode = ""
    /// 前の画面で選んだエリアの名前を受け取る
    var areaname = ""
    /// 選んだエリアの総件数を入れる
    var totalHitCount = 0
    
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "queue")
    
    /// レストランデータ一覧を取得
    func getRestData() {
        dispatchGroup.enter() // 処理始めます
        
        let url = URL(string: "https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=\(id)&areacode_l=\(areacode)&hit_per_page=\(hitPerPage)&offset_page=\(offsetPage)")!
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            // nilチェック
            guard let data = data, let urlResponse = urlResponse as? HTTPURLResponse else {
                // 通信エラーなどの場合
                return;
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(apiData.self, from: data)
                self.restInfo += response.rest
                self.totalHitCount = response.total_hit_count
                self.status = 1
                
                self.dispatchGroup.leave()
            } catch {
                print("error")
                return;
            }
        }
        // リクエストを実行
        task.resume()
    }
}
