//
//  RFMMoPubNativeAdapter.h
//  MoPub-RFM Sample
//
//  Created by Rubicon Project on 10/12/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPNativeAdAdapter.h"
#endif

#import <RFMAdSDK/RFMAdSDK.h>

@interface RFMMoPubNativeAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

- (instancetype)initWithRFMNativeAd:(RFMNativeAd *)nativeAd response:(RFMNativeAdResponse *)nativeAdResponse;
- (void)displayContentForNativeAdTap;

@end
