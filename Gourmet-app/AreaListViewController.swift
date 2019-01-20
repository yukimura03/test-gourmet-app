//
//  ViewController.swift
//  test-gourmet-app
//
//  Created by minagi on 2018/12/26.
//  Copyright © 2018 minagi. All rights reserved.
//

import UIKit
import Foundation

class AreaListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let areaListModel = AreaListModel()
    let getApiModel = GetApiModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    
        /// NavigationBarのボタンの設定。店舗一覧画面で「＜」だけ表示するように設定
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        
        areaListModel.getAreaNameAndCode()
    }
    
    /// テーブルビューを再読み込みしてデータを表示する
    func reloadData() {
        self.tableView.reloadData()
    }
    
    // cellの数はエリア名の数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areaListModel.areaInTokyo.count
    }
    
    // cellにエリア名を表示する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AreaCell", for: indexPath)
        cell.textLabel?.text = areaListModel.areaInTokyo[indexPath.row].areaname_l
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // タップしたセルの「エリア名」「エリアコード」を次の画面に渡す
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let storeInfoView = segue.destination as! StoreInfoViewController
                getApiModel.areaname = areaListModel.areaInTokyo[indexPath.row].areaname_l
                getApiModel.areacode = areaListModel.areaInTokyo[indexPath.row].areacode_l
            }
        }
    }
    
    // 前の画面から戻ってきたら、セルのハイライトが消える
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
}

