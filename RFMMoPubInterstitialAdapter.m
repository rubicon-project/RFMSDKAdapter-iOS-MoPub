//
//  RFMMoPubInterstitialAdapter.m
//
//  Integrated with RFM iOS SDK v 4.1.1
//  Integrated with MoPub iOS SDK : 3.4.0
//
//  Created by The Rubicon Project on 2/15/15.
//  Copyright (c) Rubicon Project. All rights reserved.

#import "RFMMoPubInterstitialAdapter.h"
#import <RFMAdSDK/RFMAdSDK.h>
#import "RFMMoPubAdapterConstants.h"

@interface RFMMoPubInterstitialAdapter ()<RFMAdDelegate>

@property (nonatomic, strong) RFMAdView *rfmAdView;
@property (nonatomic, assign) BOOL isReady;
@end

@implementation RFMMoPubInterstitialAdapter {
    UIViewController *_rootViewController;
}

#pragma mark - MPInerstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info;
{
    
    //Custom Event Dictionary Format:
    //{“rfm_app_id”:[Pass RFM App ID here],”rfm_pub_id”:[Pass RFM Pub ID Here],”rfm_server_name”:[RFM Server Name Here, must end in / ]}
    self.isReady = NO;
    if (!info ||
        !info[RFM_MOPUB_SERVER_KEY] ||
        !info[RFM_MOPUB_APP_ID_KEY] ||
        !info[RFM_MOPUB_PUB_ID_KEY]
        ){
        // [self reportAdFailureToMoPub:@"RFM Custom Event data missing"];
        return;
    }
    
    BOOL isIOS8 = RFM_MOPUB_ADP_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0");
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    if (!isIOS8) {
        frame.size.height = frame.size.width;
        frame.size.width = [UIScreen mainScreen].applicationFrame.size.height;
    }
    
    if (_rfmAdView == nil){
        _rfmAdView = [RFMAdView createInterstitialAdWithDelegate:self];
    }
    
    
    //Request parameter configuration
    RFMAdRequest *adRequest = [[RFMAdRequest alloc]
                               initRequestWithServer:info[RFM_MOPUB_SERVER_KEY]
                               andAppId:info[RFM_MOPUB_APP_ID_KEY]
                               andPubId:info[RFM_MOPUB_PUB_ID_KEY]];
    adRequest.rfmAdType = RFM_ADTYPE_INTERSTITIAL;
    
    
    /*----BEGIN OPTIONAL RFM TARGETING INFO -------*/
    //Uncomment all the targeting information that needs to be passed on to RFM
    
    //Optional Targeting info
    NSMutableDictionary *targetingInfo = [[NSMutableDictionary alloc] init];
    targetingInfo[RFM_ADAPTER_VER_KEY] = RFM_MOPUB_ADAPTER_VER;
    //Add your own K-Vs for RFM targeting.
    
    if (info.count > 3) {
        //extract targeting info from custom event
        
        [info enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (obj &&
                ![key isEqualToString:RFM_MOPUB_SERVER_KEY] &&
                ![key isEqualToString:RFM_MOPUB_APP_ID_KEY] &&
                ![key isEqualToString:RFM_MOPUB_PUB_ID_KEY]){
                targetingInfo[key] = obj;
            }
        }];
    }
    
    adRequest.targetingInfo = targetingInfo;
    
    
    CLLocation *location = self.delegate ? self.delegate.location : nil;
    if (location){
        adRequest.locationLatitude = location.coordinate.latitude;
        adRequest.locationLongitude = location.coordinate.longitude;
    }
    
    //
    //
    //  //These optional parameters allow set additional adview configuration parameters
    //
    //  //When the ad is in landing view mode, set the transparency with which
    //  //your background application is visible along the edges and corners of the landing
    //  //view. The default value for this setting is 0.6.
    //  adRequest.landingViewAlpha = 0.6;
    
    
    //
    //  //This optional parameter only renders a specific ad.
    //  //This setting should only be implemented for test accounts
    //  //while testing the performance of a particular ad.
    //  //Return @"0" if you want this setting to be ignored by the SDK
    //      adRequest.rfmAdTestAdId = @"0";
    
    /*----END OPTIONAL RFM TARGETING INFO -------*/
    
    if(![_rfmAdView requestFreshAdWithRequestParams:adRequest]){
        // [self reportAdFailureToMoPub:@"RFM Request Denied"];
    }
    
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    // Note: Set this to YES if you wish to enable MoPub's
    // automatic impression and click tracking
    return NO;
}


