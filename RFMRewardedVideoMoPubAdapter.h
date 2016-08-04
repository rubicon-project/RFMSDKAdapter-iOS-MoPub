//
//  RFMRewardedVideoMoPubAdapter.h
//
//  Created by Rubicon Project on 6/28/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPRewardedVideoCustomEvent.h"
#endif

@interface RFMRewardedVideoMoPubAdapter : MPRewardedVideoCustomEvent

@end
