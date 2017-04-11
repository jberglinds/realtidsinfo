//
//  RealtimeSite.h
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-02-27.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RealtimeSite : NSObject

- (instancetype)initWithSiteID:(NSInteger)ID;

@property (nonatomic) NSInteger siteID;

@property (strong, nonatomic, readonly) NSDate  *updatedAt;
@property (strong, nonatomic, readonly) NSArray *departures; // of Departure

- (void)startUpdates;
- (void)stopUpdates;

@end
