//
//  ChannelsConfig.h
//  Channels
//
//  Created by Stuart Tett on 9/2/15.
//  Copyright © 2015 Complex Polygon. All rights reserved.
//

#ifndef ChannelsConfig_h
#define ChannelsConfig_h

/* --------------------- CONFIGS AND DEBUGGERS ONLY --------------------- */


#define CONFIG_TARGET_PRODUCTION 0

#define CONFIG_BETA_ENABLED 0
#define CONFIG_BETA_VERSION 0.1

#if CONFIG_TARGET_PRODUCTION

#define CONFIG_ENABLE_LOGS 0

#define CONFIG_BASE_URL @""
#define CONFIG_AMAZON_S3_ACCESS_KEY @"AKIAIK7DKZPP7GCBYHZA"
#define CONFIG_AMAZON_S3_SECRET_KEY @"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"

#else

#define CONFIG_ENABLE_LOGS 1

#define CONFIG_BASE_URL @""

#define CONFIG_AMAZON_S3_ACCESS_KEY @"AKIAIK7DKZPP7GCBYHZA"
#define CONFIG_AMAZON_S3_SECRET_KEY @"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"

#endif

#endif /* ChannelsConfig_h */
