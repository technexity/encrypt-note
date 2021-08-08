//
//  Settings.m
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import <LocalAuthentication/LocalAuthentication.h>
#import "Settings.h"

NSString * const kBookmarkBundle = @"Bookmarks";
NSString * const kBookmarksInOrder = @"BookmarksInOrder";
NSString * const kBookmarksInAscOrder = @"BookmarksInAscOrder";

@interface Settings ()

@property (nonatomic, strong) NSUserDefaults * defaults;

@end

@implementation Settings

+ (Settings *)settings {
    static Settings *_sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedInstance = [[Settings alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)idAuthenicateWithCompletionHandler:(void (^)(BOOL success, NSString * errorMsg))completionHandler {

    LAContext *context = [[LAContext alloc] init];
    NSError *authError = nil;

    /// Test if fingerprint authentication is available on the device and a fingerprint has been enrolled.

    NSString *localizedReason = @"Please authenticate using your fingerprint.";

    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {

        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
               localizedReason:localizedReason reply:^(BOOL success, NSError *error) {
           
            if (success) {
                NSLog(@"User authenticated successfully, take appropriate action");
               
                // User authenticated successfully, take appropriate action
                completionHandler(YES, nil);
            }
            else {
                NSLog(@"User did not authenticate successfully, look at error and take appropriate action");
               
                NSString * errorMessage = nil;
               
                switch (error.code) {
                case LAErrorAuthenticationFailed:
                    errorMessage = @"There was a problem verifying your identity.";
                    break;
                case LAErrorUserCancel:
                    NSLog(@"user has tapped the home button and authentication is canced by user");

                    errorMessage = @"You pressed cancel.";
                    break;
                case LAErrorUserFallback:
                    errorMessage = @"You pressed password.";
                    break;
                case LAErrorBiometryNotAvailable:
                    errorMessage = @"Face ID/Touch ID is not available.";
                    break;
                case LAErrorBiometryNotEnrolled:
                    errorMessage = @"Face ID/Touch ID is not set up.";
                    break;
                case LAErrorBiometryLockout:
                    NSLog(@"Authentication was not successful because there were too many failed biometry attempts (5 consequitive attempts) and biometry is now locked.Passcode is required to unlock biometry");

                    errorMessage = @"Face ID/Touch ID is locked.";
                    break;
                default:
                    errorMessage = @"Face ID/Touch ID may not be configured";
                }
               
                completionHandler(NO, errorMessage);
           }
       }];
    }
    else {
        if (authError.code) {
            NSLog(@"There is no need to handle evaluate policy auth error as user is already handled the policy evaluated error in app delegate if user is not handling the policy evaluated error in app delegate then handle the auth error here.");
        }
        
        completionHandler(NO, authError.localizedDescription);
    }
}

#pragma mark - Alert & Action Sheet

- (UIAlertController *)showActionSheetIn:(UIViewController *)controller
                                   title:(NSString *)title
                       cancelButtonTitle:(NSString *)cancelButtonTitle
                       otherButtonTitles:(NSArray *)otherButtonTitles
                                tapBlock:(UIAlertCompletionBlock)tapBlock
{
    return [self showAlertIn:controller title:title message:nil preferredStyle:UIAlertControllerStyleActionSheet
           cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles tapBlock:tapBlock];
}

- (UIAlertController *)showAlertIn:(UIViewController *)controller
                             title:(NSString *)title
                           message:(NSString *)message
                 cancelButtonTitle:(NSString *)cancelButtonTitle
                 otherButtonTitles:(NSArray *)otherButtonTitles
                          tapBlock:(UIAlertCompletionBlock)tapBlock
{
    return [self showAlertIn:controller title:title message:message preferredStyle:UIAlertControllerStyleAlert
           cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles tapBlock:tapBlock];
}

- (UIAlertController *)showAlertIn:(UIViewController *)controller
                             title:(NSString *)title
                           message:(NSString *)message
                    preferredStyle:(UIAlertControllerStyle)preferredStyle
                 cancelButtonTitle:(NSString *)cancelButtonTitle
                 otherButtonTitles:(NSArray *)otherButtonTitles
                          tapBlock:(UIAlertCompletionBlock)tapBlock
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelButtonTitle != nil) {
        [alert addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:nil]];
    }
    
    if (otherButtonTitles != nil) {
        [otherButtonTitles enumerateObjectsUsingBlock:^(id  _Nonnull bTitle, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [alert addAction:[UIAlertAction actionWithTitle:bTitle
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction* action)
                              {
                                  tapBlock(alert, idx);
                              }]];
            
        }];
    }
    
    [controller presentViewController:alert animated:YES completion:nil];
    
    return alert;
}

- (UIAlertController *)showAlertIn:(UIViewController *)controller
                             title:(NSString *)title
                           message:(NSString *)message
                 cancelButtonTitle:(NSString *)cancelButtonTitle
{
    return [self showAlertIn:controller title:title message:message
           cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil tapBlock:nil];
}

- (UIAlertController *)showAlertIn:(UIViewController *)controller
                             title:(NSString *)title
                           message:(NSString *)message
{
    return [self showAlertIn:controller title:title message:message cancelButtonTitle:NSLocalizedString(@"OK", nil)];
}

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIViewController* rvc = [[[UIApplication sharedApplication].delegate window] rootViewController];
    [self showAlertIn:rvc title:title message:message];
}

@end
