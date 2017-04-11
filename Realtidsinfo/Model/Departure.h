//
//  Departure.h
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-04-11.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Departure : NSObject

@property (strong, nonatomic)   NSString    *stopArea;
@property (strong, nonatomic)   NSString    *line;
@property (nonatomic)           NSInteger   journeyDirection;
@property (strong, nonatomic)   NSString    *destination;
@property (strong, nonatomic)   NSDate      *timeTabledAt;
@property (strong, nonatomic)   NSDate      *expectedAt;

@end
