//
//  TrafiklabAPI.h
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-03-29.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrafiklabAPI : NSObject

- (instancetype)init;

- (void)getStopsMatchingString:(NSString *)searchString completion:(void(^)(NSArray *))completion;

- (void)getRealtimeForStop:(NSInteger)siteID completion:(void(^)(NSArray *))completion;

@end
