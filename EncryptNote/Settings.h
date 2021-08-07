//
//  Settings.h
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Settings : NSObject

+ (Settings *)settings;

- (void)idAuthenicateWithCompletionHandler:(void (^)(BOOL success, NSString * errorMsg))completionHandler;

@end

NS_ASSUME_NONNULL_END
