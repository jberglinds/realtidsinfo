//
//  LightsController.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-04-16.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "LightsController.h"

@interface LightsController ()
@property (strong, nonatomic) HMHomeManager *homeManager;

@property (strong, nonatomic, readwrite) NSArray *lights; // of HMService
@property (strong, nonatomic, readwrite) NSMutableSet *activatedLights; // of HMService
@end

@implementation LightsController

#pragma mark - Singleton
+ (LightsController *)sharedInstance {
    static LightsController *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LightsController alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Initialization
- (instancetype)init {
    self = [super init];
    if (self) {
        self.homeManager = [[HMHomeManager alloc] init];
        self.homeManager.delegate = self;
        self.brightness = 100;
    }
    return self;
}

- (void)setActivated:(BOOL)activated {
    if (activated) {
        [self setLightsToColor:self.currentColor];
    } else {
        self.currentColor = nil;
    }
    _activated = activated;
}

- (NSMutableSet *)activatedLights {
    if (!_activatedLights) _activatedLights = [[NSMutableSet alloc] init];
    return _activatedLights;
}

#pragma mark - HMHomeManagerDelegate
- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager {
    HMHome *primaryHome = [[self.homeManager homes] firstObject];
    self.lights = [primaryHome servicesWithTypes:@[HMServiceTypeLightbulb]];
}

// Never being called for some reason...
//- (void)homeManagerDidUpdatePrimaryHome:(HMHomeManager *)manager {
//    HMHome *primaryHome = [self.homeManager primaryHome];
//    self.lights = [primaryHome servicesWithTypes:@[HMServiceTypeLightbulb]];
//}

#pragma mark -
- (void)activateLight:(HMService *)light {
    [self.activatedLights addObject:light];
    [self setLightsToColor:self.currentColor];
}

- (void)deactivateLight:(HMService *)light {
    [self.activatedLights removeObject:light];
}

- (void)setLightsToColor:(UIColor *)color {
    if (self.activated && color) {
        CGFloat hue, saturation, brightness, alpha;
        [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        for (HMService *light in self.activatedLights) {
            for (HMCharacteristic *characteristic in light.characteristics) {
                // If brightness is zero = black color = turn off lights
                if (brightness) {
                    if ([characteristic.characteristicType isEqualToString:HMCharacteristicTypePowerState]) {
                        [characteristic writeValue:@YES completionHandler:^(NSError *error) {
                            // Handle error
                        }];
                    } else if ([characteristic.characteristicType isEqualToString:HMCharacteristicTypeHue]) {
                        [characteristic writeValue:@(hue*360.0) completionHandler:^(NSError *error) {
                            // Handle error
                        }];
                    } else if ([characteristic.characteristicType isEqualToString:HMCharacteristicTypeSaturation]) {
                        [characteristic writeValue:@(saturation*100.0) completionHandler:^(NSError *error) {
                            // Handle error
                        }];
                    } else if ([characteristic.characteristicType isEqualToString:HMCharacteristicTypeBrightness]) {
                        [characteristic writeValue:@(self.brightness) completionHandler:^(NSError *error) {
                            // Handle error
                        }];
                    }
                } else {
                    if ([characteristic.characteristicType isEqualToString:HMCharacteristicTypePowerState]) {
                        [characteristic writeValue:@NO completionHandler:^(NSError *error) {
                            // Handle error
                        }];
                    }
                }
            }
        }
        self.currentColor = color;
    }
}


@end
