//
//  LispDetailViewController.h
//  PlanetLisp
//
//  Created by Wes Henderson on 5/8/14.
//  Copyright (c) 2014 Wukix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LispDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
