//
//  Settings.h
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ALERT_ACTION_CANCEL 100
#define ALERT_ACTION_OTHER  101

typedef void (^UIAlertCompletionBlock) (UIAlertController* alertController, NSInteger buttonIndex);

@interface Settings : NSObject

+ (Settings *)settings;

- (void)idAuthenicateWithCompletionHandler:(void (^)(BOOL success, NSString * errorMsg))completionHandler;

- (UIAlertController *)showActionSheetIn:(UIViewController *)controller
                                   title:(NSString *)title
                       cancelButtonTitle:(NSString *)cancelButtonTitle
                       otherButtonTitles:(NSArray *)otherButtonTitles
                                tapBlock:(UIAlertCompletionBlock)tapBlock;

- (UIAlertController *)showAlertIn:(UIViewController *)controller
                             title:(NSString *)title
                           message:(NSString *)message;

- (UIAlertController *)showAlertIn:(UIViewController *)controller
                             title:(NSString *)title
                           message:(NSString *)message
                 cancelButtonTitle:(NSString *)cancelButtonTitle;

- (UIAlertController *)showAlertIn:(UIViewController *)controller
                             title:(NSString *)title
                           message:(NSString *)message
                 cancelButtonTitle:(NSString *)cancelButtonTitle
                 otherButtonTitles:(NSArray *)otherButtonTitles
                          tapBlock:(UIAlertCompletionBlock)tapBlock;

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title;

@end
