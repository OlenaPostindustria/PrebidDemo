//
//  DemoTableViewController.swift
//  PrebidDemo
//
//  Created by Olena Stepaniuk on 27.04.2022.
//

import UIKit

enum AdServer: String {
    case Rubicon = "Rubicon Server"
    case PrebidAWS = "Prebid Server on AWS"
}

class DemoTableViewController: UITableViewController {
    
    let adFormatTypes = [
        "Banner",
        "Interstitial",
        "Video Interstitial",
        "Native"
    ]
    
    let adServers: [AdServer] = [.Rubicon, .PrebidAWS]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        title = "Prebid Demo"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if adServers[section] == .Rubicon {
            return adFormatTypes.count - 1
        }
        return adFormatTypes.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return adServers[section].rawValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adFormatCell") ?? UITableViewCell()
        cell.textLabel?.text = adFormatTypes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let adFormat = adFormatTypes[indexPath.row]
        
        switch adFormat {
        case "Banner":
            let bannerViewController = storyboard.instantiateViewController(withIdentifier: "bannerViewController") as! BannerViewController
            bannerViewController.adServer = adServers[indexPath.section]
            self.navigationController?.pushViewController(bannerViewController, animated: true)
        case "Interstitial":
            let interstitialViewController = storyboard.instantiateViewController(withIdentifier: "interstitialViewController") as! InterstitialViewController
            interstitialViewController.adServer = adServers[indexPath.section]
            interstitialViewController.adFormat = .banner
            self.navigationController?.pushViewController(interstitialViewController, animated: true)
            
        case "Video Interstitial":
            let interstitialViewController = storyboard.instantiateViewController(withIdentifier: "interstitialViewController") as! InterstitialViewController
            interstitialViewController.adServer = adServers[indexPath.section]
            interstitialViewController.adFormat = .video
            self.navigationController?.pushViewController(interstitialViewController, animated: true)
            
        case "Native":
            if adServers[indexPath.section] == .Rubicon {
                print("There is no working stored response for native for Rubicon server.")
                return
            }
            
            let nativeViewController = storyboard.instantiateViewController(withIdentifier: "nativeViewController") as! NativeViewController
            nativeViewController.adServer = adServers[indexPath.section]
            self.navigationController?.pushViewController(nativeViewController, animated: true)
        default:
            return
        }
    }
}
