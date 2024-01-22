//
//  ChefsApp.swift
//  Chefs
//
//  Created by Daniel Watson on 09.12.23.
// add binary with libraries

import SwiftUI
import Firebase

@main
struct ChefsApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var miseboxUser = MiseboxUserManager.MiseboxUser()
    @StateObject var chef = ChefManager.Chef()
    
    var body: some Scene {
        WindowGroup {
            Onboarding(vm: OnboardingViewModel(miseboxUser: miseboxUser, chef: chef))
            .environmentObject(miseboxUser)
            .environmentObject(chef)

        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
enum MiseboxError: Error {
    case selfIsNil
    case documentDoesNotExist
}
