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
class ViewController: UIViewController {
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var sendTF: UITextField!
    
    let manager = SocketManager(socketURL: URL(string: "http://localhost:5000")!, config: [.log(true), .compress, .connectParams(["device":"iOS"])])
    
    var socket:SocketIOClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = manager.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.statusView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            
        }
        socket.on(clientEvent: .error) { (data, ack) in
            print("error")
            self.statusView.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        }
        
        
        socket.on("SEND_VIDEO_DATA") { (datas, ack) in
            print(datas)
            
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        socket.connect()
//        test()
    }
    @IBAction func send(_ sender: UIButton) {
        let text = sendTF.text
        let data = ["data":text!]
       self.socket.emit("device", with: [data])
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

