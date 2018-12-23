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
class ViewController: UIViewController {
    
    @IBOutlet weak var sendTF: UITextField!
    
    let manager = SocketManager(socketURL: URL(string: "http://localhost:5000")!, config: [.log(true), .compress])
    
    var socket:SocketIOClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = manager.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        socket.on(clientEvent: .error) { (data, ack) in
            print("error")
        }
        socket.on("SEND_MON_DATA") { (datas, ack) in
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
    func test() {
        Alamofire.request("https://httpbin.org/get").responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
    }
}

