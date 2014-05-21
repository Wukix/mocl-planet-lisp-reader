//
//  LispMasterViewController.h
//  PlanetLisp
//
//  Created by Wes Henderson on 5/8/14.
//  Copyright (c) 2014 Wukix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LispMasterViewController : UITableViewController <UIAlertViewDelegate>
- (void)reload;
- (void)queueReload;
- (void)enableUI;
- (void)timedReload:(NSTimer *)timer;
- (void)showNetError;
@end
