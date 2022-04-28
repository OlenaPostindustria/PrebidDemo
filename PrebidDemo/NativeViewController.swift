//
//  NativeViewController.swift
//  PrebidDemo
//
//  Created by Olena Stepaniuk on 27.04.2022.
//

import Foundation
import PrebidMobile
import GoogleMobileAds

class NativeViewController: UIViewController {
    
    @IBOutlet weak var adView: UIView!
    
    var adServer: AdServer = .PrebidAWS
    
    var nativeAdView: NativeAdView?
    var nativeAdUnit: NativeRequest?
    var nativeAd: NativeAd?
    
    var gadAdLoader: GADAdLoader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createNativeInAppView()
        
        switch adServer {
        case .Rubicon:
            return
        case .PrebidAWS:
            setupPrebidServerAWS(storedResponse: "response-prebid-banner-native-styles")
            setupNativeAdUnit(with: "imp-prebid-banner-native-styles")
            loadGAMNative(with: "/21808260008/apollo_custom_template_native_ad_unit")
            return
        }
    }
    
    func setupPrebidServerAWS(storedResponse: String) {
        try? Prebid.shared.setCustomPrebidServer(url: "https://prebid-server-test-j.prebid.org/openrtb2/auction")
        Prebid.shared.prebidServerAccountId = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        Prebid.shared.storedAuctionResponse = storedResponse
    }
    
    func setupNativeAdUnit(with configId: String) {
        let image = NativeAssetImage(minimumWidth: 200, minimumHeight: 200, required: true)
        image.type = ImageAsset.Main
        
        let icon = NativeAssetImage(minimumWidth: 20, minimumHeight: 20, required: true)
        icon.type = ImageAsset.Icon
        
        let title = NativeAssetTitle(length: 90, required: true)
        let body = NativeAssetData(type: DataAsset.description, required: true)
        let cta = NativeAssetData(type: DataAsset.ctatext, required: true)
        let sponsored = NativeAssetData(type: DataAsset.sponsored, required: true)
        
        nativeAdUnit = NativeRequest(configId: configId, assets: [title, icon, image, sponsored, body, cta])
        
        nativeAdUnit?.context = ContextType.Social
        nativeAdUnit?.placementType = PlacementType.FeedContent
        nativeAdUnit?.contextSubType = ContextSubType.Social
        
        let eventTracker = NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image,EventTracking.js])
        nativeAdUnit?.eventtrackers = [eventTracker]
    }
    
    func loadGAMNative(with adUnitId: String) {
        let gamRequest = GAMRequest()
        
        nativeAdUnit?.fetchDemand(adObject: gamRequest, completion: { [weak self] result in
            guard let self = self else { return }
            print("Prebid fetch demand result: \(result.name())")
            
            self.gadAdLoader = GADAdLoader(adUnitID: adUnitId,
                                           rootViewController: self,
                                           adTypes: [.customNative],
                                           options: [])
            
            self.gadAdLoader?.delegate = self
            self.gadAdLoader?.load(gamRequest)
        })
    }
    
    func createNativeInAppView(){
        let adNib = UINib(nibName: "NativeAdView", bundle: Bundle(for: type(of: self)))
        let array = adNib.instantiate(withOwner: self, options: nil)
        if let nativeAdView = array.first as? NativeAdView {
            self.nativeAdView = nativeAdView
            nativeAdView.frame = CGRect(x: 0, y: 0,
                                        width: self.adView.frame.size.width,
                                        height: 150 + UIScreen.main.bounds.width * 400 / 600)
            adView.addSubview(nativeAdView)
        }
    }
    
    func renderNativeAd() {
        guard let nativeAd = nativeAd, let nativeAdView = nativeAdView else { return }

        nativeAdView.titleLabel.text = nativeAd.title
        nativeAdView.bodyLabel.text = nativeAd.text
        
        if let iconString = nativeAd.iconUrl, let iconURL = URL(string: iconString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: iconURL) {
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data) {
                            nativeAdView.iconImageView.image = image
                        }
                    }
                }
            }
        }
        
        if let imageString = nativeAd.imageUrl, let imageURL = URL(string: imageString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageURL) {
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data) {
                            nativeAdView.mainImageView.image = image
                        }
                    }
                }
            }
        }
        
        nativeAdView.callToActionButton.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.sponsoredLabel.text = nativeAd.sponsoredBy
        nativeAd.registerView(view: nativeAdView, clickableViews: [nativeAdView.callToActionButton])
    }
}

extension NativeViewController: GADAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("GAD Ad Loader did fail to receive ad with error: \(error.localizedDescription)")
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print("GAD Ad Loader did finish loading")
    }
}

extension NativeViewController: GADCustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        ["11934135"]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: customNativeAd)
    }
}

extension NativeViewController: NativeAdDelegate {
    func nativeAdLoaded(ad: NativeAd) {
        print("Prebid Ad was loaded")
        nativeAd = ad
        nativeAd?.delegate = self
        renderNativeAd()
    }
    
    func nativeAdNotFound() {
        print("Prebid native ad was not found")
    }
    
    func nativeAdNotValid() {
        print("Prebid native ad is not valid")
    }
}

extension NativeViewController: NativeAdEventDelegate {
    func adDidExpire(ad: NativeAd) {
        print("Prebid Ad did expire")
    }
    
    func adWasClicked(ad: NativeAd) {
        print("Prebid Ad was clicked")
    }
    
    func adDidLogImpression(ad: NativeAd) {
        print("Prebid Ad did log impression")
    }
}
