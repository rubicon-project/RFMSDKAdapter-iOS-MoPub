//
//  RFMMoPubAdapterConstants.h
//
//
//  Created by The Rubicon Project on 2/20/15.
//  Copyright (c) 2015 Rubicon Project. All rights reserved.
//

#ifndef MoPub_RFM_Sample_RFMMoPubAdapterConstants_h
#define MoPub_RFM_Sample_RFMMoPubAdapterConstants_h

#define RFM_MOPUB_APP_ID_KEY @"rfm_app_id"
#define RFM_MOPUB_PUB_ID_KEY @"rfm_pub_id"
#define RFM_MOPUB_SERVER_KEY @"rfm_server_name"

#define RFM_ADAPTER_VER_KEY @"adp_version"
#define RFM_MOPUB_ADAPTER_VER @"mp_adp_2.0.0"

#define RFM_MOPUB_ADP_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#endif
