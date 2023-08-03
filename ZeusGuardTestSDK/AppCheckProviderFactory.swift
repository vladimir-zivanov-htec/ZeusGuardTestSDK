//
//  AppCheckProviderFactory.swift
//  ZeusGuard
//
//  Created by Vladimir Dinic on 5.12.22..
//

import Foundation
import FirebaseCore
import FirebaseAppCheck


class FirebaseAppChecker {
    
    static func initialize() {
        let providerFactory = FirebaseAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
//        FirebaseApp.configure()
////        let storage = Storage.storage()
//        let text = "ABCDEF"
//        if let data = text.data(using: .utf8) {
//            storage.reference(withPath: "SomeFile.txt").putData(data) { metaData, error in
//                print(error)
//            }
//        }
    }
    
    static func getTokenForHeaderRequests() {
        AppCheck.appCheck().token(forcingRefresh: false) { token, error in
            guard error == nil else {
                // Handle any errors if the token was not retrieved.
                print("Unable to retrieve App Check token: \(error!)")
                return
            }
            guard let token = token else {
                print("Unable to retrieve App Check token.")
                return
            }

            // Get the raw App Check token string.
            let tokenString = token.token

            // Include the App Check token with requests to your server.
            let url = URL(string: "https://yourbackend.example.com/yourApiEndpoint")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(tokenString, forHTTPHeaderField: "X-Firebase-AppCheck")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle response from your backend.
            }
            task.resume()
        }
    }
}

fileprivate class FirebaseAppCheckProviderFactory: NSObject, AppCheckProviderFactory {

    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if DEBUG
        let debugProvider = AppCheckDebugProvider(app: app)
        print("Debug token: \(debugProvider?.currentDebugToken() ?? "")")
//        if let debugProvider = debugProvider {
//            requestDebugToken(debugProvider: debugProvider)
//        }
        return debugProvider
        #endif

        if #available(iOS 14.0, *) {
            return AppAttestProvider(app: app)
        } else {
            return DeviceCheckProvider(app: app)
        }
    }

    private func requestDebugToken(debugProvider: AppCheckDebugProvider) {
        print("Debug token: \(debugProvider.currentDebugToken())")
        debugProvider.getToken { token, error in
            if let token = token {
                print("Debug FAC token: \(token.token), expiration date: \(token.expirationDate)")
            }

            if let error = error {
                print("Debug error: \(error)")
            }
        }
    }

}

