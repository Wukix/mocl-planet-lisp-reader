//
//  LispMasterViewController.m
//  PlanetLisp
//
//  Created by Wes Henderson on 5/8/14.
//  Copyright (c) 2014 Wukix. All rights reserved.
//

#import "LispMasterViewController.h"

#import "LispDetailViewController.h"
#import "mocl.h"

@interface LispMasterViewController () {
    NSMutableArray *_objects;
    BOOL alertActive;
    __weak IBOutlet UIBarButtonItem *btnReload;
}
@end

@implementation LispMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self queueReload];
    
    // auto-reload feed every 8 hours
    NSTimeInterval seconds = 8.0 * 60.0 * 60.0;
    [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(timedReload:) userInfo:nil repeats:YES];
}

- (void)reload
{
    load_rss(self);
    [[self tableView] reloadData];
    [self performSelector:@selector(enableUI) withObject:nil afterDelay:0.2];
}

- (void)enableUI
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [btnReload setEnabled:YES];
}

- (void)queueReload
{
    [btnReload setEnabled:NO];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self performSelector:@selector(reload) withObject:nil afterDelay:0.1];
}

- (IBAction)reload_Tap:(id)sender
{
    [self queueReload];
}

- (void)timedReload:(NSTimer *)timer
{
    [self queueReload];
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    alertActive = NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        alertActive = NO;
    }
}

- (void)showNetError
{
    if (!alertActive) {
        alertActive = YES;
        // mocl's Obj-C syntax does not support variable-length arguments, so we put this here
        // and call showNetError from mocl as needed
        [[[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Unable to connect. Please check your internet and try again." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil]
         show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}*/

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    long count = get_item_count();
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    config_cell(cell, indexPath.row);
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        set_item_index(indexPath.row);
    }
}

@end
