//
//  LightsController.h
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-04-16.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HomeKit/Homekit.h>

@interface LightsController : NSObject <HMHomeManagerDelegate>

@property (nonatomic) BOOL activated;
@property (strong, nonatomic, readonly) NSArray *lights; // of HMService
@property (strong, nonatomic, readonly) NSMutableSet *activatedLights; // of HMService
@property (nonatomic) NSInteger brightness;

+ (LightsController *)sharedInstance;
- (void)activateLight:(HMService *)light;
- (void)deactivateLight:(HMService *)light;
- (void)setLightsToColor:(UIColor *)color;

@end
