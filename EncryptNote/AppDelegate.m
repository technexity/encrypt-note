//
//  AppDelegate.m
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong) NSURL * iCloudURL;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self initializeiCloudAccessWithCompletionHandler:^(BOOL isAvailable) {
        self.iCloudIsAvailable = isAvailable;
    }];
}

#pragma mark -

- (void)initializeiCloudAccessWithCompletionHandler:(void(^)(BOOL isAvailable)) completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.iCloudURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        if (self.iCloudURL != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"iCloud is available - %@", self.iCloudURL);
                completion(YES);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"iCloud is not available");
                completion(NO);
            });
        }
    });
}

@end
