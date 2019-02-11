//
//  StoreInfoView.swift
//  test-gourmet-app
//
//  Created by minagi on 2018/12/27.
//  Copyright © 2018 minagi. All rights reserved.
//

import UIKit
import Reachability

final class RestaurantsInfoViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// レストラン情報をのせるテーブルビュー
    @IBOutlet weak var restInfoView: UITableView!
    
    let reachability = Reachability()!
    
    let getRestData = GetRestData()
    
    var areaname = ""
    var areacode = ""
    
    var alertTitle = ""
    var alertMessage = ""
    
    /// 現在のステータス
    var status: StatusType = .finish
    
    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        connectionCheck()
        
        status = .loading
        
        restInfoView.delegate = self
        restInfoView.dataSource = self
        
        // cellの最大の高さを設定
        self.restInfoView.estimatedRowHeight = 100
        self.restInfoView.rowHeight = UITableView.automaticDimension
        
        getRestData.areacodeL = areacode

        // URLを作成してデータを取得、decodeして配列に入れる
        getRestData.getRestDataFromGnaviAPI()
        
        getRestData.dispatchGroup.notify(queue: .main) {
            self.status = .finish
            self.navigationItem.title = "\(self.areaname)の飲食店 \(self.getRestData.totalHitCount.withComma)件"
            self.reloadData()
        }
        
        
    }
    
    /// テーブルビューを再読み込みする
    func reloadData() {
        self.restInfoView.reloadData()
    }
    
    /// アラートでエラーメッセージを表示させる
    func showAlert(){
        let alertController = UIAlertController(title: "エラー：\(alertTitle)", message: alertMessage, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { action in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// ネットに繋がっているか確認する
    func connectionCheck() {
        if reachability.connection == .none {
            alertTitle = "オフライン"
            alertMessage = "通信状況を確認してください"
            showAlert()
        }
    }
    
    // 選択したセルのハイライトを消す
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            restInfoView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    // 一番下まできたら次のページを読み込む
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 読み込み中は動かないように、処理終わりましたを受け取ってから動くようにする
        getRestData.dispatchGroup.notify(queue: .main) {
            // 一番下までたどり着いたら
            if self.restInfoView.contentOffset.y + self.restInfoView.frame.size.height > self.restInfoView.contentSize.height && self.restInfoView.isDragging {
                
                // 再読み込み中ステータスに変更
                self.status = .reloading
                
                // indicatorを表示するためにTableViewを更新する
                self.reloadData()
                
                // APIのアドレスを次のページに更新
                self.getRestData.offsetPage += 1
                
                //レストランデータを取得、更新
                self.getRestData.getRestDataFromGnaviAPI()
                
                // 処理終了を受け取ったらステータスを変え、TableViewを更新する
                self.getRestData.dispatchGroup.notify(queue: .main) {
                    self.status = .finish
                    self.reloadData()
                }
            }
        }
    }
    
    /* --- テーブルビューの要素--- */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch status {
        // ページを開いて読み込み中の時はloadingCellのみ表示
        case .loading:
            return 1
            
        // 読み込み完了時はレストラン情報のcellのみ表示
        case .finish:
            return 1
            
        // 一番下まで来て再読み込みする時はレストラン情報＋loadigCellの両方を表示する
        case .reloading:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SectionType(rawValue: section) {
        
        case .some(.contents):
            switch status {
            // 読み込み中の時はloadingCellを１つだけ表示する
            case .loading:
                return 1
            
            // 読み込み完了時は読み込んだレストラン数分のcellを表示する
            case .finish:
                return getRestData.restaurantsData.count
                
            // 再読み込み中は読み込んだレストラン数分のcellを表示する
            case .reloading:
                return getRestData.restaurantsData.count
            }
            
        case .some(.indicator):
            // 読み込み中のcellは常に一つだけ
            return 1
            
        case .none:
            fatalError("section数は３つ以上にはなりません。")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // エラー処理
        guard let section = SectionType(rawValue: indexPath.section) else {
            return tableView.dequeueReusableCell(withIdentifier: "Undefined Section", for: indexPath)
        }
        
        switch section {
        case .contents:
            if status == .loading {
                return self.setupIndicatorCell(indexPath: indexPath)
            } else {
                return self.setupContentsCell(indexPath: indexPath)
            }
            
        case .indicator:
            return self.setupIndicatorCell(indexPath: indexPath)
        }
    }
    
    /* --- cellを作る部分 --- */
    /// cellにindicatorを表示させる
    private func setupIndicatorCell(indexPath: IndexPath) -> UITableViewCell {
        let LoadingCell = restInfoView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
        
        LoadingCell.indicator.startAnimating() // indicatorを表示させる
        
        return LoadingCell
    }
    
    /// cellにレストラン情報を表示させる
    private func setupContentsCell(indexPath: IndexPath) -> UITableViewCell {
        // 1つ目のセクションの中身
        let cell = restInfoView.dequeueReusableCell(withIdentifier: "RestInfoCell", for: indexPath) as! RestInfoCell
        
        cell.setCell(model: getRestData.restaurantsData[indexPath.row])
        
        return cell
    }
    
}
