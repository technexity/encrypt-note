//
//  RootTabBarController.m
//  EncryptNote
//
//  Created by Nam Tran on 08/08/2021.
//

#import "RootTabBarController.h"
#import "MasterNoteViewController.h"
#import "MasterBookmarkViewController.h"
#import "MasterSettingsViewController.h"

@interface RootTabBarController ()

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    MasterNoteViewController * viewController1 = [[MasterNoteViewController alloc] init];
    viewController1.title = NSLocalizedString(@"Notes", nil);
    viewController1.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:1];
    
    MasterBookmarkViewController * viewController2 = [[MasterBookmarkViewController alloc] init];
    viewController2.title = NSLocalizedString(@"Bookmarks", nil);
    viewController2.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:2];
    
    MasterSettingsViewController * viewController3 = [[MasterSettingsViewController alloc] init];
    viewController3.title = NSLocalizedString(@"Settings", nil);
    viewController3.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:3];
    
    // Navigation controller instances
    UINavigationController * nav1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    UINavigationController * nav2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    UINavigationController * nav3 = [[UINavigationController alloc] initWithRootViewController:viewController3];

    self.viewControllers = @[nav1, nav2, nav3];
}

@end