-(void)dealloc{
    if (_rfmAdView) {
        _rfmAdView.delegate = nil;
    }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    _rootViewController = rootViewController;
    _rootViewController.navigationController.navigationBarHidden = YES;
    if (self.rfmAdView && self.isReady) {
        [self.delegate interstitialCustomEventWillAppear:self];
        [rootViewController.view addSubview:self.rfmAdView];
        [self.delegate interstitialCustomEventDidAppear:self];
    } else {
        [self reportAdFailureToMoPub:@"RFM interstitial not ready"];
    }
}

#pragma mark - RFM Ad Delegate Methods
-(UIView *)rfmAdSuperView{
    return self.rfmAdView.superview;
}

-(UIViewController *)viewControllerForRFMModalView{
    
    return [self parentViewControllerOfView:self.rfmAdView.superview];
}

- (UIViewController *)parentViewControllerOfView:(UIView*)view {
    UIResponder *responder = view;
    while (![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
        if (nil == responder) {
            break;
        }
    }
    return (UIViewController *)responder;
}

- (void)didRequestAd:(RFMAdView *)adView withUrl:(NSString *)requestUrlString{
    
}

- (void)didReceiveAd:(RFMAdView *)adView {
    if(self.rfmAdView.shouldPrecache) {
        self.isReady = NO;
        if(self.rfmAdView.canDisplayCachedAd){
            [self.rfmAdView showCachedAd];
        }
    } else {
        self.isReady = YES;
        if (self.delegate) {
            
            if (![self enableAutomaticImpressionAndClickTracking]) {
                [self.delegate trackImpression];
            }
            
            [self.delegate interstitialCustomEvent:self
                                         didLoadAd:adView];
        }
    }
}

-(void)didDisplayAd:(RFMAdView *)adView{
    self.isReady = YES;
    if (self.delegate) {
        if (![self enableAutomaticImpressionAndClickTracking]) {
            [self.delegate trackImpression];
        }
        [self.delegate interstitialCustomEvent:self
                                     didLoadAd:adView];
    }
}

- (void)didFailToDisplayAd:(RFMAdView *)adView {
    [self reportAdFailureToMoPub:@"RFM didFailToDisplayAd"];
}

- (void)didFailToReceiveAd:(RFMAdView *)adView
                    reason:(NSString *)errorReason{
    
    [self reportAdFailureToMoPub:errorReason];
}

- (void)willPresentFullScreenModalFromAd:(RFMAdView *)adView{
    if (self.delegate){
        if (![self enableAutomaticImpressionAndClickTracking]) {
            [self.delegate trackClick];
        }
        
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    }
    
}

-(void) willDismissInterstitialFromAd:(RFMAdView *)adView{
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)didDismissInterstitial{
    _rootViewController.navigationController.navigationBarHidden = NO;
    [self.delegate interstitialCustomEventDidDisappear:self];
    self.rfmAdView = nil;
}

- (void)adViewDidStopLoadingAndEnteredBackground:(RFMAdView *)adView{
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

#pragma mark - Ad Failure

-(void)reportAdFailureToMoPub:(NSString *)failReason{
    self.isReady = NO;
    if (self.delegate) {
        
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(failReason, nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(failReason, nil),
                                   };
        NSError *error = [NSError errorWithDomain:@"com.rfm.mopub.adapter"
                                             code:-101
                                         userInfo:userInfo];
        
        [self.delegate interstitialCustomEvent:self
                      didFailToLoadAdWithError:error];
    }
}




@end