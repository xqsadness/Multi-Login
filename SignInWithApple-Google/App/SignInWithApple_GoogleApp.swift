//
//  SignInWithApple_GoogleApp.swift
//  SignInWithApple-Google
//
//  Created by xqsadness on 30/05/2024.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct SignInWithApple_GoogleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return false}
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
                
        GIDSignIn.sharedInstance.configuration = config
        return true
    }
    
    //Phone auth needs to init remote notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult{
        return .noData
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
}
