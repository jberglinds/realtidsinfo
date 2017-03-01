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

@property (strong, nonatomic, readonly) NSString *locationName;
@property (strong, nonatomic, readonly) NSString *busName;
@property (strong, nonatomic, readonly) NSString *busDestination;
@property (strong, nonatomic, readonly) NSDate *expectedAt;
@property (strong, nonatomic, readonly) NSDate *updatedAt;

- (void)startUpdates;
- (void)stopUpdates;
@end
