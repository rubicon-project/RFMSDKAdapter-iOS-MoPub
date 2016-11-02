//
//  RFMMoPubNativeCustomEvent.m
//  MoPub-RFM Sample
//
//  Created by Rubicon Project on 10/12/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import "RFMMoPubNativeCustomEvent.h"
#import "RFMMoPubNativeAdapter.h"
#import <RFMAdSDK/RFMAdSDK.h>
#import "MPNativeAd.h"
#import "MPNativeAdError.h"
#import "MPLogging.h"
#import "MPNativeAdConstants.h"

@interface RFMMoPubNativeCustomEvent () <RFMNativeAdDelegate>

@property (nonatomic, readwrite, strong) RFMNativeAd *nativeAd;

@end

@implementation RFMMoPubNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info {
    NSString *rfmAppId = [info objectForKey:@"rfm_app_id"];
    NSString *rfmServerName = [info objectForKey:@"rfm_server_name"];
    NSString *rfmPubId = [info objectForKey:@"rfm_pub_id"];
    NSString *nativeSampleId = [info objectForKey:@"native-sample"];//Used for demo purposes only
    
    RFMAdRequest *adRequest = [[RFMAdRequest alloc] initRequestWithServer:rfmServerName andAppId:rfmAppId andPubId:rfmPubId];
    adRequest.rfmAdMode = nativeSampleId;
    _nativeAd = [[RFMNativeAd alloc] initWithDelegate:self];
    
    if (![_nativeAd requestCachedNativeAdWithParams:adRequest]) {
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(@"")];
    }
}


#pragma mark - RFMNativeAdDelegate

- (void)didRequestNativeAd:(RFMNativeAd *)nativeAd withUrl:(NSString *)requestUrlString {
    MPLogDebug(@"RFM native ad requested (adapter)");
}

- (void)didReceiveResponse:(RFMNativeAdResponse *)nativeResponse nativeAd:(RFMNativeAd *)nativeAd {
    RFMMoPubNativeAdapter *adAdapter = [[RFMMoPubNativeAdapter alloc] initWithRFMNativeAd:nativeAd response:nativeResponse];
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    
    NSMutableArray *imageURLs = [NSMutableArray array];
    
    if (nativeResponse.assets.iconImage.imageUrl) {
        [imageURLs addObject:nativeResponse.assets.iconImage.imageUrl];
    }
    
    if (nativeResponse.assets.mainImage.imageUrl) {
        [imageURLs addObject:nativeResponse.assets.mainImage.imageUrl];
    }
    
    [super precacheImagesWithURLs:imageURLs completionBlock:^(NSArray *errors) {
        if (errors) {
            MPLogDebug(@"%@", errors);
            [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForImageDownloadFailure()];
        } else {
            [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
        }
    }];
}

- (void)didFailToReceiveNativeAd:(RFMNativeAd *)nativeAd reason:(NSString *)errorReason {
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(errorReason)];
}

@end
