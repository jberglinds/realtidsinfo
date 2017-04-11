//
//  ViewController.h
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-02-24.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RealtimeStopViewController : UIViewController

@property (nonatomic) NSInteger stopID;
@property (nonatomic) NSInteger journeyDirection;
@property (strong, nonatomic) NSString *locationName;

@end

