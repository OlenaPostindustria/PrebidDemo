//
//  InterstitialViewController.swift
//  PrebidDemo
//
//  Created by Olena Stepaniuk on 27.04.2022.
//

import UIKit
import PrebidMobile
import GoogleMobileAds

class InterstitialViewController: UIViewController {
    
    @IBOutlet weak var showButton: UIButton!
    
    var adServer: AdServer = .Rubicon
    var adFormat: DemoAdFormat = .banner
    
    var interstitialAdUnit: AdUnit!
    var interstitialAd: GAMInterstitialAd?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showButton.isEnabled = false
        
        switch adServer {
        case .Rubicon:
            switch adFormat {
            case .banner:
                setupRubiconServer(storedResponse: "1001-rubicon-300x250")
                setupInterstitialAdUnit(configId: "1001-1")
                loadGAMInterstitial(with: "/5300653/pavliuchyk_test_adunit_1x1_puc")
            case .video:
                setupRubiconServer(storedResponse: "sample_video_response")
                setupInterstitialAdUnit(configId: "1001-1")
                loadGAMInterstitial(with: "/5300653/test_adunit_vast_pavliuchyk")
            }
        case .PrebidAWS:
            switch adFormat {
            case .banner:
                setupPrebidServerAWS(storedResponse: "response-prebid-display-interstitial-320-480")
                setupInterstitialAdUnit(configId: "imp-prebid-display-interstitial-320-480")
                loadGAMInterstitial(with: "/21808260008/prebid-demo-app-original-api-display-interstitial")
            case .video:
                setupPrebidServerAWS(storedResponse: "response-prebid-video-interstitial-320-480")
                setupInterstitialAdUnit(configId: "imp-prebid-video-interstitial-320-480")
                loadGAMInterstitial(with: "/21808260008/prebid-demo-app-original-api-video-interstitial")
            }
        }
    }
    
    func setupRubiconServer(storedResponse: String) {
        Prebid.shared.prebidServerHost = .Rubicon
        Prebid.shared.prebidServerAccountId = "1001"
        Prebid.shared.storedAuctionResponse = storedResponse
    }
    
    func setupPrebidServerAWS(storedResponse: String) {
        try? Prebid.shared.setCustomPrebidServer(url: "https://prebid-server-test-j.prebid.org/openrtb2/auction")
        Prebid.shared.prebidServerAccountId = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        Prebid.shared.storedAuctionResponse = storedResponse
    }

    func setupInterstitialAdUnit(configId: String) {
        switch adFormat {
        case .banner:
            interstitialAdUnit = InterstitialAdUnit(configId: configId)
        case .video:
            let adUnit = VideoInterstitialAdUnit(configId: configId)
            let parameters = VideoParameters()
            parameters.mimes = ["video/mp4"]
            parameters.protocols = [Signals.Protocols.VAST_2_0]
            parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
            adUnit.parameters = parameters
            interstitialAdUnit = adUnit
        }
    }
    
    func loadGAMInterstitial(with adUnitId: String) {
        let gamRequest = GAMRequest()
        
        interstitialAdUnit.fetchDemand(adObject: gamRequest) { result in
            print("Prebid fetch demand result: \(result.name())")
            
            GAMInterstitialAd.load(withAdManagerAdUnitID: adUnitId, request: gamRequest) { [weak self] ad, error in
                if let error = error {
                    print("Error occurred while loading ad: \(error.localizedDescription)")
                    return
                }
                self?.showButton.isEnabled = true
                self?.interstitialAd = ad
            }
        }
    }
    
    @IBAction func showButtonClicked(_ sender: Any) {
        if let interstitialAd = interstitialAd {
            showButton.isHidden = true
            interstitialAd.present(fromRootViewController: self)
        }
    }
}
