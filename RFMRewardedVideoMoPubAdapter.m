//
//  RFMRewardedVideoMoPubAdapter.m
//
//  Created by Rubicon Project on 6/28/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import "RFMRewardedVideoMoPubAdapter.h"
#import "RFMMoPubAdapterConstants.h"
#import "MPRewardedVideoReward.h"
#import <RFMAdSDK/RFMRewardedVideo.h>
#import <RFMAdSDK/RFMAdSDK.h>

@class MPRewardedVideoReward;

// TODO: should we do this?
#define REWARDED_VIDEO_DEFAULT_ERROR -101
#define REWARDED_VIDEO_HAS_EXPIRED_ERROR -11

@interface RFMRewardedVideoMoPubAdapter() <RFMRewardedVideoDelegate>

@property (nonatomic, strong, readonly) RFMRewardedVideo *rewardedVideo;

@end

@implementation RFMRewardedVideoMoPubAdapter {
    RFMRewardedVideo *_rewardedVideo;
    RFMAdRequest *_adRequest;
    UIViewController *_presentingRewardedVideoViewController;
}

- (void)dealloc
{
    
}

#pragma mark - Properties

- (RFMRewardedVideo*)rewardedVideo
{
    if(!_rewardedVideo) {
        _rewardedVideo = [[RFMRewardedVideo alloc] initWithDelegate:self];
    }
    return _rewardedVideo;
}

#pragma mark - override MoPub custom event methods

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary*)info
{
    //Custom Event Dictionary Format:
    //{"rfm_app_id":[Pass RFM App ID here],"rfm_pub_id":[Pass RFM Pub ID Here],"rfm_server_name":[RFM Server Name Here, must end in / ]}
    if (!info ||
        !info[RFM_MOPUB_SERVER_KEY] ||
        !info[RFM_MOPUB_APP_ID_KEY] ||
        !info[RFM_MOPUB_PUB_ID_KEY]
        ){
        [self reportAdFailureToMoPub:@"RFM Custom Event data missing"];
        return;
    }
    
    //Request parameter configuration
    _adRequest = [[RFMAdRequest alloc]
                           initRequestWithServer:info[RFM_MOPUB_SERVER_KEY]
                           andAppId:info[RFM_MOPUB_APP_ID_KEY]
                           andPubId:info[RFM_MOPUB_PUB_ID_KEY]];
    
    
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
    
    _adRequest.targetingInfo = targetingInfo;
    _adRequest.rfmAdType = RFM_ADTYPE_INTERSTITIAL;
    _adRequest.fetchOnlyVideoAds = YES;
    
    
    BOOL success = [self.rewardedVideo requestCachedRewardedVideoWithParams:_adRequest];
    
    if(!success)
        [self reportAdFailureToMoPub:@"RFM ad request is invalid."];
}

- (BOOL)hasAdAvailable
{
    return [_rewardedVideo canDisplayRewardedVideo];
}

- (void)presentRewardedVideoFromViewController:(UIViewController*)viewController
{
    _presentingRewardedVideoViewController = viewController;
    _presentingRewardedVideoViewController.navigationController.navigationBarHidden = YES;
    [self.rewardedVideo showRewardedVideo];
}

// override
//- (void)handleAdPlayedForCustomEventNetwork
//{
//    
//}

//override
- (void)handleCustomEventInvalidated
{
    [_rewardedVideo invalidate];
    _rewardedVideo = nil;
}

#pragma mark - Error handling

- (NSError*)errorWithReason:(NSString*)errorReason code:(int)code
{
    NSParameterAssert(code);
    if(code == 0)
        return nil;
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(errorReason, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorReason, nil),
                               };
    NSError *error = [NSError errorWithDomain:@"com.rfm.mopub.adapter"
                                         code:code
                                     userInfo:userInfo];
    return error;
}

#pragma mark - Ad Failure

- (void)reportAdFailureToMoPub:(NSString*)errorReason {
    if (self.delegate) {
        NSError *error = [self errorWithReason:errorReason code:REWARDED_VIDEO_DEFAULT_ERROR];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
}


// TODO: implement delegate action
//-rewardedVideoDidReceiveTapEventForCustomEvent:

#pragma mark - RFMRewardedVideoDelegate methods

- (UIView *)rfmAdSuperView
{
    return _presentingRewardedVideoViewController.view;
}

- (UIViewController *)viewControllerForRFMModalView
{
    return _presentingRewardedVideoViewController;
}

- (void)didReceiveRewardedVideo:(RFMRewardedVideo *)rewardedVideo
{
    if([self hasAdAvailable]) {
        [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    } else {
        [self reportAdFailureToMoPub:@"Rewarded video precache failure."];
    }
}

- (void)didFailToReceiveRewardedVideo:(RFMRewardedVideo *)rewardedVideo reason:(NSString *)errorReason
{
    [self reportAdFailureToMoPub:errorReason];
}

- (void)rewardedVideoWillAppear:(RFMRewardedVideo *)rewardedVideo
{
    if (![self enableAutomaticImpressionAndClickTracking]) {
        [self.delegate trackClick];
    }
        
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
}

- (void)rewardedVideoDidAppear:(RFMRewardedVideo *)rewardedVideo
{
    if (![self enableAutomaticImpressionAndClickTracking]) {
        [self.delegate trackImpression];
    }
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)didStartRewardedVideoPlayback:(RFMRewardedVideo *)rewardedVideo
{
    
}

- (void)didFailToPlayRewardedVideo:(RFMRewardedVideo *)rewardedVideo reason:(NSString *)errorReason
{
    NSError *error = nil;
    // TODO: detect failure is due to cache exipration
    if(/* DISABLES CODE */ (NO)) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
        error = [self errorWithReason:errorReason code:REWARDED_VIDEO_HAS_EXPIRED_ERROR];
    } else {
        error = [self errorWithReason:errorReason code:REWARDED_VIDEO_DEFAULT_ERROR];
    }
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
}

- (void)didCompleteRewardedVideoPlayback:(RFMRewardedVideo *)rewardedVideo reward:(RFMReward *)rfmReward
{
    MPRewardedVideoReward *mpReward = [[MPRewardedVideoReward alloc] initWithCurrencyType:kMPRewardedVideoRewardCurrencyTypeUnspecified amount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)];
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:mpReward];
}

- (void)rewardedVideoWillDisappear:(RFMRewardedVideo *)rewardedVideo
{
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
}

- (void)rewardedVideoDidDisappear:(RFMRewardedVideo *)rewardedVideo
{
    _presentingRewardedVideoViewController.navigationController.navigationBarHidden = NO;
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
    [self handleCustomEventInvalidated];
}

- (void)rewardedVideoDidStopLoadingAndEnteredBackground:(RFMRewardedVideo *)rewardedVideo
{
    [self.delegate rewardedVideoWillLeaveApplicationForCustomEvent:self];
}


@end
