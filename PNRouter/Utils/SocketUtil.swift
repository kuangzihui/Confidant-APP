//
//  SocketUtil.swift
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/4.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

import UIKit
//import Starscream

class SocketUtil: NSObject {
    
    static var shareInstance:SocketUtil {
        struct MyStatic {
            static var instance:SocketUtil = SocketUtil()
        }
        return MyStatic.instance;
    }
    
    var socket:WebSocket? = nil
//    public var onText: ((String) -> Void)?
//    public var onData: ((Data) -> Void)?
    public var onConnect: (() -> Void)?
    public var onDisconnect: ((Error?) -> Void)?
    public var connectStatus:Int = socketConnectStatusNone
    
    func connect(url:String) {
        
        print("connecturl  = \(url)")
        weak var weakSelf = self
        socket = WebSocket(url: URL(string: url)!, protocols: ["lws-minimal"])
        socket!.disableSSLCertValidation = true
        //websocketDidConnect
        socket!.onConnect = {
            weakSelf?.connectStatus = socketConnectStatusConnected
            print("websocket is connected")
            let socketUtil = SocketCountUtil.getShareObject()
            socketUtil?.reConnectCount = 0;
            NotificationCenter.default.post(name: Notification.Name(rawValue: SOCKET_ON_CONNECT_NOTI), object: url)
        }
        //websocketDidDisconnect
        socket!.onDisconnect = { (error: Error?) in
            weakSelf?.connectStatus = socketConnectStatusDisconnected
            print("websocket is disconnected: \(String(describing: error?.localizedDescription))")
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: SOCKET_ON_DISCONNECT_NOTI), object:url)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue:SOCKET_DISCONNECT_NOTI), object:url)
            
        }
        //websocketDidReceiveMessage
        socket!.onText = { (text: String) in
            
            SocketMessageUtil.receiveText(text)
        }
        //websocketDidReceiveData
        socket!.onData = { (data: Data) in
            print("receive data: \(data.count)")
        }
        //you could do onPong as well.
        connectStatus = socketConnectStatusConnecting
        socket!.connect()
    }
    
    func disconnect() {
        connectStatus = socketConnectStatusDisconnecting
        socket?.disconnect()
    }
    
    func send(text:String) {
        socket?.write(string: text, completion: {
            print("send text:\(text)")
        })
    }
    
    func send(data:Data) {
        socket?.write(data: data, completion: {
            print("send data:\(data.count)")
        })
    }
    
    func getSocketConnectStatus() -> Int {
        return connectStatus
    }
    
}
