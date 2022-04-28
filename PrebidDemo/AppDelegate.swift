//
//  AppDelegate.swift
//  PrebidDemo
//
//  Created by Olena Stepaniuk on 27.04.2022.
//

import UIKit
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        
        GADMobileAds.sharedInstance().start()
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =  [
            (kGADSimulatorID as! String),
            "52d4d5ffadb16a2847a957764f98f10c3270e207",
            deviceId
        ]
        return true
    }

}

