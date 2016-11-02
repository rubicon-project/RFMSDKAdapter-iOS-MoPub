//
//  RFMMoPubNativeAdRenderer.h
//  MoPub-RFM Sample
//
//  Created by Rubicon Project on 10/21/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPNativeAdRenderer.h"
#endif

@interface RFMMoPubNativeAdRenderer : NSObject <MPNativeAdRenderer>

@property (nonatomic, readonly) MPNativeViewSizeHandler viewSizeHandler;

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings;

@end
