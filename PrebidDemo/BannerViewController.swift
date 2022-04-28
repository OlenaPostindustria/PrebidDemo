//
//  ViewController.swift
//  PrebidDemo
//
//  Created by Olena Stepaniuk on 27.04.2022.
//

import UIKit
import PrebidMobile
import GoogleMobileAds

class BannerViewController: UIViewController {

    @IBOutlet weak var adView: UIView!
    
    var adServer: AdServer = .Rubicon
    
    var bannerAdUnit: BannerAdUnit!
    
    var gamBanner: GAMBannerView!
    
    let defaultBannerSize = CGSize(width: 320, height: 50)
    let rubiconBannerSize = CGSize(width: 300, height: 250)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch adServer {
        case .Rubicon:
            setupRubiconServer(storedResponse: "1001-rubicon-300x250")
            setupBannerAdUnit(configId: "1001-1", size: rubiconBannerSize)
            loadGAMBanner(with: "/5300653/pavliuchyk_test_adunit_1x1_puc", gadSize: kGADAdSizeMediumRectangle)
        case .PrebidAWS:
            setupPrebidServerAWS(storedResponse: "response-prebid-banner-320-50")
            setupBannerAdUnit(configId: "imp-prebid-banner-320-50", size: defaultBannerSize)
            loadGAMBanner(with: "/21808260008/prebid_demo_app_original_api_banner", gadSize: kGADAdSizeBanner)
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
    
    func setupBannerAdUnit(configId: String, size: CGSize) {
        bannerAdUnit = BannerAdUnit(configId: configId, size: size)
    }
    
    func loadGAMBanner(with adUnitId: String, gadSize: GADAdSize) {
        print("Google Mobile Ads SDK version: \(GADMobileAds.sharedInstance().sdkVersion)")
        
        gamBanner = GAMBannerView(adSize: gadSize)
        gamBanner.adUnitID = adUnitId
        gamBanner.rootViewController = self
        gamBanner.delegate = self
        gamBanner.backgroundColor = .red
        
        adView.addSubview(gamBanner)
        
        let gamRequest = GAMRequest()
        
        bannerAdUnit.fetchDemand(adObject: gamRequest) { [weak self] result in
            print("Prebid fetch demand result: \(result.name())")
            self?.gamBanner.load(gamRequest)
        }
    }
}

extension BannerViewController: GADBannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner view did receive ad")
        
        AdViewUtils.findPrebidCreativeSize(bannerView) { size in
            guard let bannerView = bannerView as? GAMBannerView else {
                return
            }
            
            bannerView.resize(GADAdSizeFromCGSize(size))
        } failure: { error in
            print("Failed to find Prebid size: \(error.localizedDescription)")
        }
        
        adView.constraints.first { $0.firstAttribute == .width }?.constant = bannerView.adSize.size.width
        adView.constraints.first { $0.firstAttribute == .height }?.constant = bannerView.adSize.size.height
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("Banner view did fail to receive ad with error: \(error.localizedDescription)")
    }
}
