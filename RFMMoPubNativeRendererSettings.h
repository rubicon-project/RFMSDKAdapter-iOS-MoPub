//
//  RFMMoPubNativeRendererSettings.h
//  MoPub-RFM Sample
//
//  Created by Rubicon Project on 10/21/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPNativeAdRendererSettings.h"
#endif

@interface RFMMoPubNativeRendererSettings : NSObject <MPNativeAdRendererSettings>

@property (nonatomic, assign) Class renderingViewClass;

@property (nonatomic, readwrite, copy) MPNativeViewSizeHandler viewSizeHandler;

@end
