//
//  AppCheckManager.swift
//  ZeusGuard
//
//  Created by Vladimir Dinic on 7.12.22..
//

import Foundation
import DeviceCheck

class AppCheckManager {
    
    static func generateToken() {
        if #available(iOS 11.0, *) {
            let device = DCDevice.current
            if device.isSupported {
                device.generateToken(completionHandler: { (data, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    guard let data = data else { return }
                    let token = data.base64EncodedString()
                    print("Token: \(token)")
                })
            } else {
                print("devicecheck not supported")
            }
        }
    }
    
}
