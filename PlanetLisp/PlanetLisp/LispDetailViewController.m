//
//  LispDetailViewController.m
//  PlanetLisp
//
//  Created by Wes Henderson on 5/8/14.
//  Copyright (c) 2014 Wukix. All rights reserved.
//

#import "LispDetailViewController.h"
#import "mocl.h"

@interface LispDetailViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;
- (void)configureView;
@end

@implementation LispDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
   
    /* from lisp:
     (declaim (call-in load-content))
     (defun load-content (self) ... )
    */
    load_content(self);
}

- (IBAction)openInSafari_Tap:(id)sender {
    open_external_browser();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
