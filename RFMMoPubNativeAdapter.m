//
//  RFMMoPubNativeAdapter.m
//  MoPub-RFM Sample
//
//  Created by Rubicon Project on 10/12/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import "RFMMoPubNativeAdapter.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdError.h"
#import "MPLogging.h"


@interface RFMMoPubNativeAdapter() <RFMNativeAdDelegate>

@property (nonatomic, strong) RFMNativeAd *nativeAd;
@property (nonatomic, strong) RFMNativeAdResponse *nativeAdResponse;
@property (nonatomic, strong) UIImageView *adChoicesView;
@property (nonatomic, strong) NSURL *adChoicesUrl;
@property (nonatomic, strong) UIView *mainMediaView;
@property (nonatomic, strong) NSURL *defaultClickUrl;

@end


@implementation RFMMoPubNativeAdapter

@synthesize properties = _properties;

- (instancetype)initWithRFMNativeAd:(RFMNativeAd *)nativeAd response:(RFMNativeAdResponse *)nativeAdResponse {
    self = [super init];
    if (self) {
        _nativeAd = nativeAd;
        _nativeAd.delegate = self;
        _nativeAdResponse = nativeAdResponse;
        
        _properties = [self convertAssetsToProperties:nativeAdResponse];
    }
    return self;
}

- (void)dealloc {
    _nativeAd.delegate = nil;
    _nativeAd = nil;
    _nativeAdResponse = nil;
    _delegate = nil;
}

- (NSDictionary *)convertAssetsToProperties:(RFMNativeAdResponse *)nativeAdResponse {
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    
    if (nativeAdResponse.link.url) {
        _defaultClickUrl = nativeAdResponse.link.url;
    }
    
    if (nativeAdResponse.assets.title.text) {
        [props setObject:nativeAdResponse.assets.title.text forKey:kAdTitleKey];
    }
    
    if (nativeAdResponse.assets.mainImage.imageUrl) {
        _mainMediaView = [[UIImageView alloc] initWithImage:nativeAdResponse.assets.mainImage.image];
        [props setObject:[nativeAdResponse.assets.mainImage.imageUrl absoluteString] forKey:kAdMainImageKey];
    }
    
    if (nativeAdResponse.assets.iconImage.imageUrl) {
        [props setObject:[nativeAdResponse.assets.iconImage.imageUrl absoluteString] forKey:kAdIconImageKey];
    }
    
    if (nativeAdResponse.assets.desc.value) {
        [props setObject:nativeAdResponse.assets.desc.value forKey:kAdTextKey];
    }
    
    if (nativeAdResponse.assets.rating.value) {
        [props setObject:nativeAdResponse.assets.rating.value forKey:kAdStarRatingKey];
    }

    if (nativeAdResponse.assets.ctaText.value) {
        [props setObject:nativeAdResponse.assets.ctaText.value forKey:kAdCTATextKey];
    }
    
    if (nativeAdResponse.assets.sponsored.value) {
        [props setObject:nativeAdResponse.assets.sponsored.value forKey:@"sponsored"];
    }
    
    if (nativeAdResponse.adChoices.image) {
        _adChoicesView = [[UIImageView alloc] initWithImage:nativeAdResponse.adChoices.image];
    }
    
    if (nativeAdResponse.adChoices.optOutUrl) {
        _adChoicesUrl = nativeAdResponse.adChoices.optOutUrl;
    }
    
    return [props copy];
}


#pragma mark - MPNativeAdAdapter

- (void)displayContentForURL:(NSURL *)URL rootViewController:(UIViewController *)controller {
    if (!controller) {
        return;
    }
    
    if (!URL || ![URL isKindOfClass:[NSURL class]] || ![URL.absoluteString length]) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:URL];
}

- (BOOL)enableThirdPartyClickTracking {
    return YES;
}

- (void)displayContentForDAAIconTap {
    [[UIApplication sharedApplication] openURL:_adChoicesUrl];
}

- (void)displayContentForNativeAdTap {
    [[UIApplication sharedApplication] openURL:self.defaultActionURL];
}

- (NSURL *)defaultActionURL {
    return _defaultClickUrl;
}

- (void)willAttachToView:(UIView *)view {
    [self.nativeAd registerViewForInteraction:view viewController:[self.delegate viewControllerForPresentingModalView]];
}

- (UIView *)privacyInformationIconView {
    return self.adChoicesView;
}

- (UIView *)mainMediaView {
    return _mainMediaView;
}

@end
