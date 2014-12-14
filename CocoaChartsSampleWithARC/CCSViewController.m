//
//  CCSViewController.m
//  Cocoa-Charts
//
//  Created by limc on 13-05-22.
//  Copyright (c) 2012 limc.cn All rights reserved.
//

#import "CCSViewController.h"
#import "CCSAppDelegate.h"
#import "CCSSimpleDemoViewController.h"

@interface CCSViewController () {
}

@end

@implementation CCSViewController
@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                  style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
            | UIViewAutoresizingFlexibleTopMargin
            | UIViewAutoresizingFlexibleRightMargin
            | UIViewAutoresizingFlexibleBottomMargin
            | UIViewAutoresizingFlexibleHeight
            | UIViewAutoresizingFlexibleWidth;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.title = @"Cocoa-Charts v0.2";
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 21;
    }

    return 0;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UILabel *lblTitle = [[UILabel alloc] init];
        lblTitle.backgroundColor = [UIColor grayColor];
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.text = @"Charts Demo";
        return lblTitle;
    } else if (section == 1) {
        UILabel *lblTitle = [[UILabel alloc] init];
        lblTitle.backgroundColor = [UIColor grayColor];
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.text = @"Single Chart Demo";
        return lblTitle;
    } else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    if (indexPath.section == 0) {
        cell.textLabel.text = @"Simple Demo";
    }

 

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UIViewController *viewController = nil;

    if (indexPath.section == 0) {
        NSUInteger row = indexPath.row;
        if (row == 0) {
            viewController = [[CCSSimpleDemoViewController alloc] init];
            NSLog(@"%@",[[NSDate alloc] initWithTimeIntervalSinceNow:0]);
        }
    } else {
        return;
    }
    CCSAppDelegate *appDelegate = (CCSAppDelegate *) [UIApplication sharedApplication].delegate;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UINavigationController *navigationController = (UINavigationController *) appDelegate.viewController;
        [navigationController pushViewController:viewController animated:YES];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *) appDelegate.viewController;
        UINavigationController *navigationController = [splitViewController.viewControllers objectAtIndex:1];
        [navigationController popToRootViewControllerAnimated:NO];
        [navigationController pushViewController:viewController animated:YES];
    }
}


@end
