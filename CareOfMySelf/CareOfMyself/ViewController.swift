//
//  ViewController.swift
//  testSocket
//
//  Created by gaof on 2018/12/20.
//  Copyright © 2018 gaof. All rights reserved.
//

import UIKit
import SocketIO
import Alamofire
import Moya
import SwiftyJSON
import SVProgressHUD
enum StatusButtonType {
    case unused
    case connected
    case disconnect
}
class StatusButton:UIButton {
    var status:StatusButtonType = .unused
}

class ViewController: UIViewController {
    var dataSource = [JSON]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusButton: StatusButton!

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var replyLabel: UILabel!
    
    @IBOutlet weak var sendTextField: UITextField!
    @IBOutlet weak var sendSidLabel: UILabel!
    let manager = SocketManager(socketURL: URL(string: "http://192.168.0.21:5000")!, config: [.log(true), .compress, .connectParams(["device":"iOS"])])
    
    var socket:SocketIOClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        socket = manager.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.statusButton.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            self.statusButton.status = .connected
            self.getDevices()
        }
        socket.on(clientEvent: .error) { (data, ack) in
            print("error")
            self.statusButton.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            self.statusButton.status = .disconnect
        }
        socket.on(clientEvent: .disconnect) { (data, ack) in
            print("disconnect")
            self.statusButton.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
            self.statusButton.status = .disconnect
            self.getDevices()
        }
        
        socket.on("SEND_VIDEO_DATA") { (datas, ack) in
            let data = datas.first
            let json_data = JSON.init(data)
         
            guard let img_str = json_data.dictionaryValue["data"]?.string else { return }
            if let img_data = Data(base64Encoded: img_str) {
                let image   = UIImage(data: img_data)
                self.previewImageView.image = image
            }
        }
        socket.on("chat") { (datas, ack) in
            let data = datas.first as! [String:String]
            self.replyLabel.text = data["text"]
        }
        
        socket.on("server_response") {data, ack in
            guard let cur = data[0] as? Double else { return }
            self.socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                self.socket.emit("update", ["amount": cur + 2.50])
            }
            ack.with("Got your currentAmount", "dude")
        }
        socket.connect()
    }


    @IBAction func videoSwitchValueChange(_ sender: UISwitch) {
        provider.request(.switchVideo(open: sender.isOn)) { (result) in
            switch result {
            case let .success(response):
                SVProgressHUD.showSuccess(withStatus: "切换成功")
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.errorDescription)
                
            }
        }
    }
    
    @IBAction func sendTextClick(_ sender: UIButton) {
        let sid = sendSidLabel.text
        let sendText = sendTextField.text
        socket.emit("chat", with: [["sid":sid,"text":sendText!]])
    }
    
    @IBAction func statusButtonClick(_ sender: StatusButton) {
        if socket.status == .connected {
            manager.disconnect()
        }else if socket.status == .disconnected {
            manager.connect()
        }else if socket.status == .notConnected{
            manager.connect()
        }
    }
    func getDevices() {
        provider.request(.devices) { (response) in
            switch response {
            case let .success(result):
                let datas = result.toJson()?.dictionaryValue["data"]?.arrayValue
                self.dataSource = datas!
                self.tableView.reloadData()
            case let .failure(error):
                print(error)
            }
            
        }
    }
    @IBAction func refreshDevices(_ sender: UIButton) {
        self.getDevices()
    }
    func requestVideoSwitch(open:Bool) {
        provider.request(.switchVideo(open: open)) { (result) in
            switch result {
            case let .success(response):
                print(response)
            case let .failure(error):
                print(error)
            }
        }
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = self.dataSource[indexPath.row].dictionaryValue["device"]?.stringValue
        cell?.detailTextLabel?.text = self.dataSource[indexPath.row].dictionaryValue["sid"]?.stringValue
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sid = self.dataSource[indexPath.row].dictionaryValue["sid"]?.stringValue
        self.sendSidLabel.text = sid
    }
}
